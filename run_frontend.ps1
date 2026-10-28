# Run Atlas AI Trading Terminal Frontend
$Host.UI.RawUI.WindowTitle = "Atlas AI Trading Terminal - Frontend"
Write-Host "Starting Atlas AI Trading Terminal Frontend on http://127.0.0.1:5173" -ForegroundColor Cyan
Set-Location -Path "$PSScriptRoot\frontend"
npm.cmd run dev
