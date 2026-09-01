param(
    [string]$DeviceId = "emulator-5554",
    [string]$ApiBaseUrl = "http://localhost:8080/api/v1"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot

Push-Location $projectRoot
try {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw "Flutter was not found in PATH. Open a Flutter-enabled terminal and try again."
    }

    Write-Host "Running DSMES Mobile against the local backend..."
    Write-Host "API: $ApiBaseUrl"

    # Android emulators cannot reach the host through localhost directly.
    # 10.0.2.2 is the emulator alias for the host machine.
    $runtimeApiBaseUrl = $ApiBaseUrl
    if ($DeviceId -like "emulator-*") {
        $runtimeApiBaseUrl = $ApiBaseUrl -replace "localhost", "10.0.2.2"
        Write-Host "Emulator API: $runtimeApiBaseUrl"
    }

    & flutter run -d $DeviceId --dart-define="BASE_URL=$runtimeApiBaseUrl"
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}
