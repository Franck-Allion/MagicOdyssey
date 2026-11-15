[CmdletBinding()]
param([string]$GodotPath = 'D:\Temp\Godot_v4.7.2-stable_win64_console.exe')
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
if (-not (Test-Path -LiteralPath $GodotPath)) { throw "Godot not found: $GodotPath" }
$presetFile = Get-Content -LiteralPath (Join-Path $repoRoot 'export_presets.cfg') -Raw
if ($presetFile -notmatch '(?m)^name="Windows Desktop"$') { throw 'Windows Desktop preset missing' }
New-Item -ItemType Directory -Force -Path (Join-Path $repoRoot 'build/windows') | Out-Null
& $GodotPath --headless --path $repoRoot --export-release 'Windows Desktop' build/windows/MagicOdyssey.exe
$exportCode = $LASTEXITCODE
if ($exportCode -ne 0) { exit $exportCode }
$executable = Join-Path $repoRoot 'build/windows/MagicOdyssey.exe'
if (-not (Test-Path -LiteralPath $executable)) { throw 'Export returned success without an executable' }
Write-Output "Built: $executable"
exit 0
