@echo off
REM Simple wrapper to call the PowerShell keystore creator
powershell -ExecutionPolicy Bypass -File "%~dp0create_keystore.ps1"
