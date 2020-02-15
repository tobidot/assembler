@echo off
if "%1%"=="" goto error
if NOT Exist "%1%" goto error
N:\nasm -f bin %1 -l .\list\temp.lst -o .\dist\temp.com
echo --- Start ---
echo +
echo on
@.\dist\temp.com
@echo off
echo +
echo --- End ---
goto end
:error
echo please?
:end