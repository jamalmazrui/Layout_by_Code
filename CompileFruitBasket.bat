@echo off
cls
echo Compiling
if exist FruitBasket.exe del FruitBasket.exe
"c:\Program Files (x86)\AutoIt3\Aut2Exe\Aut2exe.exe" /in FruitBasket.au3 /console
if exist FruitBasket.exe echo Done
