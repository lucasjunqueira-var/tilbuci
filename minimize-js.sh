#!/bin/bash
echo "Starting TilBuci JS minification process..."
java -version >/dev/null 2>&1
if [ $? -eq 0 ]; then
    if [ -f "third/closure-compiler.jar" ]; then
        echo "Full TilBuci script with editor"
        if [ -f "server/public_html/app/TilBuci.js" ]; then
            echo " - file located"
            java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/public_html/app/TilBuci.js --js_output_file server/public_html/app/TilBuci-min.js
            echo " - success"
        else
            echo " - no full script file found, please run the 'deploy-full.sh' script to create it"
        fi
        echo "TilBuci desktop runtime"
        if [ -f "server/export/runtimes/desktop.js" ]; then
            echo " - file located"
            mv "server/export/runtimes/desktop.js" "server/export/runtimes/desktop.bck"
            java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/desktop.bck --js_output_file server/export/runtimes/desktop.js
            echo " - success"
            rm "server/export/runtimes/desktop.bck"
        else
            echo " - no desktop runtime file found, please run the 'deploy-runtime.sh' script to create it"
        fi
        echo "TilBuci mobile runtime"
        if [ -f "server/export/runtimes/mobile.js" ]; then
            echo " - file located"
            mv "server/export/runtimes/mobile.js" "server/export/runtimes/mobile.bck"
            java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/mobile.bck --js_output_file server/export/runtimes/mobile.js
            echo " - success"
            rm "server/export/runtimes/mobile.bck"
        else
            echo " - no mobile runtime file found, please run the 'deploy-runtime.sh' script to create it"
        fi
        echo "TilBuci publish services runtime"
        if [ -f "server/export/runtimes/publish.js" ]; then
            echo " - file located"
            mv "server/export/runtimes/publish.js" "server/export/runtimes/publish.bck"
            java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/publish.bck --js_output_file server/export/runtimes/publish.js
            echo " - success"
            rm "server/export/runtimes/publish.bck"
        else
            echo " - no publish services runtime file found, please run the 'deploy-runtime.sh' script to create it"
        fi
        echo "TilBuci PWA runtime"
        if [ -f "server/export/runtimes/pwa.js" ]; then
            echo " - file located"
            mv "server/export/runtimes/pwa.js" "server/export/runtimes/pwa.bck"
            java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/pwa.bck --js_output_file server/export/runtimes/pwa.js
            echo " - success"
            rm "server/export/runtimes/pwa.bck"
        else
            echo " - no PWA runtime file found, please run the 'deploy-runtime.sh' script to create it"
        fi
        echo "TilBuci website runtime"
        if [ -f "server/export/runtimes/website.js" ]; then
            echo " - file located"
            mv "server/export/runtimes/website.js" "server/export/runtimes/website.bck"
            java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/website.bck --js_output_file server/export/runtimes/website.js
            echo " - success"
            rm "server/export/runtimes/website.bck"
        else
            echo " - no website runtime file found, please run the 'deploy-runtime.sh' script to create it"
        fi
    else
        echo "The Google Closure compiler JAR file 'closure-compiler.jar' was not found at the 'third' folder. Please download and copy the compiler to the 'third' folder."
    fi
else
    echo "Java is required for the minification process. Please install and add it to your PATH then try again."
fi