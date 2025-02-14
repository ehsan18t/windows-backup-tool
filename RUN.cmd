@ECHO OFF
TITLE Windows Backup Tool Runner
PowerShell -NoProfile -ExecutionPolicy Bypass -File "Compile.ps1"
PowerShell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "App.ps1"
DEL "App.ps1"
@REM PAUSE