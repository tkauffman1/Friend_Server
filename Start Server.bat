@echo off
title AzerothCore Server
mode con: cols=52 lines=11
setlocal EnableDelayedExpansion


COLOR 3F
echo LOADING...
timeout 5 >nul


GOTO MENU


:MENU
cls
COLOR 0A
ECHO 1 - Start All Servers
if exist "Wow.lnk" ((ECHO 2 - Start Wow Shortcut))
if not exist "Wow.lnk" ((ECHO 7 - EXIT)) ELSE ECHO 3 - EXIT

ECHO.

SET /P M=Type menu number then press ENTER:
IF %M%==1 GOTO STARTALL
IF %M%==2 GOTO WOW
IF %M%==3 GOTO :EOF


:STARTALL
cls
echo CONNECTING DATABASE...  
tasklist /fi "ImageName eq mysqld.exe" /fo csv 2>NUL | find /I "mysqld.exe">NUL
if "%ERRORLEVEL%"=="1" (start /min mysql\bin\mysqld.exe --console --standalone --max_allowed_packet=128M) ELSE echo Mysql was already started.
timeout 8 >nul
cls
echo STARTING OLLAMA LLM API ^(port 11434^)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "if (-not (Get-NetTCPConnection -LocalPort 11434 -State Listen -ErrorAction SilentlyContinue)) { Start-Process '%LOCALAPPDATA%\Programs\Ollama\ollama.exe' -ArgumentList 'serve' -WindowStyle Minimized; Start-Sleep -Seconds 5 }"
cls
echo CONNECTING LOGON AUTH SERVER...
tasklist /fi "ImageName eq authserver.exe" /fo csv 2>NUL | find /I "authserver.exe">NUL
if "%ERRORLEVEL%"=="1" (start /min authserver) ELSE echo Authserver was already started.
timeout 3 >nul
cls
echo CONNECTING LOGON WORLD SERVER...
tasklist /fi "ImageName eq worldserver.exe" /fo csv 2>NUL | find /I "worldserver.exe">NUL
if "%ERRORLEVEL%"=="1" (start /min worldserver) ELSE echo worldserver was already started.
timeout 3 >nul
cls
echo LOADING WORLD SERVER, PLEASE WAIT!
timeout 20 >nul
GOTO MENU



:WOW
if exist "Wow.lnk" (GOTO STARTWOW) ELSE GOTO :EOF


:STARTWOW
cls
start Wow.lnk
tasklist /fi "ImageName eq Wow.exe" /fo csv 2>NUL | find /I "Wow.exe">NUL
if "%ERRORLEVEL%"=="1" (start Wow.lnk) ELSE echo WoW has been started. Enjoy
timeout 2 >nul



:EOF