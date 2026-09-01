param(
    [string]$DeviceId = "emulator-5554"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $projectRoot ".env.staging.local"

Push-Location $projectRoot
try {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw "Flutter was not found in PATH. Open a Flutter-enabled terminal and try again."
    }
    if (-not (Test-Path $envFile)) {
        throw "Missing environment file: $envFile"
    }

    Write-Host "Running DSMES Mobile against staging..."
    & flutter run -d $DeviceId --dart-define-from-file=$envFile
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}
