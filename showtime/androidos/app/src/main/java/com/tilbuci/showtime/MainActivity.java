package com.tilbuci.showtime;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import androidx.appcompat.app.AppCompatActivity;

import android.webkit.WebChromeClient;
import android.webkit.ValueCallback;
import android.net.Uri;
import android.content.Intent;
import android.content.ActivityNotFoundException;
import android.widget.Toast;

import org.json.JSONObject;

import java.io.InputStreamReader;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;
import java.security.MessageDigest;
import android.view.WindowManager;
import android.graphics.Color;
import android.webkit.WebViewClient;
import android.webkit.WebResourceRequest;

import android.webkit.JavascriptInterface;

public class MainActivity extends AppCompatActivity {
    
    private boolean isKiosk = false;

    private WebView webView;
    private LocalServer localServer;
    private static final int PORT = 8080;
    
    private ValueCallback<Uri[]> uploadMessage;
    public static final int REQUEST_SELECT_FILE = 100;
    private Timer pingTimer;

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(this);
        setContentView(webView);

        hideSystemUI();

        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webSettings.setDomStorageEnabled(true);
        webSettings.setMediaPlaybackRequiresUserGesture(false);
        webSettings.setAllowFileAccess(true);
        webSettings.setLoadWithOverviewMode(true);
        webSettings.setUseWideViewPort(true);

        webView.addJavascriptInterface(new Object() {
            @JavascriptInterface
            public void closeApp() {
                finishAffinity();
                System.exit(0);
            }
        }, "AndroidApp");

        webView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageFinished(WebView view, String url) {
                if (url != null && url.contains("config.html")) {
                    setKioskMode(false);
                } else {
                    setKioskMode(true);
                }
            }
        });
        webView.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {
                if (uploadMessage != null) {
                    uploadMessage.onReceiveValue(null);
                    uploadMessage = null;
                }
                uploadMessage = filePathCallback;
                Intent intent = fileChooserParams.createIntent();
                try {
                    startActivityForResult(intent, REQUEST_SELECT_FILE);
                } catch (ActivityNotFoundException e) {
                    uploadMessage = null;
                    Toast.makeText(MainActivity.this, "Cannot Open File Chooser", Toast.LENGTH_LONG).show();
                    return false;
                }
                return true;
            }
        });

        // Copy assets to internal storage if needed
        File internalDir = getFilesDir();
        if (!new File(internalDir, "tilbuci.html").exists()) {
            copyAssetsToInternal("tilbuci", internalDir);
            copyAssetsToInternal("config", internalDir);
        }

        // Generate index.html based on config.json
        File tilbuciDir = new File(internalDir, "tilbuci");
        if (!tilbuciDir.exists()) tilbuciDir.mkdirs();
        
        File indexFile = new File(tilbuciDir, "index.html");
        File tilbuciTemplate = new File(tilbuciDir, "tilbuci.html");
        File configFile = new File(internalDir, "config.json");
        String movie = "";
        String ws = "";
        String accesskey = "ABCDA";
        
        if (configFile.exists()) {
            try {
                InputStream is = new FileInputStream(configFile);
                byte[] buf = new byte[is.available()];
                is.read(buf);
                is.close();
                JSONObject config = new JSONObject(new String(buf, "UTF-8"));
                movie = config.optString("movie", "");
                ws = config.optString("ws", "");
                accesskey = config.optString("accesskey", "ABCDA");
            } catch (Exception e) {}
        }
        
        if (tilbuciTemplate.exists()) {
            try {
                InputStream in = new FileInputStream(tilbuciTemplate);
                byte[] buffer = new byte[in.available()];
                in.read(buffer);
                in.close();
                String content = new String(buffer, "UTF-8");
                
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
                
                FileOutputStream fos = new FileOutputStream(indexFile);
                fos.write(content.getBytes("UTF-8"));
                fos.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        } else if (!indexFile.exists()) {
            try {
                FileOutputStream fos = new FileOutputStream(indexFile);
                fos.write("<html><body><h1>TilBuci Showtime</h1><p>Template not found.</p></body></html>".getBytes());
                fos.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        // Start NanoHTTPD
        try {
            localServer = new LocalServer(PORT, this, internalDir);
            localServer.start();
            Log.i("MainActivity", "Local server started on port " + PORT);
            
            if (!movie.isEmpty()) {
                webView.loadUrl("http://localhost:" + PORT + "/index.html");
            } else {
                webView.loadUrl("http://localhost:" + PORT + "/config/config.html");
            }
            
        } catch (IOException e) {
            e.printStackTrace();
            webView.loadData("<html><body><h1>Server Error</h1><p>" + e.getMessage() + "</p></body></html>", "text/html", "UTF-8");
        }

        startPingTimer();
    }

    private void startPingTimer() {
        if (pingTimer != null) pingTimer.cancel();
        pingTimer = new Timer();
        pingTimer.scheduleAtFixedRate(new TimerTask() {
            @Override
            public void run() {
                doPing();
            }
        }, 5000, 15 * 60 * 1000); // Wait 5s for init, then every 15 min
    }

    private String getMd5(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] messageDigest = md.digest(input.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : messageDigest) {
                String hex = Integer.toHexString(0xFF & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString().toLowerCase();
        } catch (Exception e) {
            return "";
        }
    }

    private void setLastError(String err) {
        try {
            File configFile = new File(getFilesDir(), "config.json");
            if (!configFile.exists()) return;
            InputStream is = new FileInputStream(configFile);
            byte[] buffer = new byte[is.available()];
            is.read(buffer);
            is.close();
            JSONObject config = new JSONObject(new String(buffer, "UTF-8"));
            config.put("lastError", err);
            FileOutputStream fos = new FileOutputStream(configFile);
            fos.write(config.toString().getBytes("UTF-8"));
            fos.close();
        } catch (Exception e) {}
    }

    private void doPing() {
        Log.i("MainActivity", "doPing() triggered...");
        try {
            File configFile = new File(getFilesDir(), "config.json");
            if (!configFile.exists()) {
                Log.w("MainActivity", "Ping aborted: config.json not found.");
                return;
            }
            
            InputStream is = new FileInputStream(configFile);
            byte[] buffer = new byte[is.available()];
            is.read(buffer);
            is.close();
            String configJson = new String(buffer, "UTF-8");
            JSONObject config = new JSONObject(configJson);
            
            String ws = config.optString("ws", "");
            String wsKey = config.optString("wsKey", "");
            String identifier = config.optString("identifier", "");
            
            if (ws.isEmpty() || wsKey.length() < 5) {
                Log.w("MainActivity", "Ping aborted: ws empty or wsKey < 5. ws=" + ws + " wsKey.length=" + wsKey.length());
                return;
            }
            
            Log.i("MainActivity", "Ping sending to: " + ws + "ws/");
            
            StringBuilder moviesList = new StringBuilder();
            File moviesDir = new File(new File(getFilesDir(), "tilbuci"), "movie");
            if (moviesDir.exists() && moviesDir.isDirectory()) {
                File[] dirs = moviesDir.listFiles();
                if (dirs != null) {
                    for (File d : dirs) {
                        if (d.isDirectory() && d.getName().endsWith(".movie")) {
                            if (moviesList.length() > 0) moviesList.append(",");
                            moviesList.append(d.getName().substring(0, d.getName().length() - 6));
                        }
                    }
                }
            }

            JSONObject rObj = new JSONObject();
            rObj.put("name", identifier);
            rObj.put("config", configJson);
            rObj.put("movies", moviesList.toString());
            rObj.put("type", "androidos");
            
            String rStr = rObj.toString();
            String sStr = getMd5(rStr);
            String kStr = getMd5(wsKey + sStr);
            
            String params = "a=Showtime/Ping&u=system&r=" + Uri.encode(rStr) + "&s=" + sStr + "&k=" + kStr;
            
            if (!ws.endsWith("/")) ws += "/";
            URL url = new URL(ws + "ws/");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            
            OutputStream os = conn.getOutputStream();
            os.write(params.getBytes("UTF-8"));
            os.flush();
            os.close();
            
            int responseCode = conn.getResponseCode();
            Log.i("MainActivity", "Ping response code: " + responseCode);
            if (responseCode == 200) {
                BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String inputLine;
                StringBuilder response = new StringBuilder();
                while ((inputLine = in.readLine()) != null) {
                    response.append(inputLine);
                }
                in.close();
                
                Log.i("MainActivity", "Ping response payload: " + response.toString());
                
                try {
                    JSONObject data = new JSONObject(response.toString());
                    if (data.has("e")) {
                        setLastError(data.optString("e"));
                    } else {
                        setLastError("unknown format");
                    }
                    
                    if (data.has("conf")) {
                        JSONObject conf = data.optJSONObject("conf");
                        if (conf != null) {
                            // save new conf and then:
                            clearConfServer(ws, wsKey, identifier);
                        }
                    }
                    
                    String remove = data.optString("remove", "");
                    if (!remove.isEmpty()) {
                        try {
                            File targetDir = new File(new File(new File(getFilesDir(), "tilbuci"), "movie"), remove + ".movie");
                            deleteRecursively(targetDir);
                        } catch (Exception e) {}
                        clearRemoveServer(ws, wsKey, identifier, remove);
                    }
                    
                    String upload = data.optString("upload", "");
                    if (!upload.isEmpty()) {
                        // Handle download/extract locally then:
                        try {
                            URL dlUrl = new URL(ws + "download/?a=download&file=export&movie=" + Uri.encode(upload));
                            HttpURLConnection dlConn = (HttpURLConnection) dlUrl.openConnection();
                            dlConn.setRequestMethod("GET");
                            if (dlConn.getResponseCode() == 200) {
                                File tempFile = new File(getFilesDir(), upload + ".zip");
                                InputStream dlIn = dlConn.getInputStream();
                                FileOutputStream fos = new FileOutputStream(tempFile);
                                byte[] buf = new byte[1024];
                                int len;
                                while ((len = dlIn.read(buf)) > 0) {
                                    fos.write(buf, 0, len);
                                }
                                fos.close();
                                dlIn.close();
                                
                                File targetDir = new File(new File(new File(getFilesDir(), "tilbuci"), "movie"), upload + ".movie");
                                if (!targetDir.exists()) targetDir.mkdirs();
                                
                                java.util.zip.ZipInputStream zis = new java.util.zip.ZipInputStream(new java.io.FileInputStream(tempFile));
                                java.util.zip.ZipEntry zipEntry = zis.getNextEntry();
                                while (zipEntry != null) {
                                    File newFile = new File(targetDir, zipEntry.getName());
                                    if (zipEntry.isDirectory()) {
                                        newFile.mkdirs();
                                    } else {
                                        newFile.getParentFile().mkdirs();
                                        FileOutputStream zFos = new FileOutputStream(newFile);
                                        int zLen;
                                        while ((zLen = zis.read(buf)) > 0) {
                                            zFos.write(buf, 0, zLen);
                                        }
                                        zFos.close();
                                    }
                                    zipEntry = zis.getNextEntry();
                                }
                                zis.closeEntry();
                                zis.close();
                                tempFile.delete();
                            }
                        } catch (Exception e) {}
                        clearUploadServer(ws, wsKey, identifier, upload);
                    }
                } catch (Exception ex) {}
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.e("MainActivity", "Ping failed: " + e.getMessage());
            setLastError("connection error: " + e.getMessage());
        }
    }

    private void clearConfServer(String ws, String wsKey, String identifier) {
        try {
            JSONObject rObj = new JSONObject();
            rObj.put("name", identifier);
            rObj.put("time", System.currentTimeMillis());
            String rStr = rObj.toString();
            String sStr = getMd5(rStr);
            String kStr = getMd5(wsKey + sStr);
            String params = "a=Showtime/ClearConf&u=system&r=" + Uri.encode(rStr) + "&s=" + sStr + "&k=" + kStr;
            
            URL url = new URL(ws + "ws/");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.getOutputStream().write(params.getBytes("UTF-8"));
            conn.getResponseCode();
        } catch (Exception e) {}
    }

    private void clearRemoveServer(String ws, String wsKey, String identifier, String movieName) {
        try {
            JSONObject rObj = new JSONObject();
            rObj.put("name", identifier);
            rObj.put("movie", movieName);
            rObj.put("time", System.currentTimeMillis());
            String rStr = rObj.toString();
            String sStr = getMd5(rStr);
            String kStr = getMd5(wsKey + sStr);
            String params = "a=Showtime/ClearRemove&u=system&r=" + Uri.encode(rStr) + "&s=" + sStr + "&k=" + kStr;
            
            URL url = new URL(ws + "ws/");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.getOutputStream().write(params.getBytes("UTF-8"));
            conn.getResponseCode();
        } catch (Exception e) {}
    }

    private void clearUploadServer(String ws, String wsKey, String identifier, String movieName) {
        try {
            JSONObject rObj = new JSONObject();
            rObj.put("name", identifier);
            rObj.put("movie", movieName);
            rObj.put("time", System.currentTimeMillis());
            String rStr = rObj.toString();
            String sStr = getMd5(rStr);
            String kStr = getMd5(wsKey + sStr);
            String params = "a=Showtime/ClearUpload&u=system&r=" + Uri.encode(rStr) + "&s=" + sStr + "&k=" + kStr;
            
            URL url = new URL(ws + "ws/");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.getOutputStream().write(params.getBytes("UTF-8"));
            conn.getResponseCode();
        } catch (Exception e) {}
    }

    private void copyAssetsToInternal(String path, File outPath) {
        try {
            String[] assets = getAssets().list(path);
            if (assets == null) return;
            
            if (assets.length == 0) {
                copyFile(path, outPath);
            } else {
                File dir = new File(outPath, path);
                if (!dir.exists()) dir.mkdirs();
                for (String asset : assets) {
                    copyAssetsToInternal(path + "/" + asset, outPath);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private void copyFile(String assetFilePath, File outPath) throws IOException {
        InputStream in = getAssets().open(assetFilePath);
        File outFile = new File(outPath, assetFilePath);
        outFile.getParentFile().mkdirs();
        OutputStream out = new FileOutputStream(outFile);
        byte[] buffer = new byte[1024];
        int read;
        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }
        in.close();
        out.flush();
        out.close();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (localServer != null) {
            localServer.stop();
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus && isKiosk) {
            hideSystemUI();
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (requestCode == REQUEST_SELECT_FILE) {
            if (uploadMessage == null) return;
            uploadMessage.onReceiveValue(WebChromeClient.FileChooserParams.parseResult(resultCode, intent));
            uploadMessage = null;
        } else {
            super.onActivityResult(requestCode, resultCode, intent);
        }
    }

    private void deleteRecursively(File f) {
        if (f.isDirectory()) {
            File[] files = f.listFiles();
            if (files != null) {
                for (File c : files) {
                    deleteRecursively(c);
                }
            }
        }
        f.delete();
    }
    
    private void setKioskMode(boolean kiosk) {
        isKiosk = kiosk;
        if (kiosk) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            hideSystemUI();
            try {
                startLockTask();
            } catch (Exception e) {}
        } else {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            View decorView = getWindow().getDecorView();
            decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_VISIBLE);
            try {
                stopLockTask();
            } catch (Exception e) {}
        }
    }

    private void hideSystemUI() {
        View decorView = getWindow().getDecorView();
        decorView.setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_FULLSCREEN);
    }
}
