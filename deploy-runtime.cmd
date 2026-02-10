@echo off
cd app
set export="Export\html5\bin\"
set server="..\server\export\runtimes\"
echo TilBuci WEBSITE build...
powershell -Command "cp project-runtime.xml project.xml"
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimewebsite
if %errorlevel% equ 0 (
    copy %export%Runtime.js %server%website.js
    echo  build ok!
) else (
    echo error!
)
echo TilBuci PWA build...
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimepwa
if %errorlevel% equ 0 (
    copy %export%Runtime.js %server%pwa.js
    echo  build ok!
) else (
    echo error!
)
echo TilBuci DESKTOP build...
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimedesktop
if %errorlevel% equ 0 (
    copy %export%Runtime.js %server%desktop.js
    echo  build ok!
) else (
    echo error!
)
echo TilBuci MOBILE build...
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimemobile
if %errorlevel% equ 0 (
    copy %export%Runtime.js %server%mobile.js
    echo  build ok!
) else (
    echo error!
)
echo TilBuci PUBLISH SERVICES build...
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimepublish
if %errorlevel% equ 0 (
    copy %export%Runtime.js %server%publish.js
    echo  build ok!
) else (
    echo error!
)

type Externs\browser.js Externs\embedcontent.js Externs\overlayplugin.js Externs\upload.js > Externs\externs.js
copy /Y Externs\externs.js %server%\..\desktop
copy /Y Externs\externs.js %server%\..\mobile
copy /Y Externs\externs.js %server%\..\site

echo TilBuci export runtimes created!