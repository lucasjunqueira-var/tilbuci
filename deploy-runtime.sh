#!/bin/bash
cd app || { echo "ERROR: app directory not found!"; exit 1; }
export_dir="Export/html5/bin/"
server_dir="../server/export/runtimes/"
echo "TilBuci WEBSITE build..."
cp project-runtime.xml project.xml
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimewebsite
if [ $? -eq 0 ]; then
    cp "${export_dir}Runtime.js" "${server_dir}website.js"
    echo "  build ok!"
else
    echo "  error!"
fi
echo "TilBuci PWA build..."
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimepwa
if [ $? -eq 0 ]; then
    cp "${export_dir}Runtime.js" "${server_dir}pwa.js"
    echo "  build ok!"
else
    echo "  error!"
fi
echo "TilBuci DESKTOP build..."
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimedesktop
if [ $? -eq 0 ]; then
    cp "${export_dir}Runtime.js" "${server_dir}desktop.js"
    echo "  build ok!"
else
    echo "  error!"
fi
echo "TilBuci MOBILE build..."
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimemobile
if [ $? -eq 0 ]; then
    cp "${export_dir}Runtime.js" "${server_dir}mobile.js"
    echo "  build ok!"
else
    echo "  error!"
fi
echo "TilBuci PUBLISH SERVICES build..."
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimepublish
if [ $? -eq 0 ]; then
    cp "${export_dir}Runtime.js" "${server_dir}publish.js"
    echo "  build ok!"
else
    echo "  error!"
fi
echo "TilBuci export runtimes created!"