#!/bin/bash
cp main-build.js main.js
npm run make
mv out/TilBuci-linux-x64/resources/app/phplinux out/TilBuci-linux-x64/phplinux
rm out/TilBuci-linux-x64/resources/app/phpwindows.exe
rm out/TilBuci-linux-x64/resources/app/phpmac
