/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  openfolder: async (folder) => {
	  try {
		return await ipcRenderer.invoke('open-folder', folder);
	  } catch (err) {
		return `Error: ${err}`;
	  }
  }, 
  openbrowser: (url) => {
	ipcRenderer.invoke('open-browser', url);
  }, 
  openwindow: (url) => {
	ipcRenderer.invoke('open-window', url);
  }, 
  close: () => {
	ipcRenderer.invoke('close');
  }
});
