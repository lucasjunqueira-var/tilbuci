@echo off
CALL copy main-build.js main.js
CALL npm run make
CALL move out\TilBuci-win32-x64\resources\app\phpwindows.exe out\TilBuci-win32-x64\phpwindows.exe
CALL del out\TilBuci-win32-x64\resources\app\phplinux
CALL del out\TilBuci-win32-x64\resources\app\phpmac
echo Your app is ready in the folder out\TilBuci-win32-x64\. To distribute it, you need to send all the contents of this folder.