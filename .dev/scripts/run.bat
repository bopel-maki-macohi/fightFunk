@echo off
ren "%~1.SCRIPT" "%~1.hx"
haxe -m "%~1" --interp %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
ren "%~1.hx" "%~1.SCRIPT"