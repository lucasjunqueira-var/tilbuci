/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
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
import android.content.pm.PackageManager;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

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

import com.hoho.android.usbserial.driver.UsbSerialPort;
import com.hoho.android.usbserial.driver.UsbSerialDriver;
import com.hoho.android.usbserial.driver.UsbSerialProber;
import com.hoho.android.usbserial.util.SerialInputOutputManager;
import android.hardware.usb.UsbManager;
import android.hardware.usb.UsbDeviceConnection;
import android.content.Context;
import java.util.List;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothSocket;
import java.util.UUID;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.IntentFilter;

public class MainActivity extends AppCompatActivity implements SerialInputOutputManager.Listener {

    private UsbSerialPort usbSerialPort;
    private SerialInputOutputManager usbIoManager;
    private BluetoothSocket btSocket;
    private Thread btReadThread;
    
    private boolean isKiosk = false;

    private WebView webView;
    private LocalServer localServer;
    private static final int PORT = 8080;
    
    private ValueCallback<Uri[]> uploadMessage;
    public static final int REQUEST_SELECT_FILE = 100;
    private Timer pingTimer;

    private static final String ACTION_USB_PERMISSION = "com.tilbuci.showtime.USB_PERMISSION";
    
    private final BroadcastReceiver usbReceiver = new BroadcastReceiver() {
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (ACTION_USB_PERMISSION.equals(action)) {
                synchronized (this) {
                    if (intent.getBooleanExtra(UsbManager.EXTRA_PERMISSION_GRANTED, false)) {
                        // Retry setup
                        String sp = "";
                        String sb = "9600";
                        try {
                            File configFile = new File(getFilesDir(), "config.json");
                            if (configFile.exists()) {
                                InputStream is = new FileInputStream(configFile);
                                byte[] buf = new byte[is.available()];
                                is.read(buf);
                                is.close();
                                JSONObject config = new JSONObject(new String(buf, "UTF-8"));
                                sp = config.optString("serialPort", "");
                                sb = config.optString("serialBaud", "9600");
                            }
                        } catch (Exception e) {}
                        setupSerialPort(sp, sb);
                    }
                }
            }
        }
    };

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        IntentFilter filter = new IntentFilter(ACTION_USB_PERMISSION);
        if (android.os.Build.VERSION.SDK_INT >= 33) {
            registerReceiver(usbReceiver, filter, android.content.Context.RECEIVER_NOT_EXPORTED);
        } else {
            registerReceiver(usbReceiver, filter);
        }
        
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.WRITE_EXTERNAL_STORAGE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.WRITE_EXTERNAL_STORAGE}, 112);
        }

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
        String accesskey = "AAAAA";
        
        if (configFile.exists()) {
            try {
                InputStream is = new FileInputStream(configFile);
                byte[] buf = new byte[is.available()];
                is.read(buf);
                is.close();
                JSONObject config = new JSONObject(new String(buf, "UTF-8"));
                movie = config.optString("movie", "");
                ws = config.optString("ws", "");
                accesskey = config.optString("accesskey", "AAAAA");
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
                        "    function TBShowtime_Event(movie, eventName, jsonStr) {\n" +
                        "        fetch('http://localhost:8080/api/event', {\n" +
                        "            method: 'POST',\n" +
                        "            headers: { 'Content-Type': 'application/json' },\n" +
                        "            body: JSON.stringify({ movie: movie, event: eventName, json: jsonStr })\n" +
                        "        });\n" +
                        "    }\n" +
                        "    function TBShowtime_Hardware(msg) {\n" +
                        "        fetch('http://localhost:8080/api/hardware', {\n" +
                        "            method: 'POST',\n" +
                        "            headers: { 'Content-Type': 'application/json' },\n" +
                        "            body: JSON.stringify({ message: msg })\n" +
                        "        });\n" +
                        "    }\n" +
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
            
            // Connect Serial
            String serialPort = "";
            String serialBaud = "9600";
            if (configFile.exists()) {
                try {
                    InputStream is = new FileInputStream(configFile);
                    byte[] buf = new byte[is.available()];
                    is.read(buf);
                    is.close();
                    JSONObject config = new JSONObject(new String(buf, "UTF-8"));
                    serialPort = config.optString("serialPort", "");
                    serialBaud = config.optString("serialBaud", "9600");
                } catch (Exception e) {}
            }
            setupSerialPort(serialPort, serialBaud);
            
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

    // Initialize a periodic timer to ping the remote server every 15 minutes
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

    // Generate an MD5 hash string for cryptographic communication checks
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

    // Update the 'lastError' property in config.json to reflect connection status
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

    // Core routine to ping the master server and process incoming commands (conf, remove, upload)
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
                            boolean changed = false;
                            
                            JSONObject localConfig = new JSONObject();
                            if (configFile.exists()) {
                                InputStream is2 = new FileInputStream(configFile);
                                byte[] buf2 = new byte[is2.available()];
                                is2.read(buf2);
                                is2.close();
                                localConfig = new JSONObject(new String(buf2, "UTF-8"));
                            }
                            
                            if (conf.has("movie") && !conf.getString("movie").equals(localConfig.optString("movie", ""))) {
                                localConfig.put("movie", conf.getString("movie"));
                                changed = true;
                            }
                            if (conf.has("accesskey") && !conf.getString("accesskey").equals(localConfig.optString("accesskey", "AAAAA"))) {
                                localConfig.put("accesskey", conf.getString("accesskey"));
                                changed = true;
                            }
                            if (conf.has("identifier") && !conf.getString("identifier").equals(localConfig.optString("identifier", ""))) {
                                localConfig.put("identifier", conf.getString("identifier"));
                                changed = true;
                            }
                            if (conf.has("autoStart") && conf.getBoolean("autoStart") != localConfig.optBoolean("autoStart", false)) {
                                localConfig.put("autoStart", conf.getBoolean("autoStart"));
                                changed = true;
                            }
                            if (conf.has("serialPort") && !conf.getString("serialPort").equals(localConfig.optString("serialPort", ""))) {
                                localConfig.put("serialPort", conf.getString("serialPort"));
                                changed = true;
                            }
                            if (conf.has("serialBaud") && !conf.getString("serialBaud").equals(localConfig.optString("serialBaud", ""))) {
                                localConfig.put("serialBaud", conf.getString("serialBaud"));
                                changed = true;
                            }
                            
                            if (changed) {
                                FileOutputStream fos = new FileOutputStream(configFile);
                                fos.write(localConfig.toString().getBytes("UTF-8"));
                                fos.close();
                                
                                // Restart app logic if we want, or just wait for next tick
                            }
                            
                            // save new conf and then:
                            clearConfServer(ws, wsKey, identifier);
                            
                            if (changed) {
                                runOnUiThread(new Runnable() {
                                    @Override
                                    public void run() {
                                        recreate();
                                    }
                                });
                            }
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

    // Send a CLEARCONF REST signal to the remote server to acknowledge configuration update
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

    // Send a CLEARREMOVE REST signal to the remote server to acknowledge movie deletion
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

    // Send a CLEARUPLOAD REST signal to the remote server to acknowledge movie download
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

    // Recursively copy base HTML and JS assets from APK to internal storage
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

    // Copy a single asset file from APK to internal storage
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

    // Recursively delete files and folders
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
    
    // Toggle full-screen immersive view and Lock Task (pinning)
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

    private StringBuilder serialBuffer = new StringBuilder();

    @Override
    public void onNewData(byte[] data) {
        String chunk = new String(data);
        serialBuffer.append(chunk);
        
        int newlineIndex;
        while ((newlineIndex = serialBuffer.indexOf("\n")) != -1) {
            final String text = serialBuffer.substring(0, newlineIndex).trim();
            serialBuffer.delete(0, newlineIndex + 1);
            
            if (!text.isEmpty()) {
                runOnUiThread(() -> {
                    try {
                        String jsonStr = JSONObject.quote(text);
                        webView.evaluateJavascript("if(typeof tilbuci_runaction === 'function') tilbuci_runaction(" + jsonStr + ");", null);
                    } catch (Exception e) {}
                });
            }
        }
    }

    @Override
    public void onRunError(Exception e) {
        // Disconnected
        if (usbIoManager != null) {
            usbIoManager.stop();
            usbIoManager = null;
        }
    }

    // Initialize USB or Bluetooth SPP connection based on user settings
    private void setupSerialPort(String portName, String baudStr) {
        if (usbIoManager != null) { usbIoManager.stop(); usbIoManager = null; }
        if (usbSerialPort != null) { try { usbSerialPort.close(); } catch(Exception e){} usbSerialPort = null; }
        if (btSocket != null) { try { btSocket.close(); } catch(Exception e){} btSocket = null; }
        if (btReadThread != null) { btReadThread.interrupt(); btReadThread = null; }
        
        if (portName == null || portName.isEmpty()) return;
        
        try {
            int baudRate = 9600;
            if (!baudStr.isEmpty()) baudRate = Integer.parseInt(baudStr);

            if (portName.startsWith("BT:")) {
                // Bluetooth SPP Connection
                String macAddress = portName.substring(3, 20); // BT:XX:XX:XX:XX:XX:XX
                BluetoothAdapter btAdapter = BluetoothAdapter.getDefaultAdapter();
                BluetoothDevice device = btAdapter.getRemoteDevice(macAddress);
                btSocket = device.createRfcommSocketToServiceRecord(UUID.fromString("00001101-0000-1000-8000-00805F9B34FB"));
                btSocket.connect();
                
                btReadThread = new Thread(() -> {
                    try {
                        InputStream in = btSocket.getInputStream();
                        byte[] buffer = new byte[1024];
                        int bytes;
                        while (!Thread.currentThread().isInterrupted() && (bytes = in.read(buffer)) > -1) {
                            byte[] data = new byte[bytes];
                            System.arraycopy(buffer, 0, data, 0, bytes);
                            onNewData(data);
                        }
                    } catch (Exception e) {}
                });
                btReadThread.start();
                
            } else if (portName.startsWith("USB:")) {
                // USB OTG Connection
                UsbManager manager = (UsbManager) getSystemService(Context.USB_SERVICE);
                List<UsbSerialDriver> availableDrivers = UsbSerialProber.getDefaultProber().findAllDrivers(manager);
                if (availableDrivers.isEmpty()) return;
                
                UsbSerialDriver driver = availableDrivers.get(0);
                if (!manager.hasPermission(driver.getDevice())) {
                    PendingIntent permissionIntent = PendingIntent.getBroadcast(this, 0, new Intent(ACTION_USB_PERMISSION), PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
                    manager.requestPermission(driver.getDevice(), permissionIntent);
                    return;
                }
                
                UsbDeviceConnection connection = manager.openDevice(driver.getDevice());
                if (connection == null) return;
                
                usbSerialPort = driver.getPorts().get(0);
                usbSerialPort.open(connection);
                usbSerialPort.setParameters(baudRate, 8, UsbSerialPort.STOPBITS_1, UsbSerialPort.PARITY_NONE);
                usbSerialPort.setDTR(true);
                usbSerialPort.setRTS(true);
                
                usbIoManager = new SerialInputOutputManager(usbSerialPort, this);
                java.util.concurrent.Executors.newSingleThreadExecutor().submit(usbIoManager);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Write text payload to the active serial port (USB or Bluetooth)
    public void sendSerialMessage(String msg) {
        try {
            byte[] data = (msg + "\n").getBytes("UTF-8");
            if (usbSerialPort != null && usbSerialPort.isOpen()) {
                usbSerialPort.write(data, 1000);
            } else if (btSocket != null && btSocket.isConnected()) {
                OutputStream os = btSocket.getOutputStream();
                os.write(data);
                os.flush();
            }
        } catch (Exception e) {}
    }

    // Hide Android status and navigation bars (Immersive Sticky Mode)
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
