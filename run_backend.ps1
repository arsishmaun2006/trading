# Run Atlas AI Trading Terminal Backend
$Host.UI.RawUI.WindowTitle = "Atlas AI Trading Terminal - Backend"
Write-Host "Starting Atlas AI Trading Terminal Backend on http://127.0.0.1:8000" -ForegroundColor Cyan
$env:PYTHONPATH = "$PSScriptRoot\backend"
& "C:\Users\arsis\Python311\python.exe" -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
