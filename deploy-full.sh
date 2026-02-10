#!/bin/bash
cd app || { echo "ERROR: app directory not found!"; exit 1; }
export_dir="Export/html5/bin/"
server_dir="../server/public_html/app/"
buildtime=$(date +"%Y%m%d%H%M")
echo "Build timestamp: $buildtime"
if [ -f "Assets/build-base.json" ]; then
    sed "s/BNUM/$buildtime/" Assets/build-base.json > Assets/build.json
    echo "Build number $buildtime set in build.json"
else
    echo "ERROR: Assets/build-base.json not found!"
    exit 1
fi
if [ -f "project-full.xml" ]; then
    cp project-full.xml project.xml
    echo "project.xml set to FULL"
else
    echo "ERROR: project-full.xml not found!"
    exit 1
fi
echo "TilBuci FULL deploy $buildtime..."
openfl build html5 -D haxeJSON -nolaunch
build_status=$?
if [ $build_status -eq 0 ]; then
    echo "Build successful! Copying files..."  
    mkdir -p "${server_dir}assets" "${server_dir}manifest" "${server_dir}lib"
    if [ -f "${export_dir}TilBuci.js" ]; then
        cp "${export_dir}TilBuci.js" "${server_dir}TilBuci.js"
        echo "  TilBuci.js copied"
    elif [ -f "${export_dir}Tilbuci.js" ]; then
        cp "${export_dir}Tilbuci.js" "${server_dir}TilBuci.js"
        echo "  Tilbuci.js copied as TilBuci.js"
    else
        echo "  WARNING: TilBuci.js not found in ${export_dir}"
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
    echo "TilBuci FULL ready!"
else
    echo "TilBuci build error!"
    exit 1
fi