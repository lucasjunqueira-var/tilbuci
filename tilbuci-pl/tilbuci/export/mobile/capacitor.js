/**
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/.
**/

// access plugin from the global object
const { StatusBar } = window.Capacitor.Plugins;
const { NavigationBar } = window.Capacitor.Plugins;
const { Filesystem } = window.Capacitor.Plugins;
const { App } = window.Capacitor.Plugins;

// quitting app
/*const TBB_appQuitCapacitor = async () => {
	App.exitApp();
}*/

// save text file
/*const TBB_Capacitor_Save = async (name, content) => {
  await Filesystem.writeFile({
    path: name,
    data: content,
    directory: 'DATA',
    encoding: 'utf8',
  });
};*/

// load text file
/*const TBB_Capacitor_Load = async (name) => {
  const contents = await Filesystem.readFile({
    path: name,
    directory: 'DATA',
    encoding: 'utf8',
  });
  return(contents.data);
};*/

// check if file exists
/*const TBB_Capacitor_FileExists = async (name) => {
  try {
    await Filesystem.stat({
      path: name, 
	    directory: 'DATA'
	  });
	  return (true);
  } catch (error) {
	  return (false);
  }
};*/

// startup visual adjust
document.addEventListener("DOMContentLoaded", async () => {
  [STATUSBAR]
  [NAVIGATIONBAR]
});