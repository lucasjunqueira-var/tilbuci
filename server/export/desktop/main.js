const { app, BrowserWindow, ipcMain } = require('electron/main')
const path = require('node:path')

const createWindow = () => {
	const win = new BrowserWindow({
		width: [WIDTH],
		height: [HEIGHT], 
		icon: "favicon.png", 
		[FULLSCREEN]
		[KIOSK]
		spellcheck: false
	})
	[RESIZE]
	win.removeMenu()
	win.loadFile('index.html')
	ipcMain.on('quit-app', (event) => {
		app.quit()
	})
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