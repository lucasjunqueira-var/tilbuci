@echo off
echo Testing desktop app...
call npm run start
IF %ERRORLEVEL% NEQ 0 (
    echo error while testing the app
    exit /b %ERRORLEVEL%
)
pause