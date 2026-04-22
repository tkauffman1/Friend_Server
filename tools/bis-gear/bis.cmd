@echo off
setlocal EnableExtensions
REM Run bis.sh under Git Bash. Always use this on Windows (not double-click bis.sh).
REM Usage:
REM   bis.cmd -c "protection paladin" -n YourCharacterName

set "HERE=%~dp0"

if "%~1"=="" (
  echo.
  echo Usage: bis.cmd -c "protection paladin" -n YourCharacterName
  echo.
  echo Or PowerShell:  powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%Generate-BisMail.ps1" -Class "protection paladin" -Name YourCharacterName
  echo.
  pause
  exit /b 2
)

set "BASH="
if exist "%ProgramFiles%\Git\bin\bash.exe" set "BASH=%ProgramFiles%\Git\bin\bash.exe"
if not defined BASH if exist "%ProgramFiles(x86)%\Git\bin\bash.exe" set "BASH=%ProgramFiles(x86)%\Git\bin\bash.exe"

if not defined BASH (
  echo.
  echo [ERROR] Git Bash not found. Install Git for Windows, or run PowerShell instead:
  echo   powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%Generate-BisMail.ps1" -Class "protection paladin" -Name YourChar
  echo.
  pause
  exit /b 1
)

pushd "%HERE%"
"%BASH%" "%HERE%bis.sh" %*
set ERR=%ERRORLEVEL%
popd

echo.
echo Exit code: %ERR%
echo Full log ^(same output as above^): "%HERE%bis-last-run.log"
echo.
if %ERR% neq 0 (
  echo This script only WRITES a .sql file under sql\generated. Items appear in-game AFTER you run that SQL on your characters database.
)
pause
exit /b %ERR%
