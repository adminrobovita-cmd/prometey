
$ErrorActionPreference = "Continue"

$ProjectRoot = $PSScriptRoot

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "       PROMETEY - STOP CENTER" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Остановка Frontend и Backend
Write-Host "[1/2] Stopping Frontend and Backend..." -ForegroundColor Yellow

foreach ($Port in @(5173, 3000)) {

    $Connections = Get-NetTCPConnection `
        -LocalPort $Port `
        -State Listen `
        -ErrorAction SilentlyContinue

    foreach ($Connection in $Connections) {

        $ProcessId = $Connection.OwningProcess

        if ($ProcessId -gt 0) {
            Stop-Process -Id $ProcessId -Force `
                -ErrorAction SilentlyContinue

            Write-Host "Stopped process on port $Port (PID: $ProcessId)" -ForegroundColor Green
        }
    }
}

# Остановка PostgreSQL
Write-Host ""
Write-Host "[2/2] Stopping PostgreSQL..." -ForegroundColor Yellow

docker compose -f "$ProjectRoot\docker-compose.yml" stop postgres

if ($LASTEXITCODE -eq 0) {
    Write-Host "PostgreSQL stopped successfully!" -ForegroundColor Green
}
else {
    Write-Host "Could not stop PostgreSQL. Check Docker Desktop." -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "       PROMETEY STOPPED!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""

Read-Host "Press Enter to close"
