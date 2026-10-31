$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
try {
    $msys = if ($env:CW_MSYS2) { $env:CW_MSYS2 } else { Join-Path $root 'tools\msys64' }
    $bash = Join-Path $msys 'usr\bin\bash.exe'
    if (-not (Test-Path $bash)) {
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw 'MSYS2 von https://www.msys2.org installieren und CW_MSYS2 auf dessen Installationsordner setzen. Danach erneut starten.'
        }
        & winget install --id MSYS2.MSYS2 --exact --source winget --location $msys --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path $bash)) {
            throw 'MSYS2 konnte nicht im Paketordner eingerichtet werden. Falls bereits installiert: CW_MSYS2 auf den vorhandenen Installationsordner setzen.'
        }
    }
    $env:MSYSTEM = 'UCRT64'
    $env:CHERE_INVOKING = '1'
    $env:CW_BUILD_ROOT = $root
    & $bash -lc 'pacman -Syu --noconfirm'
    if ($LASTEXITCODE -ne 0) { throw 'MSYS2-Aktualisierung unterbrochen (bei Basisupdates moeglich). NANO_BUILD.cmd erneut starten.' }
    & $bash -lc 'pacman -S --needed --noconfirm make mingw-w64-ucrt-x86_64-arm-none-eabi-gcc mingw-w64-ucrt-x86_64-arm-none-eabi-newlib'
    if ($LASTEXITCODE -ne 0) { throw 'Compiler-Installation fehlgeschlagen.' }
    & $bash -lc 'set -eu; export PATH=/ucrt64/bin:/usr/bin:$PATH; cd "$(cygpath -u "$CW_BUILD_ROOT")/firmware/mcu/simpleserial-aes"; arm-none-eabi-gcc --version; make OS=MSYS PLATFORM=CWNANO CRYPTO_TARGET=TINYAES128C SS_VER=SS_VER_1_1; test -s simpleserial-aes-CWNANO.hex; echo "Fertig: simpleserial-aes-CWNANO.hex (kein automatisches Flashen)."'
    if ($LASTEXITCODE -ne 0) { throw 'Nano-Firmware-Build fehlgeschlagen. Ausgabe oben beachten.' }
} catch {
    Write-Host $_ -ForegroundColor Red
    exit 1
}
