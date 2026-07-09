/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const AdmZip = require('adm-zip');
const crypto = require('crypto');
const { SerialPort } = require('serialport');
const { ReadlineParser } = require('@serialport/parser-readline');

let mainWindow;
let server;
let activeSerialPort = null;
let appConfig = {
    movie: "",
    ws: "",
    wsKey: "",
    accesskey: "AAAAA",
    identifier: "",
    autoStart: false,
    hideCursor: false,
    lastError: null
};

let pingInterval = null;

const configPath = path.join(__dirname, 'config.json');
const tilbuciDir = path.join(__dirname, 'tilbuci');
const moviesDir = path.join(tilbuciDir, 'movie');

const ENCRYPTION_KEY = crypto.scryptSync('tilbuci-showtime-secret-key-2023', 'salt', 32);
const IV_LENGTH = 16;

// Encrypt text securely using aes-256-cbc and a pre-defined key
function encrypt(text) {
    if (!text) return text;
    if (text.includes(':') && text.split(':')[0].length === 32) return text; // Already encrypted
    try {
        let iv = crypto.randomBytes(IV_LENGTH);
        let cipher = crypto.createCipheriv('aes-256-cbc', ENCRYPTION_KEY, iv);
        let encrypted = cipher.update(text, 'utf8', 'hex');
        encrypted += cipher.final('hex');
        return iv.toString('hex') + ':' + encrypted;
    } catch (e) {
        return text;
    }
}

// Decrypt aes-256-cbc encrypted string using a pre-defined key
function decrypt(text) {
    if (!text || !text.includes(':')) return text;
    try {
        let textParts = text.split(':');
        let iv = Buffer.from(textParts.shift(), 'hex');
        let encryptedText = textParts.join(':');
        let decipher = crypto.createDecipheriv('aes-256-cbc', ENCRYPTION_KEY, iv);
        let decrypted = decipher.update(encryptedText, 'hex', 'utf8');
        decrypted += decipher.final('utf8');
        return decrypted;
    } catch (e) {
        return text;
    }
}

if (fs.existsSync(configPath)) {
    try {
        appConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
        if (appConfig.wsKey) {
            appConfig.wsKey = decrypt(appConfig.wsKey);
        }
    } catch (e) {
        // Ignored
    }
} else {
    saveConfig();
}

// Set up the serial port connection using the configuration settings
function setupSerialPort() {
    if (activeSerialPort) {
        if (activeSerialPort.isOpen) activeSerialPort.close();
        activeSerialPort = null;
    }
    
    if (appConfig.serialPort && appConfig.serialBaud) {
        try {
            activeSerialPort = new SerialPort({
                path: appConfig.serialPort,
                baudRate: parseInt(appConfig.serialBaud)
            });
            
            const parser = activeSerialPort.pipe(new ReadlineParser({ delimiter: '\n' }));
            parser.on('data', (data) => {
                const text = data.trim();
                if (mainWindow && !mainWindow.isDestroyed()) {
                    try {
                        const jsonStr = JSON.stringify(text); // Escape string properly for eval
                        mainWindow.webContents.executeJavaScript(`if(typeof tilbuci_runaction === 'function') tilbuci_runaction(${jsonStr});`);
                    } catch(e) {}
                }
            });
            
            activeSerialPort.on('error', function(err) {
                console.error("Serial port error:", err.message);
            });
            
        } catch (e) {
            console.error("Failed to initialize serial port:", e.message);
        }
    }
}

if (!appConfig.identifier) {
    const now = new Date();
    const pad = n => n.toString().padStart(2, '0');
    const dateStr = `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())} ${pad(now.getHours())}:${pad(now.getMinutes())}`;
    const randomChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let randomStr = '';
    for (let i = 0; i < 8; i++) {
        randomStr += randomChars.charAt(Math.floor(Math.random() * randomChars.length));
    }
    appConfig.identifier = `${dateStr} ${randomStr}`;
    saveConfig();
}

// Save the application configuration settings to disk
function saveConfig() {
    let saveAppConfig = { ...appConfig };
    delete saveAppConfig.lastError;
    saveAppConfig.wsKey = encrypt(appConfig.wsKey);
    fs.writeFileSync(configPath, JSON.stringify(saveAppConfig));
}

// Calculate and return the MD5 hash of a given string
function md5(str) {
    return crypto.createHash('md5').update(str).digest('hex').toLowerCase();
}

// Ping the configured remote server and process synchronization tasks
async function pingServer() {
    if (!appConfig.ws || !appConfig.wsKey || appConfig.wsKey.length < 5) {
        appConfig.lastError = null;
        return;
    }
    
    try {
        let moviesList = "";
        if (fs.existsSync(moviesDir)) {
            const dirs = fs.readdirSync(moviesDir, { withFileTypes: true })
                .filter(dirent => dirent.isDirectory() && dirent.name.endsWith('.movie'))
                .map(dirent => dirent.name.replace('.movie', ''));
            moviesList = dirs.join(',');
        }
        
        let saveAppConfig = { ...appConfig };
        delete saveAppConfig.lastError;
        saveAppConfig.wsKey = encrypt(appConfig.wsKey);
        
        let rObj = {
            name: appConfig.identifier || '',
            config: JSON.stringify(saveAppConfig),
            movies: moviesList, 
            type: 'desktop'
        };
        let rStr = JSON.stringify(rObj);
        let sStr = md5(rStr);
        let kStr = md5(appConfig.wsKey + sStr);
        
        const params = new URLSearchParams();
        params.append('a', 'Showtime/Ping');
        params.append('u', 'system');
        params.append('r', rStr);
        params.append('s', sStr);
        params.append('k', kStr);
        
        let url = appConfig.ws;
        if (!url.endsWith('/')) url += '/';
        url += 'ws/';
        
        const response = await fetch(url, {
            method: 'POST',
            body: params,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });
        
        const data = await response.json();
        
        if (data && data.e !== undefined) {
            appConfig.lastError = data.e;
        } else {
            appConfig.lastError = "unknown format";
        }
        
        if (data && data.conf && typeof data.conf === 'object' && Object.keys(data.conf).length > 0) {
            let changed = false;
            
            if (data.conf.movie !== undefined && data.conf.movie !== appConfig.movie) {
                appConfig.movie = data.conf.movie;
                changed = true;
            }
            if (data.conf.accesskey !== undefined && data.conf.accesskey !== appConfig.accesskey) {
                appConfig.accesskey = data.conf.accesskey;
                changed = true;
            }
            if (data.conf.identifier !== undefined && data.conf.identifier !== appConfig.identifier) {
                appConfig.identifier = data.conf.identifier;
                changed = true;
            }
            if (data.conf.autoStart !== undefined && !!data.conf.autoStart !== appConfig.autoStart) {
                appConfig.autoStart = !!data.conf.autoStart;
                app.setLoginItemSettings({
                    openAtLogin: appConfig.autoStart,
                    path: app.getPath('exe')
                });
                changed = true;
            }
            if (data.conf.hideCursor !== undefined && !!data.conf.hideCursor !== appConfig.hideCursor) {
                appConfig.hideCursor = !!data.conf.hideCursor;
                changed = true;
            }
            if (data.conf.serialPort !== undefined && data.conf.serialPort !== appConfig.serialPort) {
                appConfig.serialPort = data.conf.serialPort;
                changed = true;
            }
            if (data.conf.serialBaud !== undefined && data.conf.serialBaud !== appConfig.serialBaud) {
                appConfig.serialBaud = data.conf.serialBaud;
                changed = true;
            }
            
            if (changed) {
                saveConfig();
                generateIndexHtml();
            }
            
            await clearConfServer();
            
            if (changed) {
                app.relaunch();
                app.exit(0);
            }
        }
        
        if (data && typeof data.remove === 'string' && data.remove.trim() !== '') {
            const removeMovie = data.remove.trim();
            if (removeMovie !== appConfig.movie) {
                const targetDir = path.join(moviesDir, removeMovie + '.movie');
                if (fs.existsSync(targetDir)) {
                    fs.rmSync(targetDir, { recursive: true, force: true });
                }
            }
            await clearRemoveServer(removeMovie);
        }
        
        if (data && typeof data.upload === 'string' && data.upload.trim() !== '') {
            const uploadMovie = data.upload.trim();
            let downloadSuccess = false;
            try {
                let downloadUrl = appConfig.ws;
                if (!downloadUrl.endsWith('/')) downloadUrl += '/';
                downloadUrl += 'download/?a=download&file=export&movie=' + encodeURIComponent(uploadMovie);
                
                const dlResponse = await fetch(downloadUrl);
                if (dlResponse.ok) {
                    const arrayBuffer = await dlResponse.arrayBuffer();
                    const tempZipPath = path.join(__dirname, 'temp', uploadMovie + '.zip');
                    if (!fs.existsSync(path.join(__dirname, 'temp'))) {
                        fs.mkdirSync(path.join(__dirname, 'temp'), { recursive: true });
                    }
                    fs.writeFileSync(tempZipPath, Buffer.from(arrayBuffer));
                    
                    const targetDir = path.join(moviesDir, uploadMovie + '.movie');
                    const zip = new AdmZip(tempZipPath);
                    zip.extractAllTo(targetDir, true);
                    fs.unlinkSync(tempZipPath);
                    downloadSuccess = true;
                }
            } catch (e) {
                // Ignore download error
            }
            
            await clearUploadServer(uploadMovie);
            
            if (downloadSuccess && uploadMovie === appConfig.movie) {
                app.relaunch();
                app.exit(0);
            }
        }
    } catch (e) {
        appConfig.lastError = "connection error";
    }
}

// Send a CLEARREMOVE REST signal to the remote server
async function clearRemoveServer(movieName) {
    if (!appConfig.ws || !appConfig.wsKey || appConfig.wsKey.length < 5) return;
    
    try {
        let rObj = {
            name: appConfig.identifier || '',
            movie: movieName,
            time: Date.now()
        };
        let rStr = JSON.stringify(rObj);
        let sStr = md5(rStr);
        let kStr = md5(appConfig.wsKey + sStr);
        
        const params = new URLSearchParams();
        params.append('a', 'Showtime/ClearRemove');
        params.append('u', 'system');
        params.append('r', rStr);
        params.append('s', sStr);
        params.append('k', kStr);
        
        let url = appConfig.ws;
        if (!url.endsWith('/')) url += '/';
        url += 'ws/';
        
        await fetch(url, {
            method: 'POST',
            body: params,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });
    } catch (e) {
    }
}

// Send a CLEARUPLOAD REST signal to the remote server
async function clearUploadServer(movieName) {
    if (!appConfig.ws || !appConfig.wsKey || appConfig.wsKey.length < 5) return;
    
    try {
        let rObj = {
            name: appConfig.identifier || '',
            movie: movieName,
            time: Date.now()
        };
        let rStr = JSON.stringify(rObj);
        let sStr = md5(rStr);
        let kStr = md5(appConfig.wsKey + sStr);
        
        const params = new URLSearchParams();
        params.append('a', 'Showtime/ClearUpload');
        params.append('u', 'system');
        params.append('r', rStr);
        params.append('s', sStr);
        params.append('k', kStr);
        
        let url = appConfig.ws;
        if (!url.endsWith('/')) url += '/';
        url += 'ws/';
        
        await fetch(url, {
            method: 'POST',
            body: params,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });
    } catch (e) {
    }
}

// Send a CLEARCONF REST signal to the remote server
async function clearConfServer() {
    if (!appConfig.ws || !appConfig.wsKey || appConfig.wsKey.length < 5) return;
    
    try {
        let rObj = {
            name: appConfig.identifier || '',
            time: Date.now()
        };
        let rStr = JSON.stringify(rObj);
        let sStr = md5(rStr);
        let kStr = md5(appConfig.wsKey + sStr);
        
        const params = new URLSearchParams();
        params.append('a', 'Showtime/ClearConf');
        params.append('u', 'system');
        params.append('r', rStr);
        params.append('s', sStr);
        params.append('k', kStr);
        
        let url = appConfig.ws;
        if (!url.endsWith('/')) url += '/';
        url += 'ws/';
        
        await fetch(url, {
            method: 'POST',
            body: params,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });
        
    } catch (e) {
        console.error("ClearConf error:", e);
    }
}

// Generate index.html dynamically by replacing placeholders in tilbuci.html
function generateIndexHtml() {
    const templatePath = path.join(tilbuciDir, 'tilbuci.html');
    const indexPath = path.join(tilbuciDir, 'index.html');
    
    if (fs.existsSync(templatePath)) {
        let content = fs.readFileSync(templatePath, 'utf8');
        content = content.replace(/\[MOVIE\]/g, appConfig.movie || '');
        content = content.replace(/\[WS\]/g, appConfig.ws || '');
        
        // Inject ABCD areas and TBShowtime_Event
        const injectScript = `
        <script>
            function TBShowtime_Event(movie, eventName, jsonStr) {
                fetch('http://localhost:8080/api/event', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ movie: movie, event: eventName, json: jsonStr })
                });
            }
            function TBShowtime_Hardware(msg) {
                fetch('http://localhost:8080/api/hardware', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: msg })
                });
            }
            let access = "";
            let accesskey = "${appConfig.accesskey}";
            function addAccess(char) {
                access += char;
                if (access.length > 5) access = access.substring(access.length - 5);
                if (access === accesskey) {
                    window.location.href = "http://localhost:8080/config/config.html";
                }
            }
        </script>
        <style>
            ${appConfig.hideCursor ? '* { cursor: none !important; }' : ''}
            .abcd-area { position: fixed; width: 5%; height: 5%; z-index: 999999; cursor: pointer; }
            #area-A { top: 0; left: 0; }
            #area-B { top: 0; right: 0; }
            #area-C { bottom: 0; left: 0; }
            #area-D { bottom: 0; right: 0; }
        </style>
        <div id="area-A" class="abcd-area" onclick="addAccess('A')"></div>
        <div id="area-B" class="abcd-area" onclick="addAccess('B')"></div>
        <div id="area-C" class="abcd-area" onclick="addAccess('C')"></div>
        <div id="area-D" class="abcd-area" onclick="addAccess('D')"></div>
        `;
        
        content = content.replace('</body>', injectScript + '\n</body>');
        fs.writeFileSync(indexPath, content);
    }
}

// Initialize and configure the local Express server
function startServer() {
    const expressApp = express();
    expressApp.use(cors());
    expressApp.use(express.json());
    
    // Serve tilbuci content at root
    expressApp.use('/', express.static(tilbuciDir, {
        etag: false,
        maxAge: 0,
        setHeaders: function (res, path) {
            res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate");
            res.setHeader("Pragma", "no-cache");
            res.setHeader("Expires", "0");
            res.setHeader("Surrogate-Control", "no-store");
        }
    }));
    // Serve config at /config
    expressApp.use('/config', express.static(path.join(__dirname, 'config'), {
        etag: false,
        maxAge: 0,
        setHeaders: function (res, path) {
            res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate");
            res.setHeader("Pragma", "no-cache");
            res.setHeader("Expires", "0");
            res.setHeader("Surrogate-Control", "no-store");
        }
    }));

    const upload = multer({ dest: path.join(__dirname, 'temp') });

    expressApp.get('/api/config', (req, res) => {
        res.json(appConfig);
    });

    expressApp.post('/api/config', (req, res) => {
        appConfig.movie = req.body.movie !== undefined ? req.body.movie : appConfig.movie;
        appConfig.ws = req.body.ws !== undefined ? req.body.ws : appConfig.ws;
        appConfig.wsKey = req.body.wsKey !== undefined ? req.body.wsKey : appConfig.wsKey;
        appConfig.accesskey = req.body.accesskey || appConfig.accesskey;
        appConfig.identifier = req.body.identifier !== undefined ? req.body.identifier : appConfig.identifier;
        appConfig.autoStart = req.body.autoStart !== undefined ? req.body.autoStart : appConfig.autoStart;
        appConfig.hideCursor = req.body.hideCursor !== undefined ? req.body.hideCursor : appConfig.hideCursor;
        appConfig.serialPort = req.body.serialPort !== undefined ? req.body.serialPort : appConfig.serialPort;
        appConfig.serialBaud = req.body.serialBaud !== undefined ? req.body.serialBaud : appConfig.serialBaud;
        
        app.setLoginItemSettings({
            openAtLogin: appConfig.autoStart,
            path: app.getPath('exe')
        });

        saveConfig();
        generateIndexHtml();
        setupSerialPort();
        
        pingServer();
        if (pingInterval) clearInterval(pingInterval);
        if (appConfig.ws && appConfig.wsKey && appConfig.wsKey.length >= 5) {
            pingInterval = setInterval(pingServer, 15 * 60 * 1000);
        }
        
        res.json({ success: true });
    });

    expressApp.get('/api/movies', (req, res) => {
        if (!fs.existsSync(moviesDir)) fs.mkdirSync(moviesDir, { recursive: true });
        const dirs = fs.readdirSync(moviesDir, { withFileTypes: true })
            .filter(dirent => dirent.isDirectory() && dirent.name.endsWith('.movie'))
            .map(dirent => dirent.name.replace('.movie', ''));
        res.json(dirs);
    });

    expressApp.post('/api/upload', upload.single('file'), (req, res) => {
        if (!req.file) return res.status(400).json({ error: 'No file' });
        
        const zipPath = req.file.path;
        const originalName = req.file.originalname;
        const movieName = originalName.replace('.zip', '');
        const targetDir = path.join(moviesDir, movieName + '.movie');

        try {
            const zip = new AdmZip(zipPath);
            zip.extractAllTo(targetDir, true);
            fs.unlinkSync(zipPath);
            res.json({ success: true, movie: movieName });
        } catch (e) {
            res.status(500).json({ error: 'Extract error' });
        }
    });

    expressApp.post('/api/delete', (req, res) => {
        const { movie } = req.body;
        if (movie) {
            const targetDir = path.join(moviesDir, movie + '.movie');
            if (fs.existsSync(targetDir)) {
                fs.rmSync(targetDir, { recursive: true, force: true });
            }
            if (appConfig.movie === movie) {
                appConfig.movie = "";
                saveConfig();
                generateIndexHtml();
            }
        }
        res.json({ success: true });
    });

    expressApp.get('/api/serialports', async (req, res) => {
        try {
            const { SerialPort } = require('serialport');
            const ports = await SerialPort.list();
            res.json(ports.map(p => p.path));
        } catch (e) {
            console.error("Error listing serial ports:", e);
            res.json([]);
        }
    });

    expressApp.post('/api/event', (req, res) => {
        const { movie, event, json } = req.body;
        if (movie && event && json) {
            try {
                const docsDir = app.getPath('documents');
                const tbDir = path.join(docsDir, 'TBShowtime');
                if (!fs.existsSync(tbDir)) fs.mkdirSync(tbDir, { recursive: true });
                
                const movieDir = path.join(tbDir, movie);
                if (!fs.existsSync(movieDir)) fs.mkdirSync(movieDir, { recursive: true });
                
                const now = new Date();
                const pad = n => n.toString().padStart(2, '0');
                const dateStr = `${now.getFullYear()}${pad(now.getMonth()+1)}${pad(now.getDate())}${pad(now.getHours())}${pad(now.getMinutes())}${pad(now.getSeconds())}`;
                
                const filePath = path.join(movieDir, `${event}-${dateStr}.json`);
                fs.writeFileSync(filePath, json, 'utf8');
            } catch (e) {
                console.error("Error saving event:", e);
            }
        }
        res.json({ success: true });
    });

    expressApp.post('/api/hardware', (req, res) => {
        const { message } = req.body;
        if (activeSerialPort && activeSerialPort.isOpen) {
            activeSerialPort.write(message + '\n');
        }
        res.json({ success: true });
    });

    server = expressApp.listen(8080, () => {
        // Server started silently
    });
}

// Create and initialize the main Electron window
function createWindow() {
    generateIndexHtml();
    setupSerialPort();
    startServer();
    
    pingServer();
    if (appConfig.ws && appConfig.wsKey && appConfig.wsKey.length >= 5) {
        pingInterval = setInterval(pingServer, 15 * 60 * 1000);
    }

    let initialKiosk = (appConfig.movie && appConfig.movie.trim() !== '');

    mainWindow = new BrowserWindow({
        width: 1280,
        height: 720,
        icon: 'images/tilbuciIcon.png',
        kiosk: initialKiosk,
        alwaysOnTop: initialKiosk,
        fullscreen: initialKiosk,
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true
        }
    });

    mainWindow.setMenuBarVisibility(false);
    
    mainWindow.webContents.on('did-navigate', (event, url) => {
        if (url.includes('config.html')) {
            mainWindow.setKiosk(false);
            mainWindow.setAlwaysOnTop(false);
            mainWindow.setFullScreen(false);
            mainWindow.unmaximize();
            mainWindow.setSize(1280, 720);
            mainWindow.center();
        } else {
            mainWindow.setFullScreen(true);
            mainWindow.setKiosk(true);
            mainWindow.setAlwaysOnTop(true);
        }
    });
    
    mainWindow.on('blur', () => {
        if (mainWindow && mainWindow.isKiosk()) {
            mainWindow.focus();
        }
    });

    if (appConfig.movie && appConfig.movie.trim() !== '') {
        mainWindow.loadURL('http://localhost:8080/index.html');
    } else {
        mainWindow.loadURL('http://localhost:8080/config/config.html');
    }

    mainWindow.once('ready-to-show', () => {
        mainWindow.webContents.session.clearCache().then(() => {
            if (initialKiosk) {
                mainWindow.show();
                mainWindow.setAlwaysOnTop(true, 'screen-saver');
                mainWindow.focus();
            }
        });
    });

    mainWindow.on('closed', function () {
        mainWindow = null;
    });
}

app.whenReady().then(createWindow);

app.on('window-all-closed', function () {
    if (server) {
        server.close();
    }
    if (process.platform !== 'darwin') app.quit();
});

app.on('activate', function () {
    if (mainWindow === null) createWindow();
});

// apply autoStart initially
if (appConfig.autoStart) {
    app.setLoginItemSettings({
        openAtLogin: true,
        path: app.getPath('exe')
    });
}

