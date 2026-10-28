# Launch Atlas AI Trading Terminal (Backend + Frontend)
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "       Launching Atlas AI Trading Terminal Suite         " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "$PSScriptRoot\run_backend.ps1"
Start-Sleep -Seconds 2
Start-Process powershell -ArgumentList "-NoExit", "-ExecutionPolicy", "Bypass", "-File", "$PSScriptRoot\run_frontend.ps1"

Write-Host "Terminal launched successfully!" -ForegroundColor Green
Write-Host "Backend API:  http://127.0.0.1:8000" -ForegroundColor White
Write-Host "Frontend App: http://127.0.0.1:5173" -ForegroundColor White
