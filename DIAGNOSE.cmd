@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows-ready\Start.ps1" -Diagnose
pause
