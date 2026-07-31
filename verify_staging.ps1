$ErrorActionPreference = "Stop"

# 1. Clear Port 3000 safely (Ignoring PID 0 / System Idle)
$portConns = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
foreach ($conn in $portConns) {
    if ($conn.OwningProcess -gt 0) {
        Write-Host "[WARNING] Clearing active PID $($conn.OwningProcess) on port 3000..." -ForegroundColor Yellow
        Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

# 2. Start Staging Server
Write-Host "[ENGINE] Launching staging server..." -ForegroundColor Cyan
$server = Start-Process node -ArgumentList "server.js" -WorkingDirectory "C:\feelix\deploy_staging" -PassThru
Start-Sleep -Seconds 3

try {
    Write-Host "[TEST] Sending POST payload to /api/contact..." -ForegroundColor Cyan
    $body = @{
        name    = "Staging Auditor"
        email   = "audit@mineralbank.local"
        message = "Testing isolated deploy_staging contact endpoint."
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "http://localhost:3000/api/contact" -Method Post -Body $body -ContentType "application/json"
    
    Write-Host "[SUCCESS] deploy_staging Contact Endpoint Verified!" -ForegroundColor Green
    $response | Format-List
}
catch {
    Write-Host "[FAILURE] Staging Test Failed: $_" -ForegroundColor Red
}
finally {
    if ($server -and -not $server.HasExited) {
        Stop-Process -Id $server.Id -Force -ErrorAction SilentlyContinue
        Write-Host "[CLEANUP] Staging server stopped." -ForegroundColor Yellow
    }
}
