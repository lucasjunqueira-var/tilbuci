@echo off
REM Concatena os arquivos JS em externs.js
type app\Externs\browser.js app\Externs\embedcontent.js app\Externs\overlayplugin.js app\Externs\upload.js > app\Externs\externs.js

REM Copia externs.js para as pastas de destino
copy /Y app\Externs\externs.js server\public_html\app\
copy /Y app\Externs\externs.js server\export\desktop\
copy /Y app\Externs\externs.js server\export\mobile\
copy /Y app\Externs\externs.js server\export\site\

echo Operação concluída com sucesso!
pause
