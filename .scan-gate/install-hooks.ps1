[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$missing = $false

if (-not (Get-Command pre-commit -ErrorAction SilentlyContinue)) {
    Write-Host "pre-commit is not installed. Install with: py -m pip install pre-commit" -ForegroundColor Red
    $missing = $true
}

if (-not (Get-Command trufflehog -ErrorAction SilentlyContinue)) {
    Write-Host "trufflehog is not installed or is not visible in PATH." -ForegroundColor Red
    $missing = $true
}

if ($missing) {
    exit 127
}

if (-not (Test-Path ".pre-commit-config.yaml") -and (Test-Path ".pre-commit-config.windows.yaml")) {
    Copy-Item ".pre-commit-config.windows.yaml" ".pre-commit-config.yaml"
    Write-Host "Copied .pre-commit-config.windows.yaml to .pre-commit-config.yaml"
}

pre-commit install --hook-type pre-commit --hook-type pre-push
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

pre-commit install-hooks
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host "Scan gate installed for pre-commit and pre-push."
