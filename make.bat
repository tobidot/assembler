@echo off
if "%1%"=="" goto error
@echo on
@N:\nasm -f bin %1.asm -l .\list\%1.lst -o .\dist\%1.com
@echo off
goto end
:error
echo "plase?"
:end