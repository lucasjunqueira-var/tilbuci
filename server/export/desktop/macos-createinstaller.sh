#!/bin/zsh
echo "Preparing icons..."
mkdir -p icons
./node_modules/.bin/electron-icon-maker --input=favicon.png --output=./
cp -R ./icons/mac/* icons
cp -R ./icons/win/* icons
cp -R ./icons/png/* icons
echo "Creating desktop app..."
npx electron-forge make --arch x64
npx electron-forge make --arch arm64
open ./out
echo "Your app installer was created at the out/make folder as ZIP files, for both Intel (x64) and Silicon (arm64) platforms.