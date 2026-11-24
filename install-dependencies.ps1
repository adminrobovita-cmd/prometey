[CmdletBinding()]
param(
    [switch]$SkipWeb,
    [switch]$SkipApi
)

$ErrorActionPreference = "Stop"

# Скрипт должен находиться в корне проекта ПРОМЕТЕЙ:
# C:\projects\prometey\install-dependencies.ps1

$ProjectRoot = $PSScriptRoot

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   PROMETEY - установка зависимостей" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Папка проекта: $ProjectRoot"
Write-Host ""

# Проверяем Node.js и npm
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    throw "Node.js не найден. Установите Node.js LTS с https://nodejs.org/ и перезапустите PowerShell."
}

if (-not (Get-Command npm.cmd -ErrorAction SilentlyContinue)) {
    throw "npm не найден. Переустановите Node.js LTS и перезапустите PowerShell."
}

Write-Host "Node.js: $(node --version)" -ForegroundColor Green
Write-Host "npm:     $(npm.cmd --version)" -ForegroundColor Green

function Install-AppDependencies {
    param(
        [Parameter(Mandatory = $true)]
        [string]$AppName,

        [Parameter(Mandatory = $true)]
        [string]$AppPath
    )

    if (-not (Test-Path (Join-Path $AppPath "package.json"))) {
        throw "Не найден package.json для '$AppName': $AppPath"
    }

    Write-Host ""
    Write-Host "Установка зависимостей: $AppName" -ForegroundColor Yellow

    Push-Location $AppPath
    try {
        if (Test-Path "package-lock.json") {
            Write-Host "Найден package-lock.json — выполняю npm ci..."
            npm.cmd ci
        }
        else {
            Write-Host "package-lock.json не найден — выполняю npm install..."
            npm.cmd install
        }

        if ($LASTEXITCODE -ne 0) {
            throw "Установка зависимостей для '$AppName' завершилась с ошибкой (код $LASTEXITCODE)."
        }

        Write-Host "Зависимости '$AppName' установлены." -ForegroundColor Green
    }
    finally {
        Pop-Location
    }
}

if (-not $SkipApi) {
    Install-AppDependencies -AppName "Backend API" -AppPath (Join-Path $ProjectRoot "apps\api")
}

if (-not $SkipWeb) {
    Install-AppDependencies -AppName "Frontend Web" -AppPath (Join-Path $ProjectRoot "apps\web")
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   УСТАНОВКА ЗАВЕРШЕНА" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "Теперь можно запускать ПРОМЕТЕЙ через start.ps1."
Write-Host ""
