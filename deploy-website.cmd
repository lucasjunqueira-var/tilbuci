@echo off
cd app
set export="Export\html5\bin\"
set server="..\server\export\runtimes\"
set assets="..\app\"
echo TilBuci WEBSITE build...
powershell -Command "cp project-runtime.xml project.xml"
openfl build html5 -D haxeJSON -D tilbuciplayer -D runtimewebsite
if %errorlevel% equ 0 (
    copy %export%TilBuci.js %server%website.js
    echo  build ok!
) else (
    echo error!
)

type Externs\browser.js Externs\embedcontent.js Externs\overlayplugin.js Externs\upload.js Externs\qrcode.js Externs\accessibility.js > Externs\externs.js
copy /Y Externs\externs.js %server%\..\desktop
copy /Y Externs\externs.js %server%\..\mobile
copy /Y Externs\externs.js %server%\..\site

echo TilBuci export website runtime created!