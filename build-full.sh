#!/bin/bash
cd app || { echo "ERROR: app dir not found!"; exit 1; }
export_dir="Export/html5/bin/"
server_dir="../server/public_html/app/"
buildtime=$(date +"%Y%m%d%H%M")
echo "Build timestamp: $buildtime"
if [ -f "Assets/build-base.json" ]; then
    sed "s/BNUM/$buildtime/" Assets/build-base.json > Assets/build.json
else
    echo "ERROR: Assets/build-base.json file not found!"
    exit 1
fi
if [ -f "project-full.xml" ]; then
    cp project-full.xml project.xml
else
    echo "ERROR: project-full.xml file not found!"
    exit 1
fi
echo "TilBuci FULL build $buildtime..."
openfl build html5 -D haxeJSON -nolaunch
build_status=$?
if [ $build_status -eq 0 ]; then
    echo "Build OK! Start file copy..."
    mkdir -p "${server_dir}assets" "${server_dir}manifest" "${server_dir}lib"
    if [ -f "${export_dir}TilBuci.js" ]; then
        cp "${export_dir}TilBuci.js" "${server_dir}TilBuci.js"
        echo "  TilBuci.js copied"
    elif [ -f "${export_dir}Tilbuci.js" ]; then
        cp "${export_dir}Tilbuci.js" "${server_dir}TilBuci.js"
        echo "  TilBuci.js copied"
    else
        echo "  WARNING: TilBuci.js not found at ${export_dir}"
    fi
    if [ -d "${export_dir}assets" ]; then
        cp -R "${export_dir}assets/." "${server_dir}assets/" 2>/dev/null
        echo "  assets copied"
    fi
    if [ -d "${export_dir}manifest" ]; then
        cp -R "${export_dir}manifest/." "${server_dir}manifest/" 2>/dev/null
        echo "  manifest copied"
    fi
    if [ -d "${export_dir}lib" ]; then
        cp -R "${export_dir}lib/." "${server_dir}lib/" 2>/dev/null
        echo "  lib copied"
    fi
    echo "Files ready at ${server_dir}"
    echo "Opening browser..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "http://tilbuci/app/?md=editor&cch=true"
    else
        xdg-open "http://tilbuci/app/?md=editor&cch=true"
    fi
    echo "TilBuci started!"
else
    echo "TilBuci build error!"
    exit 1
fi