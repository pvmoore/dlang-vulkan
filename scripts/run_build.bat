@echo off

set COMPILER_TYPE=%1%
set BUILD_TYPE=%2%
set CONFIG_TYPE=%3%

chcp 65001
dub run --build=%BUILD_TYPE% --config=%CONFIG_TYPE% --compiler=%COMPILER_TYPE% --arch=x86_64 --parallel -- %4 %5
