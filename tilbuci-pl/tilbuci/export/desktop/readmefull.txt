TILBUCI DESKTOP APP

This folder contains the desktop app project you created from your TilBuci movie. To get started, you'll need to install Node.js on your computer. This is easy: go to https://nodejs.org/ and follow the instructions for your operating system.

Next, prepare your Electron JS project. Open a terminal window in your content folder and run these commands.

This will install the latest version of Electrion JS:
> npm install --save-dev electron


These will install the dependencies needed to export the app:
> npm install --save-dev @electron-forge/cli
> npx electron-forge import

Now you're ready to create your app. To start, test it using this command:
> npm run start

If you want to create an executable for your operating system, use this command:
> npm run package

To create an installer, use this command:
> npm run make

Like any app built using Electron Js, you can enhance yours in a variety of ways, especially by adding custom icons. You can find more information here:
https://www.electronforge.io/guides/create-and-add-icons

To update the content of your app, go back to the "Exchange > Export for desktop" menu in TilBuci and generate only the update file.