@echo off
rem ---------------------------------------------------------------------------
rem TilBuci Showtime (desktop) - Windows build (x64 and arm64)
rem
rem Equivalent to "npm run build:win": generates both the x64 and the arm64
rem unpacked Windows builds using the locally installed electron-builder.
rem
rem Output folders:
rem   dist\win-unpacked          Windows x64
rem   dist\win-arm64-unpacked    Windows arm64
rem
rem Note: electron-builder rebuilds the native serialport module for each target
rem architecture, so after the build node_modules\@serialport\bindings-cpp
rem \build\Release holds the binding of the last built architecture (arm64).
rem Because node-gyp-build checks that folder before the prebuilt binaries, that
rem leftover breaks local "npm start" runs with:
rem     bindings.node is not a valid Win32 application
rem The script therefore validates the binding when the build finishes and
rem removes the leftover, so the correct prebuilt binary is used again.
rem
rem Usage:
rem   build.cmd                builds Windows x64 and arm64 (default)
rem   build.cmd <arguments>    forwards the arguments to electron-builder,
rem                            e.g. build.cmd --win --x64
rem ---------------------------------------------------------------------------

setlocal EnableExtensions
title TilBuci Showtime - desktop build

rem Always operate from the folder that contains this script.
cd /d "%~dp0"

echo ============================================================
echo  TilBuci Showtime - desktop build
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
rem 2. Dependencies
rem ---------------------------------------------------------------------------
if exist "node_modules\electron-builder" goto :deps_ok
echo [setup] node_modules is missing, installing dependencies...
call npm install
if errorlevel 1 (
    echo [error] "npm install" failed.
    pause
    exit /b 1
)
:deps_ok

rem ---------------------------------------------------------------------------
rem 3. Build arguments
rem ---------------------------------------------------------------------------
set "BUILD_ARGS=%*"
if not defined BUILD_ARGS set "BUILD_ARGS=--win --x64 --arm64"

rem ---------------------------------------------------------------------------
rem 4. Clean the previous outputs
rem ---------------------------------------------------------------------------
rem A build that fails while renaming its output leaves an intermediate
rem "<target>.tmp" folder behind. Outputs and leftovers are removed so the new
rem build starts from a clean state.
if exist "dist\win-unpacked" (
    echo [setup] removing previous output: dist\win-unpacked
    rmdir /s /q "dist\win-unpacked"
)
if exist "dist\win-arm64-unpacked" (
    echo [setup] removing previous output: dist\win-arm64-unpacked
    rmdir /s /q "dist\win-arm64-unpacked"
)
if exist "dist\win-unpacked.tmp" (
    echo [setup] removing leftover intermediate output: dist\win-unpacked.tmp
    rmdir /s /q "dist\win-unpacked.tmp"
)
if exist "dist\win-arm64-unpacked.tmp" (
    echo [setup] removing leftover intermediate output: dist\win-arm64-unpacked.tmp
    rmdir /s /q "dist\win-arm64-unpacked.tmp"
)
if exist "dist\win-unpacked" echo [warn] could not remove dist\win-unpacked, it seems to be in use.
if exist "dist\win-arm64-unpacked" echo [warn] could not remove dist\win-arm64-unpacked, it seems to be in use.
if exist "dist\win-unpacked.tmp" echo [warn] could not remove dist\win-unpacked.tmp, it seems to be in use.
if exist "dist\win-arm64-unpacked.tmp" echo [warn] could not remove dist\win-arm64-unpacked.tmp, it seems to be in use.

rem ---------------------------------------------------------------------------
rem 5. Build
rem ---------------------------------------------------------------------------
echo.
echo [build] electron-builder %BUILD_ARGS%
echo [build] the first run downloads the Electron binaries, this may take a while.
echo.

call "node_modules\.bin\electron-builder.cmd" %BUILD_ARGS%
set "BUILD_RESULT=%errorlevel%"

echo.
if not "%BUILD_RESULT%"=="0" goto :build_failed

rem ---------------------------------------------------------------------------
rem 6. Restore the native binding for local development
rem ---------------------------------------------------------------------------
rem The native module now matches the last built architecture. If it no longer
rem loads on this machine, it is removed so the prebuilt binary is used again.
node -e "require('node-gyp-build')(require('path').join(process.cwd(),'node_modules','@serialport','bindings-cpp'))" >nul 2>&1
if not errorlevel 1 goto :binding_restored

echo [setup] restoring the native serialport binding for local runs...
if exist "node_modules\@serialport\bindings-cpp\build" rmdir /s /q "node_modules\@serialport\bindings-cpp\build"
node -e "require('node-gyp-build')(require('path').join(process.cwd(),'node_modules','@serialport','bindings-cpp'))" >nul 2>&1
if errorlevel 1 goto :binding_failed
echo [setup] native binding restored.
goto :binding_restored

:binding_failed
echo [warn]  could not restore the native binding. Run test.cmd, or "npm ci",
echo [warn]  before running "npm start".
:binding_restored

echo [done] build finished successfully.
if exist "dist\win-unpacked" echo [done] Windows x64:   dist\win-unpacked\TilBuci Showtime.exe
if exist "dist\win-arm64-unpacked" echo [done] Windows arm64: dist\win-arm64-unpacked\TilBuci Showtime.exe
echo [done] the packaged application stores its data in the user's Documents\TBShowtime folder.
echo.
pause
endlocal
exit /b 0

:build_failed
echo [error] the build failed with exit code %BUILD_RESULT%.
echo [error] review the output above for the reason.
echo [hint]  errors such as "EPERM: operation not permitted, rename" are usually
echo [hint]  caused by antivirus scanning or by a file being used in the dist
echo [hint]  folder. Close anything using dist and run build.cmd again.
echo.
pause
endlocal
exit /b %BUILD_RESULT%
