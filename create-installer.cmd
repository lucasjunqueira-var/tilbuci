@echo off
setlocal enabledelayedexpansion

echo ============================================
echo TilBuci Installer Creation Script
echo ============================================

REM Looking for 7-Zip
set "SEVENZ="
if exist "C:\Program Files\7-Zip\7z.exe" (
    set "SEVENZ=C:\Program Files\7-Zip\7z.exe"
) else (
    echo ERROR: 7-Zip not found.
    echo Please ensure 7-zip is installed in the "Program Files" folder.
    exit /b 1
)
echo Using 7-zip: %SEVENZ%

REM Step 1: creating the full Javascript file
echo.
echo Step 1: Creating the full Javascript file...
call deploy-full.cmd
if %errorlevel% neq 0 (
    echo ERROR: Step 1 failed. Exiting.
    exit /b 1
)
cd ..
echo Step 1 completed.

REM Step 2: creating the runtime files
echo.
echo Step 2: Creating the runtime files...
call deploy-runtime.cmd
if %errorlevel% neq 0 (
    echo ERROR: Step 2 failed. Exiting.
    exit /b 1
)
cd ..
echo Step 2 completed.

REM Step 3: minification
echo.
echo Step 3: Minifying Javascript files...
call minimize-js.cmd
if %errorlevel% neq 0 (
    echo ERROR: Step 3 failed. Exiting.
    exit /b 1
)
echo Step 3 completed.

REM Step 4: removing old files
echo.
echo Step 4: Removing old ZIP files...
if exist "setup\setup\part1.zip" (
    del "setup\setup\part1.zip"
    echo Deleted part1.zip
)
if exist "setup\setup\part2.zip" (
    del "setup\setup\part2.zip"
    echo Deleted part2.zip
)
if exist "setup\setup\part3.zip" (
    del "setup\setup\part3.zip"
    echo Deleted part3.zip
)
echo Step 4 completed.

REM Step 5: creating part1.zip
echo.
echo Step 5: Creating part1.zip...
cd server
if %errorlevel% neq 0 (
    echo ERROR: Cannot change to server directory.
    exit /b 1
)

REM Create temporary directory
if exist temp_part1 rmdir /s /q temp_part1
mkdir temp_part1

REM Copy app folder excluding Config.php and Config - example.php
if exist app (
    echo Config.php > exclude_list.txt
    echo Config - example.php >> exclude_list.txt
    echo *.pdf >> exclude_list.txt
    echo *.zip >> exclude_list.txt
    echo *.psd >> exclude_list.txt
    echo *.kra >> exclude_list.txt
    xcopy app temp_part1\app /E /I /Y /EXCLUDE:exclude_list.txt
    del exclude_list.txt
)

REM Copy events/events.txt
if exist events\events.txt (
    if not exist temp_part1\events mkdir temp_part1\events
    copy events\events.txt temp_part1\events\ /Y
)

REM Copy export subfolders
set export_folders=desktop iframe mobile publish pwa runtimes site
for %%f in (%export_folders%) do (
    if exist export\%%f (
        xcopy export\%%f temp_part1\export\%%f /E /I /Y
    )
)

REM Copy language/langDefault.json
if exist language\langDefault.json (
    if not exist temp_part1\language mkdir temp_part1\language
    copy language\langDefault.json temp_part1\language\ /Y
)

REM Create ZIP using 7-Zip
echo Creating part1.zip with 7-Zip...
cd temp_part1
"%SEVENZ%" a -tzip "..\..\setup\setup\part1.zip" * -mx=9
if %errorlevel% neq 0 (
    echo ERROR: Failed to create part1.zip.
    cd ..
    rmdir /s /q temp_part1
    exit /b 1
)
cd ..

REM Cleanup
rmdir /s /q temp_part1
cd ..
echo Step 5 completed.

REM Step 6: creating part2.zip
echo.
echo Step 6: Creating part2.zip...
cd server\public_html
if %errorlevel% neq 0 (
    echo ERROR: Cannot change to server\public_html directory.
    exit /b 1
)

if exist temp_part2 rmdir /s /q temp_part2
mkdir temp_part2

REM Copy app folder excluding editor.json, player.json, etc.
if exist app (
    echo editor.json > exclude2.txt
    echo player.json >> exclude2.txt
    echo editor - example.json >> exclude2.txt
    echo player - example.json >> exclude2.txt
    echo *.pdf >> exclude2.txt
    echo *.zip >> exclude2.txt
    echo *.psd >> exclude2.txt
    echo *.kra >> exclude2.txt
    xcopy app temp_part2\app /E /I /Y /EXCLUDE:exclude2.txt
    del exclude2.txt
)

REM Copy download/index.php
if exist download\index.php (
    if not exist temp_part2\download mkdir temp_part2\download
    copy download\index.php temp_part2\download\ /Y
)

REM Copy editor/index.php
if exist editor\index.php (
    if not exist temp_part2\editor mkdir temp_part2\editor
    copy editor\index.php temp_part2\editor\ /Y
)

REM Copy font files
set font_files=averiaserifgwf.woff2 liberationserif.woff2 librasans.woff2 roboto.woff2
for %%f in (%font_files%) do (
    if exist font\%%f (
        if not exist temp_part2\font mkdir temp_part2\font
        copy font\%%f temp_part2\font\ /Y
    )
)

REM Copy movie/movie.txt
if exist movie\movie.txt (
    if not exist temp_part2\movie mkdir temp_part2\movie
    copy movie\movie.txt temp_part2\movie\ /Y
)

REM Copy ws files
if exist ws\index.php (
    if not exist temp_part2\ws mkdir temp_part2\ws
    copy ws\index.php temp_part2\ws\ /Y
)
if exist ws\launcher.php (
    if not exist temp_part2\ws mkdir temp_part2\ws
    copy ws\launcher.php temp_part2\ws\ /Y
)
if exist ws\launcher\theartist.gif (
    if not exist temp_part2\ws\launcher mkdir temp_part2\ws\launcher
    copy ws\launcher\theartist.gif temp_part2\ws\launcher\ /Y
)

REM Copy license.txt
if exist license.txt (
    copy license.txt temp_part2\ /Y
)

REM Create ZIP using 7-Zip
echo Creating part2.zip with 7-Zip...
cd temp_part2
"%SEVENZ%" a -tzip "..\..\..\setup\setup\part2.zip" * -mx=9
if %errorlevel% neq 0 (
    echo ERROR: Failed to create part2.zip.
    cd ..
    rmdir /s /q temp_part2
    exit /b 1
)
cd ..

rmdir /s /q temp_part2
cd ..\..
echo Step 6 completed.

REM Step 7: creating part3.zip
echo.
echo Step 7: Creating part3.zip...
cd server\public_html
if %errorlevel% neq 0 (
    echo ERROR: Cannot change to server\public_html directory.
    exit /b 1
)

if exist temp_part3 rmdir /s /q temp_part3
mkdir temp_part3

if exist index.php copy index.php temp_part3\ /Y
if exist VisitorTerms.txt copy VisitorTerms.txt temp_part3\ /Y

REM Create ZIP using 7-Zip
echo Creating part3.zip with 7-Zip...
cd temp_part3
"%SEVENZ%" a -tzip "..\..\..\setup\setup\part3.zip" * -mx=9
if %errorlevel% neq 0 (
    echo ERROR: Failed to create part3.zip.
    cd ..
    rmdir /s /q temp_part3
    exit /b 1
)
cd ..

rmdir /s /q temp_part3
cd ..\..
echo Step 7 completed.

REM Step 8: finishing the installer
echo.
echo Step 8: Creating final installer...
cd setup
if %errorlevel% neq 0 (
    echo ERROR: Cannot change to setup directory.
    exit /b 1
)
if exist "TilBuci_webinstall_update_NEW.zip" (
    del "TilBuci_webinstall_update_NEW.zip"
    echo Deleted old TilBuci_webinstall_update_NEW.zip
)

REM Create temporary directory for final ZIP structure
if exist temp_final rmdir /s /q temp_final
mkdir temp_final

REM Copy setup folder (the inner one) into temp_final
xcopy setup temp_final\setup /E /I /Y

REM Copy README.txt and setup.php into temp_final
copy README.txt temp_final\ /Y
copy setup.php temp_final\ /Y

REM Create ZIP using 7-Zip
echo Creating final installer with 7-Zip...
cd temp_final
"%SEVENZ%" a -tzip "..\TilBuci_webinstall_update_NEW.zip" * -mx=9
if %errorlevel% neq 0 (
    echo ERROR: Failed to create final installer.
    cd ..
    rmdir /s /q temp_final
    exit /b 1
)
cd ..

REM Cleanup temporary directory
rmdir /s /q temp_final
cd ..
echo Step 8 completed.

echo.
echo ============================================
echo Installer creation completed successfully!
echo Final installer: setup\TilBuci_webinstall_update_NEW.zip
echo ============================================
pause