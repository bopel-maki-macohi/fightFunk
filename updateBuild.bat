@echo off
ren SetBuild.SCRIPT SetBuild.hx
haxe -m SetBuild --interp %~1 %~2 %~3 %~4 %~5 %~6 %~7 %~8 %~9
ren SetBuild.hx SetBuild.SCRIPT