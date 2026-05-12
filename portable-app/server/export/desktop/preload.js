const { contextBridge, ipcRenderer } = require('electron/renderer')

contextBridge.exposeInMainWorld('electronAPI', {
  quitApp: () => ipcRenderer.send('quit-app'), 
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