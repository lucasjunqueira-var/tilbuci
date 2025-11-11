@echo off
echo Installing Capacitor...
call copy "package.ori" "package.json"
call npm install @capacitor/cli @capacitor/core
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing Capacitor
    exit /b %ERRORLEVEL%
)
echo Installing status bar plugin...
call npm install @capacitor/status-bar
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing Capacitor
    exit /b %ERRORLEVEL%
)
echo Installing file system plugin...
call npm install @capacitor/filesystem
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing Capacitor
    exit /b %ERRORLEVEL%
)
echo Installing navigation bar plugin...
call npm install @squareetlabs/capacitor-navigation-bar
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing Capacitor
    exit /b %ERRORLEVEL%
)
echo Installing app plugin...
call npm install @capacitor/app
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing Capacitor
    exit /b %ERRORLEVEL%
)
echo Installing assets handler...
call npm install @capacitor/assets --save-dev
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing the assets handler
    exit /b %ERRORLEVEL%
)
echo Installing kiosk mode support...
call npm install @capgo/capacitor-android-kiosk
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing the kiosk mode support
    exit /b %ERRORLEVEL%
)
echo Preparing Android environment...
call npm install @capacitor/android
IF %ERRORLEVEL% NEQ 0 (
    echo error while preparing for Android
    exit /b %ERRORLEVEL%
)
echo Adding the Android platform...
call npx cap add android
IF %ERRORLEVEL% NEQ 0 (
    echo error while adding the Android platform
    exit /b %ERRORLEVEL%
)
echo App setup process completed successfully!
pause