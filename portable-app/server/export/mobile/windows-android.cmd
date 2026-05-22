@echo off
echo Preparing icon...
call npx capacitor-assets generate --android
IF %ERRORLEVEL% NEQ 0 (
    echo error while preparing the icon
    exit /b %ERRORLEVEL%
)
echo Synchronizing content...
call npx cap sync android
IF %ERRORLEVEL% NEQ 0 (
    echo error while synchronizing content
    exit /b %ERRORLEVEL%
)
echo Starting Android Studio...
call npx cap open android
pause