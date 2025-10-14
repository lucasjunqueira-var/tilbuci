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
echo Creating desktop app installer...
call npx electron-forge make --arch x64
IF %ERRORLEVEL% NEQ 0 (
    echo error while creating the x64 app installer
    exit /b %ERRORLEVEL%
)
call npx electron-forge make --arch arm64
IF %ERRORLEVEL% NEQ 0 (
    echo error while creating the ARM app installer
    exit /b %ERRORLEVEL%
)
call explorer "out"
echo Your app installer (Setup.exe) was created at the "make" folder, inside the "out" one.
pause