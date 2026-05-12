/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
const { app, BrowserWindow, ipcMain, shell, Menu } = require('electron');
const path = require('path');
const { exec } = require('child_process');
const fs = require('node:fs');
const serverPath = 'resources/app/';

function createWindow() {
  const win = new BrowserWindow({
    width: 800,
    height: 600,
	menu: null, 
	icon: 'images/tilbuciIcon.png',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true, 
	  nodeIntegration: false
    }, 
	resizable: false,
	maximizable: false
  });
  win.setMenu(null);
  win.loadFile('index.html');
}

ipcMain.handle('close', (event) => {
	app.quit();
});

ipcMain.handle('open-browser', (event, url) => {
	shell.openExternal(url);
});

ipcMain.handle('open-window', (event, url) => {
	const newWin = new BrowserWindow({
        width: 1440,
        height: 810,
        autoHideMenuBar: true, 
		icon: 'images/tilbuciIcon.png'
    });
	newWin.loadURL(url);
	newWin.setMenu(null);
});

ipcMain.handle('open-folder', async (event, folder) => {
  return new Promise((resolve, reject) => {
	  let folderpath = serverPath + 'server/public/' + folder;
	  if (process.platform == 'darwin') {
		let executablePath = app.getPath('exe');
		let executableDir = path.dirname(executablePath);
		folderpath = executableDir + '/../Resources/app/server/public/' + folder;
		exec('open "' + folderpath + '"', (error, stdout, stderr) => {
			if (error) return reject(stderr);
			resolve(stdout);
		});
	  } else if (process.platform == 'linux') {
		exec('open "' + folderpath + '"', (error, stdout, stderr) => {
			if (error) return reject(stderr);
			resolve(stdout);
		});
	  } else {
		folderpath = folderpath.split('/').join('\\');
		exec('start ""  "' + folderpath + '"', (error, stdout, stderr) => {
			if (error) return reject(stderr);
			resolve(stdout);
		});
	  }
  });
});

app.whenReady().then(() => {
	Menu.setApplicationMenu(null);
	createWindow();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('ready', () => {
	if (process.platform == 'darwin') {
		let executablePath = app.getPath('exe');
		let executableDir = path.dirname(executablePath);
		process.chdir(executableDir);
		exec('./phpmac -S localhost:51804 -t ../Resources/app/server/public/', (error, stdout, stderr) => {
			if (error) {
			  console.error(`PHP server start error: ${error.message}`);
			  return;
			}
			if (stderr) {
			  console.error(`Stderr: ${stderr}`);
			  return;
			}
			console.log(`Result: ${stdout}`);
		});
	} else if (process.platform == 'linux') {
		exec('./phplinux -S localhost:51804 -t '+serverPath+'server/public/', (error, stdout, stderr) => {
		  if (error) {
			console.error(`PHP server start error: ${error.message}`);
			return;
		  }
		  if (stderr) {
			console.error(`Stderr: ${stderr}`);
			return;
		  }
		  console.log(`Result: ${stdout}`);
		});
	} else {
		exec('phpwindows.exe -S localhost:51804 -t '+serverPath+'server/public/', (error, stdout, stderr) => {
		  if (error) {
			console.error(`PHP server start error: ${error.message}`);
			return;
		  }
		  if (stderr) {
			console.error(`Stderr: ${stderr}`);
			return;
		  }
		  console.log(`Result: ${stdout}`);
		});
	}
});

app.on('quit', () => {
	if (process.platform == 'darwin') {
		exec('pkill -f "phpmac -S"', (error, stdout, stderr) => {
		  if (error) {
			console.error(`PHP server stop error: ${error.message}`);
			return;
		  }
		  if (stderr) {
			console.error(`Stderr: ${stderr}`);
			return;
		  }
		  console.log(`Result: ${stdout}`);
		});
	} else if (process.platform == 'linux') {
		exec('pkill -f "phplinux -S"', (error, stdout, stderr) => {
		  if (error) {
			console.error(`PHP server stop error: ${error.message}`);
			return;
		  }
		  if (stderr) {
			console.error(`Stderr: ${stderr}`);
			return;
		  }
		  console.log(`Result: ${stdout}`);
		});
	} else {
		exec('taskkill /IM phpwindows.exe /F', (error, stdout, stderr) => {
		  if (error) {
			console.error(`PHP server stop error: ${error.message}`);
			return;
		  }
		  if (stderr) {
			console.error(`Stderr: ${stderr}`);
			return;
		  }
		  console.log(`Result: ${stdout}`);
		});
	}
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) createWindow();
});
