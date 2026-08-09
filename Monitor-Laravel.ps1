Write-Host "================================================" -ForegroundColor Cyan
Write-Host "   MONITOR LARAVEL - DOCKER"                       -ForegroundColor Cyan
Write-Host "   SPRINT 2 - Laboratorio SO"                      -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

$containers = @("laravel-app", "laravel-mysql", "laravel-redis")
$maxFailures = 3
$failures = 0
$iteration = 0

function Test-ContainerRunning {
    param([string]$name)
    $status = docker inspect -f '{{.State.Running}}' $name 2>$null
    return $status -eq "true"
}

function Show-Status {
    param([string]$label, [bool]$isRunning)
    if ($isRunning) {
        Write-Host "[OK] $label - RUNNING" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "[X]  $label - STOPPED" -ForegroundColor Red
        return $false
    }
}

while ($true) {
    $iteration++
    Clear-Host
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "   MONITOR LARAVEL (DOCKER) - Iteracion #$iteration" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "ESTADO DE CONTENEDORES:" -ForegroundColor Cyan

    $allRunning = $true
    foreach ($c in $containers) {
        $running = Test-ContainerRunning $c
        $ok = Show-Status $c $running
        if (-not $ok) { $allRunning = $false }
    }

    Write-Host ""
    if (-not $allRunning) {
        $failures++
        Write-Host "ERROR: Algun contenedor esta detenido (Intento #$failures)" -ForegroundColor Red
    }
    else {
        $failures = 0
    }

    Write-Host ""
    Write-Host "ESTADISTICAS DE CONTENEDORES (docker stats):" -ForegroundColor Cyan
    try {
        $stats = docker stats --no-stream --format "table {{.Name}}`t{{.CPUPerc}}`t{{.MemPerc}}" 2>$null
        Write-Host $stats -ForegroundColor Green
    }
    catch {
        Write-Host "No se pudieron obtener estadisticas de Docker" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "------------------------------------------------" -ForegroundColor Gray
    Write-Host ("Timestamp: {0}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
    Write-Host "Proxima actualizacion en 10 segundos..." -ForegroundColor Gray
    Write-Host "Presiona Ctrl+C para salir" -ForegroundColor Yellow

    Start-Sleep -Seconds 10
}
