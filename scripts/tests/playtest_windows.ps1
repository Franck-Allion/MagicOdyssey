[CmdletBinding()]
param([string]$Executable = 'build/windows/MagicOdyssey.exe', [switch]$EditorPreview)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class PreviewDesktop {
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct Point { public int X, Y; }
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hwnd, out Rect rect);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hwnd, ref Point point);
    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int index);
    [DllImport("user32.dll")] public static extern void keybd_event(byte key, byte scan, uint flags, UIntPtr extra);
}
'@
[PreviewDesktop]::SetProcessDPIAware() | Out-Null
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$outDir = Join-Path $repoRoot 'docs/art/reviews/p005-r02'
$sourceExe = (Resolve-Path -LiteralPath $Executable).Path
# Copy only the embedded executable: prove independence from project resources/editor.
$testDir = Join-Path $env:TEMP ('MagicOdyssey-standalone-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testDir | Out-Null
$testExe = Join-Path $testDir 'MagicOdyssey.exe'
Copy-Item -LiteralPath $sourceExe -Destination $testExe
Write-Output "Isolated executable: $testExe"
Write-Output "Physical desktop: $([PreviewDesktop]::GetSystemMetrics(0))x$([PreviewDesktop]::GetSystemMetrics(1))"
$modes = @('default', '1920x1080', '1280x720')
if ($EditorPreview) { $modes = @('editor-preview') }
foreach ($mode in $modes) {
    $logPath = Join-Path $outDir ('desktop-' + $mode + '.log')
    if (Test-Path -LiteralPath $logPath) { Remove-Item -LiteralPath $logPath }
    $start = New-Object System.Diagnostics.ProcessStartInfo
    $start.FileName = $testExe
    if ($EditorPreview) { $start.FileName = $sourceExe }
    $start.WorkingDirectory = $testDir
    $start.UseShellExecute = $true
    # Shell execution uses the Windows executable association, as Explorer does.
    $start.Arguments = '--log-file "' + $logPath + '"'
    if ($EditorPreview) { $start.Arguments += ' --path "' + $repoRoot + '" res://scenes/combat/combat_preview.tscn' }
    elseif ($mode -ne 'default') { $start.Arguments += " -- --preview-size=$mode" }
    $process = [System.Diagnostics.Process]::Start($start)
    try {
        $deadline = [DateTime]::UtcNow.AddSeconds(30)
        $ready = $false
        while ([DateTime]::UtcNow -lt $deadline -and -not $process.HasExited) {
            if ((Test-Path -LiteralPath $logPath) -and (Select-String -LiteralPath $logPath -Pattern '^COMBAT_PREVIEW_READY$' -Quiet)) { $ready = $true; break }
            Start-Sleep -Milliseconds 200
        }
        if (-not $ready) { throw "Scene did not render within 30 seconds: $mode" }
        Start-Sleep -Milliseconds 800
        $process.Refresh()
        if ($process.HasExited -or $process.MainWindowHandle -eq [IntPtr]::Zero) { throw "No game window: $mode" }
        [PreviewDesktop]::SetForegroundWindow($process.MainWindowHandle) | Out-Null
        Start-Sleep -Milliseconds 400
        $rect = New-Object PreviewDesktop+Rect
        $point = New-Object PreviewDesktop+Point
        [PreviewDesktop]::GetClientRect($process.MainWindowHandle, [ref]$rect) | Out-Null
        [PreviewDesktop]::ClientToScreen($process.MainWindowHandle, [ref]$point) | Out-Null
        $width = $rect.Right - $rect.Left
        $height = $rect.Bottom - $rect.Top
        Write-Output "$mode : title=$($process.MainWindowTitle), client=${width}x${height}, pid=$($process.Id)"
        if ($mode -match '^\d+x\d+$' -and "${width}x${height}" -ne $mode) { throw "Wrong client size for $mode" }
        if ($point.X -lt 0 -or $point.Y -lt 0 -or ($point.X + $width) -gt [PreviewDesktop]::GetSystemMetrics(0) -or ($point.Y + $height) -gt [PreviewDesktop]::GetSystemMetrics(1)) {
            throw "Window outside physical desktop; cannot verify full client: $mode"
        }
        $bitmap = New-Object System.Drawing.Bitmap($width, $height)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.CopyFromScreen($point.X, $point.Y, 0, 0, $bitmap.Size)
            $bitmap.Save((Join-Path $outDir ('desktop-' + $mode + '.png')))
        } finally { $graphics.Dispose(); $bitmap.Dispose() }
        [PreviewDesktop]::keybd_event(0x1B, 0, 0, [UIntPtr]::Zero)
        [PreviewDesktop]::keybd_event(0x1B, 0, 2, [UIntPtr]::Zero)
        if (-not $process.WaitForExit(5000)) { throw "ESC failed to exit: $mode" }
        if ($process.ExitCode -ne 0) { throw "Unexpected exit $($process.ExitCode): $mode" }
        Write-Output "$mode : ESC exit=$($process.ExitCode)"
        if (Select-String -LiteralPath $logPath -Pattern 'ERROR|WARNING|SCRIPT ERROR' -Quiet) { throw "Godot warning/error: $logPath" }
    } finally {
        if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit(); Write-Output 'Failed playtest process cleaned up' }
        $process.Dispose()
    }
}
$remaining = @(Get-Process -Name MagicOdyssey -ErrorAction SilentlyContinue)
if ($remaining.Count -ne 0) { throw 'MagicOdyssey processes remain' }
Write-Output "PASS: shell launch, $($modes.Count) desktop windows, ESC exits with code 0, no remaining game process."
