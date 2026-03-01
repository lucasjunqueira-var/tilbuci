@echo off
echo Installing Electron...
call copy "package.ori" "package.json"
call npm install --save-dev electron
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing Electron
    exit /b %ERRORLEVEL%
)
echo Installing Electron Forge...
call npm install --save-dev @electron-forge/cli
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing Electron Forge
    exit /b %ERRORLEVEL%
)
echo Configuring Electron Forge...
call npx electron-forge import
IF %ERRORLEVEL% NEQ 0 (
    echo error while configuring Electron Forge
    exit /b %ERRORLEVEL%
)
echo Installing icon manager...
call npm install --save-dev electron-icon-maker
IF %ERRORLEVEL% NEQ 0 (
    echo error while installing the icon manager
    exit /b %ERRORLEVEL%
)
echo Adjusting Forge configuration...
call node adjust-forge.mjs
IF %ERRORLEVEL% NEQ 0 (
    echo error while adjusting forge configuration
    exit /b %ERRORLEVEL%
)
pause