PREPARING THE PROJECT

This folder contains the files needed to create TilBuci's portable desktop applications. To use it, first confirm that Node.js is available on your system - if it is not, go to nodejs.org and check the best way to install it on your computer. After that, run the "setup.cmd" script (on Windows) or "setup.sh" (on Linux or macOS) to prepare Electron, which is necessary for the portable app - you only need to do this once.

On Linux systems, confirm that the dpkg and the fakeroot packages are installed on your system before building the final application.


ABOUT PHP

The TilBuci portable application uses the static-php-cli project (https://github.com/crazywhalecc/static-php-cli) for various functionalities. Before testing or building your app, access the download site for this project (https://dl.static-php.dev/static-php-cli/windows/spc-max/ for Windows or https://dl.static-php.dev/static-php-cli/bulk/ for Linux and macOS) and download the "cli" version appropriate for your system. TilBuci was tested using the latest PHP version 8.2. Save the downloaded file from this website in this folder with the name "phpwindows.exe", "phplinux" or "phpmac", depending on your system. On Linux and macOS systems, remember to mark the PHP file as executable before proceeding.

TESTING AND BUILDING THE APP

To test the application, simply run the "test.cmd" (or "test.sh") script, and to generate the final app, run "build-windows.cmd", "build-linux.sh" or "build-macos.sh" according to your system. The app will be generated in a version for the system where the build command was executed.