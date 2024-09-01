@echo off
set export="Export\html5\bin\"
set server="C:\sync\Dropbox\Htdocs\Tilbuci\public_html\app\"
for /F "skip=1 delims=" %%F in ('
    wmic PATH Win32_LocalTime GET Day^,Month^,Year /FORMAT:TABLE
') do (
    for /F "tokens=1-3" %%L in ("%%F") do (
        set CurrDay=0%%L
        set CurrMonth=0%%M
        set CurrYear=%%N
    )
)
set CurrDay=%CurrDay:~-2%
set CurrMonth=%CurrMonth:~-2%
set CurrHour=%time:~0,2%
set CurrHour=00%CurrHour: =%
set CurrHour=%CurrHour:~-2%
set CurrMinute=%time:~3,2%
set CurrMinute=00%CurrMinute: =%
set CurrMinute=%CurrMinute:~-2%
set buildtime=%CurrYear%%CurrMonth%%CurrDay%%CurrHour%%CurrMinute%
powershell -Command "(gc Assets/build-base.json) -replace 'BNUM', %buildtime% | Out-File -encoding UTF8 Assets/build.json"
powershell -Command "cp project-dom.xml project.xml"
echo TilBuci editor build %buildtime%...
openfl build html5 -D haxeJSON -final
if %errorlevel% equ 0 (
    copy %export%Tilbuci.js %server%TilBuci-dom.js
    xcopy %export%assets\*.* %server%assets\ /E/Y/Q
    xcopy %export%manifest\*.* %server%manifest\ /E/Y/Q
    xcopy %export%lib\*.* %server%lib\ /E/Y/Q
    echo TilBuci DOM ready!
) else (
    echo TilBuci build error!
)