package com.tilbuci.showtime;

import android.content.Context;
import fi.iki.elonen.NanoHTTPD;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class LocalServer extends NanoHTTPD {

    private Context context;
    private File filesDir;

    public LocalServer(int port, Context context, File filesDir) {
        super(port);
        this.context = context;
        this.filesDir = filesDir;
    }

    @Override
    public Response serve(IHTTPSession session) {
        String uri = session.getUri();
        Method method = session.getMethod();
        
        if (uri.equals("/api/config")) {
            File configFile = new File(filesDir, "config.json");
            if (Method.POST.equals(method)) {
                try {
                    java.util.Map<String, String> files = new java.util.HashMap<>();
                    session.parseBody(files);
                    String postData = files.get("postData");
                    
                    if (postData != null) {
                        java.io.FileOutputStream fos = new java.io.FileOutputStream(configFile);
                        fos.write(postData.getBytes("UTF-8"));
                        fos.close();
                        
                        try {
                            org.json.JSONObject config = new org.json.JSONObject(postData);
                            String movie = config.optString("movie", "");
                            String ws = config.optString("ws", "");
                            String accesskey = config.optString("accesskey", "ABCDA");
                            
                            File tilbuciTemplate = new File(new File(filesDir, "tilbuci"), "tilbuci.html");
                            File indexFile = new File(new File(filesDir, "tilbuci"), "index.html");
                            if (tilbuciTemplate.exists()) {
                                java.io.InputStream in = new java.io.FileInputStream(tilbuciTemplate);
                                byte[] tbuf = new byte[in.available()];
                                in.read(tbuf);
                                in.close();
                                String content = new String(tbuf, "UTF-8");
                                
                                content = content.replace("[MOVIE]", movie);
                                content = content.replace("[WS]", ws);
                                
                                String injectScript = "<script>\n" +
                                        "    let access = \"\";\n" +
                                        "    let accesskey = \"" + accesskey + "\";\n" +
                                        "    function addAccess(char) {\n" +
                                        "        access += char;\n" +
                                        "        if (access.length > 5) access = access.substring(access.length - 5);\n" +
                                        "        if (access === accesskey) {\n" +
                                        "            window.location.href = \"http://localhost:8080/config/config.html\";\n" +
                                        "        }\n" +
                                        "    }\n" +
                                        "</script>\n" +
                                        "<style>\n" +
                                        "    .abcd-area { position: fixed; z-index: 999999; cursor: pointer; -webkit-tap-highlight-color: transparent; }\n" +
                                        "    @media (orientation: landscape) { .abcd-area { width: 5%; height: 10%; } }\n" +
                                        "    @media (orientation: portrait) { .abcd-area { width: 10%; height: 5%; } }\n" +
                                        "    #area-A { top: 0; left: 0; }\n" +
                                        "    #area-B { top: 0; right: 0; }\n" +
                                        "    #area-C { bottom: 0; left: 0; }\n" +
                                        "    #area-D { bottom: 0; right: 0; }\n" +
                                        "</style>\n" +
                                        "<div id=\"area-A\" class=\"abcd-area\" onclick=\"addAccess('A')\"></div>\n" +
                                        "<div id=\"area-B\" class=\"abcd-area\" onclick=\"addAccess('B')\"></div>\n" +
                                        "<div id=\"area-C\" class=\"abcd-area\" onclick=\"addAccess('C')\"></div>\n" +
                                        "<div id=\"area-D\" class=\"abcd-area\" onclick=\"addAccess('D')\"></div>\n";
                                
                                content = content.replace("</body>", injectScript + "</body>");
                                
                                java.io.FileOutputStream ifos = new java.io.FileOutputStream(indexFile);
                                ifos.write(content.getBytes("UTF-8"));
                                ifos.close();
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                return newFixedLengthResponse(Response.Status.OK, "application/json", "{\"success\":true}");
            } else {
                if (configFile.exists()) {
                    try {
                        java.io.InputStream is = new java.io.FileInputStream(configFile);
                        byte[] buffer = new byte[is.available()];
                        is.read(buffer);
                        is.close();
                        String content = new String(buffer, "UTF-8");
                        return newFixedLengthResponse(Response.Status.OK, "application/json", content);
                    } catch (Exception e) {}
                }
                return newFixedLengthResponse(Response.Status.OK, "application/json", "{\"movie\":\"\",\"ws\":\"\",\"wsKey\":\"\",\"accesskey\":\"ABCDA\",\"identifier\":\"\",\"autoStart\":false}");
            }
        }
        if (uri.equals("/api/upload") && Method.POST.equals(method)) {
            try {
                java.util.Map<String, String> files = new java.util.HashMap<>();
                session.parseBody(files);
                
                // In NanoHTTPD, uploaded files are stored in temp files, we just get the location
                String tempFilePath = files.get("file");
                if (tempFilePath != null) {
                    // We need original name. NanoHTTPD provides it in session.getParms()
                    java.util.Map<String, String> parms = session.getParms();
                    String originalName = parms.get("file");
                    if (originalName != null && originalName.endsWith(".zip")) {
                        String movieName = originalName.substring(0, originalName.length() - 4);
                        File targetDir = new File(new File(new File(filesDir, "tilbuci"), "movie"), movieName + ".movie");
                        unzip(new File(tempFilePath), targetDir);
                        return newFixedLengthResponse(Response.Status.OK, "application/json", "{\"success\":true,\"movie\":\"" + movieName + "\"}");
                    }
                }
                return newFixedLengthResponse(Response.Status.OK, "application/json", "{\"success\":false,\"error\":\"Invalid file\"}");
            } catch (Exception e) {
                e.printStackTrace();
                return newFixedLengthResponse(Response.Status.OK, "application/json", "{\"success\":false,\"error\":\"Upload failed\"}");
            }
        }
        
        if (uri.equals("/api/delete") && Method.POST.equals(method)) {
            try {
                java.util.Map<String, String> files = new java.util.HashMap<>();
                session.parseBody(files);
                String postData = files.get("postData");
                if (postData != null) {
                    org.json.JSONObject obj = new org.json.JSONObject(postData);
                    String movieName = obj.optString("movie", "");
                    if (!movieName.isEmpty()) {
                        File targetDir = new File(new File(new File(filesDir, "tilbuci"), "movie"), movieName + ".movie");
                        deleteRecursively(targetDir);
                    }
                }
                return newFixedLengthResponse(Response.Status.OK, "application/json", "{\"success\":true}");
            } catch (Exception e) {
                e.printStackTrace();
                return newFixedLengthResponse(Response.Status.OK, "application/json", "{\"success\":false}");
            }
        }
        
        if (uri.equals("/api/movies")) {
            File moviesDir = new File(new File(filesDir, "tilbuci"), "movie");
            org.json.JSONArray arr = new org.json.JSONArray();
            if (moviesDir.exists() && moviesDir.isDirectory()) {
                File[] dirs = moviesDir.listFiles();
                if (dirs != null) {
                    for (File d : dirs) {
                        if (d.isDirectory() && d.getName().endsWith(".movie")) {
                            arr.put(d.getName().substring(0, d.getName().length() - 6));
                        }
                    }
                }
            }
            return newFixedLengthResponse(Response.Status.OK, "application/json", arr.toString());
        }
        
        if (uri.equals("/")) {
            uri = "/index.html";
        }
        
        try {
            File file;
            if (uri.startsWith("/config/")) {
                file = new File(filesDir, uri.substring(1));
            } else {
                file = new File(new File(filesDir, "tilbuci"), uri.substring(1));
            }
            
            if (file.exists() && !file.isDirectory()) {
                String mimeType = getContentType(uri);
                InputStream is = new FileInputStream(file);
                return newFixedLengthResponse(Response.Status.OK, mimeType, is, file.length());
            } else {
                return newFixedLengthResponse(Response.Status.NOT_FOUND, "text/plain", "Not Found");
            }
        } catch (Exception e) {
            return newFixedLengthResponse(Response.Status.INTERNAL_ERROR, "text/plain", e.toString());
        }
    }

    private String getContentType(String uri) {
        if (uri.endsWith(".html")) return "text/html";
        if (uri.endsWith(".js")) return "application/javascript";
        if (uri.endsWith(".css")) return "text/css";
        if (uri.endsWith(".png")) return "image/png";
        if (uri.endsWith(".jpg") || uri.endsWith(".jpeg")) return "image/jpeg";
        if (uri.endsWith(".json")) return "application/json";
        return "application/octet-stream";
    }

    private void unzip(File zipFile, File targetDir) throws Exception {
        if (!targetDir.exists()) targetDir.mkdirs();
        java.util.zip.ZipInputStream zis = new java.util.zip.ZipInputStream(new java.io.FileInputStream(zipFile));
        java.util.zip.ZipEntry zipEntry = zis.getNextEntry();
        byte[] buffer = new byte[1024];
        while (zipEntry != null) {
            File newFile = new File(targetDir, zipEntry.getName());
            if (zipEntry.isDirectory()) {
                newFile.mkdirs();
            } else {
                newFile.getParentFile().mkdirs();
                java.io.FileOutputStream fos = new java.io.FileOutputStream(newFile);
                int len;
                while ((len = zis.read(buffer)) > 0) {
                    fos.write(buffer, 0, len);
                }
                fos.close();
            }
            zipEntry = zis.getNextEntry();
        }
        zis.closeEntry();
        zis.close();
    }
    
    private void deleteRecursively(File f) {
        if (f.isDirectory()) {
            for (File c : f.listFiles()) {
                deleteRecursively(c);
            }
        }
        f.delete();
    }
}
