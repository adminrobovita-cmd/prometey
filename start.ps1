
$ErrorActionPreference = "Stop"

$ProjectRoot = $PSScriptRoot
$ApiPath = Join-Path $ProjectRoot "apps\api"
$WebPath = Join-Path $ProjectRoot "apps\web"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "       PROMETEY - START CENTER" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Проверка файлов проекта
if (!(Test-Path "$ProjectRoot\docker-compose.yml")) {
    Write-Host "ERROR: docker-compose.yml not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

if (!(Test-Path "$ApiPath\package.json") -or
    !(Test-Path "$WebPath\package.json")) {
    Write-Host "ERROR: Application files not found!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# Проверка Docker
Write-Host "[1/4] Checking Docker..." -ForegroundColor Yellow

docker info *> $null

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker is not running!" -ForegroundColor Red
    Write-Host "Start Docker Desktop and run this script again."
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Docker is ready!" -ForegroundColor Green

# Запуск PostgreSQL
Write-Host ""
Write-Host "[2/4] Starting PostgreSQL..." -ForegroundColor Yellow

docker compose -f "$ProjectRoot\docker-compose.yml" up -d --wait postgres

if ($LASTEXITCODE -ne 0) {
    Write-Host "PostgreSQL startup failed!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "PostgreSQL is ready!" -ForegroundColor Green

# Проверка портов
function Test-PortInUse($Port) {
    return [bool](Get-NetTCPConnection -LocalPort $Port `
        -State Listen -ErrorAction SilentlyContinue)
}

# Запуск Backend
Write-Host ""
Write-Host "[3/4] Starting Backend..." -ForegroundColor Yellow

if (!(Test-PortInUse 3000)) {
    Start-Process powershell.exe `
        -WorkingDirectory $ApiPath `
        -ArgumentList @(
            "-NoExit",
            "-Command",
            "Write-Host 'PROMETEY BACKEND' -ForegroundColor Cyan; npm.cmd run start:dev"
        )
    Write-Host "Backend started!" -ForegroundColor Green
}
else {
    Write-Host "Backend already running on port 3000." -ForegroundColor Yellow
}

# Запуск Frontend
Write-Host ""
Write-Host "[4/4] Starting Frontend..." -ForegroundColor Yellow

if (!(Test-PortInUse 5173)) {
    Start-Process powershell.exe `
        -WorkingDirectory $WebPath `
        -ArgumentList @(
            "-NoExit",
            "-Command",
            "Write-Host 'PROMETEY FRONTEND' -ForegroundColor Cyan; npm.cmd run dev"
        )
    Write-Host "Frontend started!" -ForegroundColor Green
}
else {
    Write-Host "Frontend already running on port 5173." -ForegroundColor Yellow
}

# Открываем интерфейс
Start-Sleep -Seconds 3

Start-Process "http://localhost:5173"

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "       PROMETEY STARTED!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Frontend: http://localhost:5173"
Write-Host "Backend:  http://localhost:3000"
Write-Host "Database: localhost:5432"
Write-Host ""

Read-Host "Press Enter to close this window"
