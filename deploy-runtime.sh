#!/bin/bash

# Change to app directory
cd app || { echo "ERROR: app directory not found!"; exit 1; }

# Define directories
export_dir="Export/html5/bin/"
server_dir="../server/export/runtimes/"

# Copy project-runtime.xml to project.xml
if [ -f "project-runtime.xml" ]; then
    cp project-runtime.xml project.xml
    echo "project.xml set to RUNTIME"
else
    echo "ERROR: project-runtime.xml not found!"
    exit 1
fi

# Function to build a specific runtime
build_runtime() {
    local name="$1"
    local define="$2"
    local output="$3"
    
    echo "TilBuci $name build..."
    openfl build html5 -D haxeJSON -D tilbuciplayer -D "$define"
    if [ $? -eq 0 ]; then
        cp "${export_dir}Runtime.js" "${server_dir}${output}"
        echo "  build ok!"
    else
        echo "  error!"
    fi
}

# Build all runtimes
build_runtime "WEBSITE" "runtimewebsite" "website.js"
build_runtime "PWA" "runtimepwa" "pwa.js"
build_runtime "DESKTOP" "runtimedesktop" "desktop.js"
build_runtime "MOBILE" "runtimemobile" "mobile.js"
build_runtime "PUBLISH SERVICES" "runtimepublish" "publish.js"

# Concatenate externs files
echo "Creating externs.js..."
if [ -f "Externs/browser.js" ] && [ -f "Externs/embedcontent.js" ] && [ -f "Externs/overlayplugin.js" ] && [ -f "Externs/upload.js" ]; then
    cat Externs/browser.js Externs/embedcontent.js Externs/overlayplugin.js Externs/upload.js > Externs/externs.js
    echo "  externs.js created"
    
    # Copy externs.js to desktop, mobile, site directories
    if [ -d "${server_dir}/../desktop" ]; then
        cp Externs/externs.js "${server_dir}/../desktop/"
        echo "  copied to desktop"
    fi
    if [ -d "${server_dir}/../mobile" ]; then
        cp Externs/externs.js "${server_dir}/../mobile/"
        echo "  copied to mobile"
    fi
    if [ -d "${server_dir}/../site" ]; then
        cp Externs/externs.js "${server_dir}/../site/"
        echo "  copied to site"
    fi
else
    echo "  WARNING: One or more externs files missing, skipping externs concatenation"
fi

echo "TilBuci export runtimes created!"