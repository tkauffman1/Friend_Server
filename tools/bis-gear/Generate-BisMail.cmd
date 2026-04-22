@echo off
setlocal EnableExtensions
set "HERE=%~dp0"

if "%~1"=="" (
  echo.
  echo Usage: Generate-BisMail.cmd -Class "protection paladin" -Name YourCharacterName
  echo   Or use bis.cmd with the same -c / -n flags if you have Git Bash.
  echo.
  pause
  exit /b 2
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%HERE%Generate-BisMail.ps1" %*
set ERR=%ERRORLEVEL%
echo.
echo Exit code: %ERR%
pause
exit /b %ERR%
