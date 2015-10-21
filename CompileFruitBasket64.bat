@echo off
cls
echo Compiling
if exist FruitBasket64.exe del FruitBasket64.exe
"c:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2Exe_x64.exe" /in FruitBasket.au3 /out FruitBasket64.exe /console
if exist FruitBasket64.exe echo Done
