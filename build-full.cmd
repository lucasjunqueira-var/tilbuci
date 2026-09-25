@echo off
cd app
set export="Export\html5\bin\"
set server="..\server\public_html\app\"
set assets="..\app\"
rem ---------------------------------------------------------------------------
rem Build timestamp (YYYYMMDDHHMM)
rem wmic was deprecated and removed from Windows 11 24H2+ (now a Feature on
rem Demand, disabled by default), so the date comes from PowerShell instead.
rem ---------------------------------------------------------------------------
set buildtime=
for /F "delims=" %%F in ('powershell -NoProfile -Command "Get-Date -Format yyyyMMddHHmm"') do set buildtime=%%F
if not defined buildtime (
    echo TilBuci build number error: could not determine the current date/time.
    exit /b 1
)
powershell -NoProfile -Command "(gc Assets/build-base.json) -replace 'BNUM', '%buildtime%' | Out-File -encoding UTF8 Assets/build.json"
if errorlevel 1 (
    echo TilBuci build number error: Assets/build.json was not generated.
    exit /b 1
)
powershell -NoProfile -Command "cp project-full.xml project.xml"
echo TilBuci FULL build %buildtime%...
openfl build html5 -D haxeJSON -nolaunch
if %errorlevel% equ 0 (
    copy %export%Tilbuci.js %server%TilBuci.js
    type Externs\browser.js Externs\embedcontent.js Externs\overlayplugin.js Externs\upload.js Externs\qrcode.js Externs\accessibility.js > Externs\externs.js
    copy /Y Externs\externs.js %server%
    xcopy %assets%assets\*.* %server%assets\ /E/Y/Q
    xcopy %export%lib\*.* %server%lib\ /E/Y/Q
    start "" "http://tilbuci/app/?md=editor&cch=true"
    echo TilBuci started!
) else (
    echo TilBuci build error!
)
