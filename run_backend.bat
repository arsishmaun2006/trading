@echo off
title Atlas AI Trading Terminal - Backend API
echo ===================================================
echo Starting Atlas AI Trading Terminal Backend (FastAPI)
echo ===================================================
cd /d "%~dp0backend"
set PYTHONPATH=%~dp0backend
"C:\Users\arsis\Python311\python.exe" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
pause
