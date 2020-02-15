echo off
if "%1"="" goto error
N:\nasm -f bin %1.asm -l .\list\%1.lst -o .\dist\%1.com
goto end
:error
echo "plase?"
:end