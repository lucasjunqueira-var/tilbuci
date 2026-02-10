@echo off
echo Starting TilBuci JS minification process...
java -version >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    IF EXIST "third/closure-compiler.jar" (
        echo Full TilBuci script with editor
        IF EXIST "server/public_html/app/TilBuci.js" (
            echo - file located
            CALL java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/public_html/app/TilBuci.js --js_output_file server/public_html/app/TilBuci-min.js
            echo - success
        ) ELSE (
            echo - no full script file found, please run the 'deploy-full.cmd' script to create it
        )
        echo TilBuci desktop runtime
        IF EXIST "server/export/runtimes/desktop.js" (
            echo - file located
            rename "server\export\runtimes\desktop.js" "desktop.bck"
            CALL java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/desktop.bck --js_output_file server/export/runtimes/desktop.js
            echo - success
            del "server\export\runtimes\desktop.bck"
        ) ELSE (
            echo - no desktop runtime file found, please run the 'deploy-runtime.cmd' script to create it
        )
        echo TilBuci mobile runtime
        IF EXIST "server/export/runtimes/mobile.js" (
            echo - file located
            rename "server\export\runtimes\mobile.js" "mobile.bck"
            CALL java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/mobile.bck --js_output_file server/export/runtimes/mobile.js
            echo - success
            del "server\export\runtimes\mobile.bck"
        ) ELSE (
            echo - no mobile runtime file found, please run the 'deploy-runtime.cmd' script to create it
        )
        echo TilBuci publish services runtime
        IF EXIST "server/export/runtimes/publish.js" (
            echo - file located
            rename "server\export\runtimes\publish.js" "publish.bck"
            CALL java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/publish.bck --js_output_file server/export/runtimes/publish.js
            echo - success
            del "server\export\runtimes\publish.bck"
        ) ELSE (
            echo - no publish services runtime file found, please run the 'deploy-runtime.cmd' script to create it
        )
        echo TilBuci PWA runtime
        IF EXIST "server/export/runtimes/pwa.js" (
            echo - file located
            rename "server\export\runtimes\pwa.js" "pwa.bck"
            CALL java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/pwa.bck --js_output_file server/export/runtimes/pwa.js
            echo - success
            del "server\export\runtimes\pwa.bck"
        ) ELSE (
            echo - no PWA runtime file found, please run the 'deploy-runtime.cmd' script to create it
        )
        echo TilBuci website runtime
        IF EXIST "server/export/runtimes/website.js" (
            echo - file located
            rename "server\export\runtimes\website.js" "website.bck"
            CALL java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/export/runtimes/website.bck --js_output_file server/export/runtimes/website.js
            echo - success
            del "server\export\runtimes\website.bck"
        ) ELSE (
            echo - no mobile runtime file found, please run the 'deploy-runtime.cmd' script to create it
        )
    ) ELSE (
        echo The Google Closure compiler JAR file 'closure-compiler.jar' was not found at the 'third' folder. Please download and copy the compiler to the 'third' folder.
    )
) ELSE (
    echo Java is required for the minification process. Please install and add it to your PATH then try again.
)