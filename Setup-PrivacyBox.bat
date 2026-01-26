@echo off
:: Privacy Box - One-Click Launcher
:: Just double-click this file to start setup!

echo.
echo   Starting Privacy Box Setup...
echo.

:: Run PowerShell script with execution policy bypass
powershell -ExecutionPolicy Bypass -File "%~dp0privacy-box-setup.ps1"

pause
