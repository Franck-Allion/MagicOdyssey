[CmdletBinding()]
param(
    [string]$GodotPath = "D:\Temp\Godot_v4.7.2-stable_win64.exe",
    [switch]$UpdateGolden
)

# Resolve repository root relative to this script's directory
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path

if (-not (Test-Path $GodotPath)) {
    Write-Error "Godot executable not found at specified path: $GodotPath"
    exit 2
}

$GodotArgs = @("--path", $RepoRoot, "--script", "res://docs/audits/AUDIT-002/capture_baseline.gd")

if ($UpdateGolden) {
    $GodotArgs += @("--", "--update-golden-baselines")
}

& $GodotPath $GodotArgs | Out-Default
$RunnerExitCode = $LASTEXITCODE

exit $RunnerExitCode
