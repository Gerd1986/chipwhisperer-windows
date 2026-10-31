param([switch]$Diagnose)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
function Run($exe, $arguments) {
    & $exe @arguments
    if ($LASTEXITCODE -ne 0) { throw "Fehler ($LASTEXITCODE): $exe $arguments" }
}
try {
    # Resolve an installed interpreter, never create an environment.
    $probe = 'import sys; print(sys.executable)'
    if ($env:CW_PYTHON) {
        $python = $env:CW_PYTHON
    } elseif (Get-Command py -ErrorAction SilentlyContinue) {
        $python = & py -3 -c $probe
        if ($LASTEXITCODE -ne 0) { throw 'Python Launcher findet kein Python 3.' }
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        $python = & python -c $probe
        if ($LASTEXITCODE -ne 0) { throw 'Python konnte nicht gestartet werden.' }
    } else {
        throw 'Bitte Python >= 3.11 (64 Bit) installieren, inklusive Python Launcher oder PATH-Eintrag.'
    }
    Run $python @('-c', 'import sys,struct,site; assert sys.version_info >= (3,11), "Python >= 3.11 erforderlich"; assert struct.calcsize("P")==8, "64-Bit-Python erforderlich"; assert sys.prefix == sys.base_prefix, "Bitte eine normale Python-Installation ueber CW_PYTHON auswaehlen"; assert site.ENABLE_USER_SITE, "Python-Benutzerpakete sind deaktiviert"')
    Write-Host "Python: $python"
    if ($Diagnose) {
        Run $python @((Join-Path $PSScriptRoot 'diagnose.py'))
        exit 0
    }
    $marker = Join-Path $PSScriptRoot 'setup-python.txt'
    $identity = & $python -c 'import sys; print(sys.executable + "|" + sys.version)'
    if ($LASTEXITCODE -ne 0) { throw 'Python-Version konnte nicht ermittelt werden.' }
    $ready = (Test-Path $marker) -and ((Get-Content $marker -Raw).Trim() -eq $identity.Trim())
    if ($ready) {
        & $python -c 'import chipwhisperer,jupyterlab,ipywidgets,matplotlib,scipy,bokeh,pandas,holoviews' 2>$null
        $ready = ($LASTEXITCODE -eq 0)
    }
    if (-not $ready) {
        Run $python @('-m', 'pip', 'install', '--user', '-e', $root, 'jupyterlab', 'ipywidgets', 'matplotlib', 'scipy', 'bokeh', 'pandas', 'holoviews')
        Run $python @('-m', 'pip', 'check')
        Run $python @('-c', 'import chipwhisperer,jupyterlab,ipywidgets,matplotlib,scipy,bokeh,pandas,holoviews; print(chipwhisperer.__version__)')
        Set-Content $marker $identity
    }
    Write-Host 'ChipWhisperer startet. Dieses Fenster offen lassen; Beenden mit Strg+C.'
    Run $python @('-m', 'jupyterlab', '--ServerApp.ip=127.0.0.1', "--ServerApp.root_dir=$root")
} catch {
    Write-Host $_ -ForegroundColor Red
    Read-Host 'Enter zum Schliessen'
    exit 1
}
