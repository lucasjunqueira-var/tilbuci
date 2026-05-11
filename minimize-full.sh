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
    else
        echo "The Google Closure compiler JAR file 'closure-compiler.jar' was not found at the 'third' folder. Please download and copy the compiler to the 'third' folder."
    fi
else
    echo "Java is required for the minification process. Please install and add it to your PATH then try again."
fi