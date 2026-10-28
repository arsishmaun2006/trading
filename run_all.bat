@echo off
title Atlas AI Trading Terminal - Launcher
echo Launching Atlas AI Trading Terminal...
start "Atlas AI Backend" cmd /k "cd /d %~dp0 && run_backend.bat"
timeout /t 3 /nobreak >nul
start "Atlas AI Frontend" cmd /k "cd /d %~dp0 && run_frontend.bat"
echo Terminal is starting:
echo Backend:  http://127.0.0.1:8000
echo Frontend: http://127.0.0.1:5173
echo.
pause
