@echo off
echo Preparing icons...
call ./node_modules/.bin/electron-icon-maker --input=favicon.png --output=./
IF %ERRORLEVEL% NEQ 0 (
    echo error while preparing the icons
    exit /b %ERRORLEVEL%
)
call xcopy ".\icons\mac\*" ".\icons\" /E /I /Y
call xcopy ".\icons\win\*" ".\icons\" /E /I /Y
call xcopy ".\icons\png\*" ".\icons\" /E /I /Y
echo Creating desktop app...
call npx electron-forge package --arch x64
IF %ERRORLEVEL% NEQ 0 (
    echo error while creating the x64 app
    exit /b %ERRORLEVEL%
)
call npx electron-forge package --arch arm64
IF %ERRORLEVEL% NEQ 0 (
    echo error while creating the ARM app
    exit /b %ERRORLEVEL%
)
call explorer "out"
echo Your app was created at the "out" folder for both x64 and ARM platforms.
pause