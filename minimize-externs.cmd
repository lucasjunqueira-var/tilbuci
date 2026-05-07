@echo off
echo Starting TilBuci JS minification process...
java -version >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    IF EXIST "third/closure-compiler.jar" (
        echo Full TilBuci script with editor
        IF EXIST "server/public_html/app/externs.js" (
            echo - file located
            CALL java -jar third/closure-compiler.jar --compilation_level SIMPLE_OPTIMIZATIONS --js server/public_html/app/externs.js --js_output_file server/public_html/app/externs-min.js
            echo - success
        ) ELSE (
            echo - no full script file found, please run the 'deploy-full.cmd' script to create it
        )
    ) ELSE (
        echo The Google Closure compiler JAR file 'closure-compiler.jar' was not found at the 'third' folder. Please download and copy the compiler to the 'third' folder.
    )
) ELSE (
    echo Java is required for the minification process. Please install and add it to your PATH then try again.
)