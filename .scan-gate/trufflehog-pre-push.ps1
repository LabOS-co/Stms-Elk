[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

if (-not (Get-Command trufflehog -ErrorAction SilentlyContinue)) {
    [Console]::Error.WriteLine("trufflehog is required but was not found in PATH.")
    [Console]::Error.WriteLine("Install it from https://docs.trufflesecurity.com/pre-commit-hooks and retry.")
    exit 127
}

$zeroRef = "0000000000000000000000000000000000000000"
$fromRef = $env:PRE_COMMIT_FROM_REF
$baseRef = $null

if ($fromRef -and $fromRef -ne $zeroRef) {
    & git cat-file -e "$fromRef^{commit}" 2>$null
    if ($LASTEXITCODE -eq 0) {
        $baseRef = $fromRef
    }
}

if (-not $baseRef) {
    $rootCommits = @(& git rev-list --max-parents=0 HEAD)
    if ($LASTEXITCODE -ne 0 -or $rootCommits.Count -eq 0) {
        [Console]::Error.WriteLine("Unable to determine base commit for pre-push scan.")
        exit 1
    }
    $baseRef = $rootCommits[-1]
}

Write-Host "Running TruffleHog git scan since $baseRef..."

& trufflehog git file://. `
    --config .trufflehog.yaml `
    --since-commit "$baseRef" `
    --results=verified,unknown,unverified `
    --fail `
    --no-update

exit $LASTEXITCODE
