#!/bin/bash
cp main-build.js main.js
npm run make
mv out/TilBuci-darwin-x64/TilBuci.app/Contents/Resources/app/phpmac out/TilBuci-darwin-x64/TilBuci.app/Contents/MacOS
rm out/TilBuci-darwin-x64/TilBuci.app/Contents/Resources/app/phpwindows.exe
rm out/TilBuci-darwin-x64/TilBuci.app/Contents/Resources/app/phplinux