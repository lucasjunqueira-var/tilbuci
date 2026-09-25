@echo off
rem ---------------------------------------------------------------------------
rem TilBuci Showtime (desktop) - test launcher
rem
rem Prepares the environment and starts the Electron application in test mode.
rem Usage: double-click this file, or run "test.cmd" from a terminal.
rem ---------------------------------------------------------------------------

setlocal EnableExtensions
title TilBuci Showtime - desktop test

rem Always operate from the folder that contains this script.
cd /d "%~dp0"

echo ============================================================
echo  TilBuci Showtime - desktop test
echo ============================================================
echo.

rem ---------------------------------------------------------------------------
rem 1. Node.js availability
rem ---------------------------------------------------------------------------
where node >nul 2>&1
if errorlevel 1 (
    echo [error] Node.js was not found in PATH.
    echo [error] Install Node.js 18 or newer and try again.
    pause
    exit /b 1
)

rem ---------------------------------------------------------------------------
rem 2. Environment sanitizing
rem ---------------------------------------------------------------------------
rem The VS Code integrated terminal exports ELECTRON_RUN_AS_NODE=1. With that
rem variable set, Electron starts as plain Node and the application fails with
rem "Cannot read properties of undefined (reading 'whenReady')".
rem The quoting matters here: "set VAR=" with a trailing space would set the
rem variable to a space instead of clearing it.
set "ELECTRON_RUN_AS_NODE="

rem ---------------------------------------------------------------------------
rem 3. Dependencies
rem ---------------------------------------------------------------------------
if exist "node_modules\electron" goto :deps_ok
echo [setup] node_modules is missing, installing dependencies...
call npm install
if errorlevel 1 (
    echo [error] "npm install" failed.
    pause
    exit /b 1
)
:deps_ok

rem ---------------------------------------------------------------------------
rem 4. Native serialport binding
rem ---------------------------------------------------------------------------
rem node-gyp-build looks inside node_modules\@serialport\bindings-cpp\build\Release
rem BEFORE the prebuilt binaries in the "prebuilds" folder. A leftover local
rem build made for another architecture (for example ARM64) therefore shadows
rem the correct x64 prebuild and loading fails with:
rem     bindings.node is not a valid Win32 application
rem When the binding cannot be loaded, the stale local build is removed so the
rem matching prebuilt binary is used instead.
node -e "require('node-gyp-build')(require('path').join(process.cwd(),'node_modules','@serialport','bindings-cpp'))" >nul 2>&1
if not errorlevel 1 goto :binding_ok

echo [setup] serialport native binding failed to load.
if exist "node_modules\@serialport\bindings-cpp\build" (
    echo [setup] removing the stale local build, using prebuilt binaries instead...
    rmdir /s /q "node_modules\@serialport\bindings-cpp\build"
)

node -e "require('node-gyp-build')(require('path').join(process.cwd(),'node_modules','@serialport','bindings-cpp'))" >nul 2>&1
if not errorlevel 1 goto :binding_ok

echo [error] the serialport native binding still cannot be loaded.
echo [error] run a clean reinstall with "npm ci" and try again.
pause
exit /b 1
:binding_ok

rem ---------------------------------------------------------------------------
rem 5. Local server port
rem ---------------------------------------------------------------------------
rem The application serves its content on http://localhost:8080, so a second
rem instance cannot bind the port. A running instance is closed on request.
netstat -ano | findstr /c:":8080 " | findstr /c:"LISTENING" >nul 2>&1
if errorlevel 1 goto :port_free

echo [warn] port 8080 is already in use, another instance may be running.
choice /C YN /N /M "Close the running instance and continue? [Y/N] "
if errorlevel 2 goto :port_free

rem netstat reports the same PID once per protocol (IPv4 and IPv6), so each PID
rem is terminated only once.
for /f "tokens=5" %%p in ('netstat -ano ^| findstr /c:":8080 " ^| findstr /c:"LISTENING"') do (
    if not defined killed_%%p (
        set "killed_%%p=1"
        taskkill /F /PID %%p >nul 2>&1
    )
)
echo [setup] previous instance closed.
:port_free

rem ---------------------------------------------------------------------------
rem 6. Run the application
rem ---------------------------------------------------------------------------
set "SHOWTIME_DATA="
for /f "usebackq delims=" %%d in (`powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')" 2^>nul`) do set "SHOWTIME_DATA=%%d\TBShowtime"

echo.
echo [run] content:   http://localhost:8080
echo [run] settings:  http://localhost:8080/config/config.html
if defined SHOWTIME_DATA echo [run] local data: %SHOWTIME_DATA%
echo [run] test REST routes: http://localhost:8080/api/name, /api/setval, /api/getval
echo [run] leave kiosk mode by clicking the top-left corner 5 times (accesskey AAAAA)
echo [run] starting the application...
echo.

call npm start

echo.
echo [run] the application has exited.
pause
endlocal
