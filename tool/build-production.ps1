$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $projectRoot ".env.production.local"

Push-Location $projectRoot
try {
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        throw "Flutter was not found in PATH. Open a Flutter-enabled terminal and try again."
    }
    if (-not (Test-Path $envFile)) {
        throw "Missing environment file: $envFile"
    }

    Write-Host "Building DSMES Mobile production APK..."
    & flutter build apk --release --dart-define-from-file=$envFile
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    Write-Host "APK: build/app/outputs/flutter-apk/app-release.apk"
}
finally {
    Pop-Location
}
