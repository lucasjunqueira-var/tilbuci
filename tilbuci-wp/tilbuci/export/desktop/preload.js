const { contextBridge, ipcRenderer } = require('electron/renderer')

contextBridge.exposeInMainWorld('electronAPI', {
  quitApp: async() => {
    return await ipcRenderer.invoke('quit-app');
  },
  kioskEnd: async() => {
    return await ipcRenderer.invoke('kiosk-end');
  },  
  kioskStart: async() => {
    return await ipcRenderer.invoke('kiosk-start');
  },  
  saveFile: async(name, content) => {
    return await ipcRenderer.invoke('save-file', name, content);
  }, 
  readFile: (name) => {
    return ipcRenderer.invoke('read-file', name);
  }, 
  existsFile: (name) => {
    return ipcRenderer.invoke('exists-file', name);
  }
})