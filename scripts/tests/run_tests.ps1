[CmdletBinding()]
param(
    [string]$GodotPath = "D:\Temp\Godot_v4.7.2-stable_win64.exe",
    [switch]$FailureMode
)

# Resolve repository root relative to this script's directory
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

if (-not (Test-Path $GodotPath)) {
    Write-Error "Godot executable not found at specified path: $GodotPath"
    exit 2
}

$GodotArgs = @("--headless", "--path", $RepoRoot, "--script", "res://scripts/tests/test_runner.gd")

if ($FailureMode) {
    $GodotArgs += @("--", "--test-failure-mode")
}

# Run Godot headlessly and capture standard output while waiting for completion
& $GodotPath $GodotArgs | Out-Default
$RunnerExitCode = $LASTEXITCODE

exit $RunnerExitCode
