const { app, BrowserWindow, ipcMain } = require('electron/main')
const path = require('node:path')
const fs = require('fs')

let win;

const createWindow = () => {
	win = new BrowserWindow({
		width: [WIDTH],
		height: [HEIGHT], 
		icon: "favicon.png", 
		[FULLSCREEN]
		[KIOSK]
		spellcheck: false, 
		webPreferences: {
			nodeIntegration: false,
			contextIsolation: true,
			preload: path.join(__dirname, 'preload.js')
		}
	})
	[RESIZE]
	win.removeMenu()
	win.loadFile('index.html')
}

app.whenReady().then(() => {
  createWindow()
  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit()
})

ipcMain.handle('save-file', async (event, name, content) => {
  const userDataPath = app.getPath('userData');
  const filePath = path.join(userDataPath, name);
  try {
    fs.writeFileSync(filePath, content, 'utf-8');
    return (true);
  } catch (err) {
    return (false);
  }
});

ipcMain.handle('read-file', (event, name) => {
  const userDataPath = app.getPath('userData');
  const filePath = path.join(userDataPath, name);
  if (fs.existsSync(filePath)) {
	try {
		const content = fs.readFileSync(filePath, 'utf-8');
		return (content);
	} catch (err) {
		return ("");
	}
  } else {
	return ("");
  }
});

ipcMain.handle('exists-file', async (event, name) => {
  const userDataPath = app.getPath('userData');
  const filePath = path.join(userDataPath, name);
  if (fs.existsSync(filePath)) {
	return (true);
  } else {
	return (false);
  }
});

ipcMain.handle('quit-app', async (event) => {
  app.quit()
});

ipcMain.handle('kiosk-start', async (event) => {
  win.setKiosk(true)
});

ipcMain.handle('kiosk-end', async (event) => {
  win.setKiosk(false)
});