[CmdletBinding()]
param([string]$Executable = 'build/windows/MagicOdyssey-P008-F03B-baseline.exe')
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type @'
using System;
using System.Runtime.InteropServices;
public static class F04Desktop {
    [StructLayout(LayoutKind.Sequential)] public struct Rect { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)] public struct Point { public int X, Y; }
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hwnd);
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hwnd, IntPtr after, int x, int y, int w, int h, uint flags);
    [DllImport("user32.dll")] public static extern IntPtr WindowFromPoint(Point point);
    [DllImport("user32.dll")] public static extern IntPtr GetAncestor(IntPtr hwnd, uint flags);
    [DllImport("user32.dll")] public static extern void mouse_event(uint flags, int dx, int dy, int data, UIntPtr extra);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hwnd, out Rect rect);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hwnd, ref Point point);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void keybd_event(byte key, byte scan, uint flags, UIntPtr extra);
}
'@
[F04Desktop]::SetProcessDPIAware() | Out-Null
$outDir = $PSScriptRoot
$sourceExe = (Resolve-Path -LiteralPath $Executable).Path
$testDir = Join-Path $env:TEMP ('MagicOdyssey-F04-before-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testDir | Out-Null
$testExe = Join-Path $testDir 'MagicOdyssey.exe'
Copy-Item -LiteralPath $sourceExe -Destination $testExe
$logPath = Join-Path $outDir 'windows-before-720p.log'
if (Test-Path -LiteralPath $logPath) { Remove-Item -LiteralPath $logPath }
$start = New-Object System.Diagnostics.ProcessStartInfo
$start.FileName = $testExe
$start.WorkingDirectory = $testDir
$start.UseShellExecute = $true
$start.Arguments = '--log-file "' + $logPath + '" -- --preview-tokens=full_board --preview-size=1280x720 --preview-hand=10 --preview-slots --preview-utility'
$process = [System.Diagnostics.Process]::Start($start)
try {
    $deadline = [DateTime]::UtcNow.AddSeconds(30)
    while (-not (Test-Path -LiteralPath $logPath) -or -not (Select-String -LiteralPath $logPath -Pattern '^COMBAT_PREVIEW_READY$' -Quiet)) {
        if ([DateTime]::UtcNow -gt $deadline -or $process.HasExited) { throw 'Baseline did not render' }
        Start-Sleep -Milliseconds 200
    }
    $process.Refresh()
    [F04Desktop]::SetForegroundWindow($process.MainWindowHandle) | Out-Null
    [F04Desktop]::SetCursorPos(0,0) | Out-Null
    Start-Sleep -Milliseconds 700
    $rect = New-Object F04Desktop+Rect
    $point = New-Object F04Desktop+Point
    [F04Desktop]::GetClientRect($process.MainWindowHandle,[ref]$rect) | Out-Null
    [F04Desktop]::ClientToScreen($process.MainWindowHandle,[ref]$point) | Out-Null
    if ($rect.Right -ne 1280 -or $rect.Bottom -ne 720) { throw 'Baseline client is not native 1280x720' }
    if ([F04Desktop]::GetForegroundWindow() -ne $process.MainWindowHandle) {
        [F04Desktop]::SetWindowPos($process.MainWindowHandle,[IntPtr](-1),0,0,0,0,0x0053) | Out-Null
        Start-Sleep -Milliseconds 300
        $focusPoint = New-Object F04Desktop+Point
        $focusPoint.X = $point.X + 1270
        $focusPoint.Y = $point.Y + 710
        if ([F04Desktop]::GetAncestor([F04Desktop]::WindowFromPoint($focusPoint),2) -ne $process.MainWindowHandle) { throw 'Baseline window is occluded; refusing OS input' }
        [F04Desktop]::SetCursorPos($focusPoint.X,$focusPoint.Y) | Out-Null
        [F04Desktop]::mouse_event(0x0002,0,0,0,[UIntPtr]::Zero)
        [F04Desktop]::mouse_event(0x0004,0,0,0,[UIntPtr]::Zero)
        Start-Sleep -Milliseconds 300
    }
    if ([F04Desktop]::GetForegroundWindow() -ne $process.MainWindowHandle) { throw 'Baseline has no foreground; refusing OS input' }
    $bitmap = New-Object System.Drawing.Bitmap(1280,720)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.CopyFromScreen($point.X,$point.Y,0,0,$bitmap.Size)
        $bitmap.Save((Join-Path $outDir 'windows-before-720p.png'))
    } finally { $graphics.Dispose(); $bitmap.Dispose() }
    if ([F04Desktop]::GetForegroundWindow() -ne $process.MainWindowHandle) { throw 'Baseline lost foreground; refusing ESC' }
    [F04Desktop]::keybd_event(0x1B,0,0,[UIntPtr]::Zero)
    [F04Desktop]::keybd_event(0x1B,0,2,[UIntPtr]::Zero)
    if (-not $process.WaitForExit(5000) -or $process.ExitCode -ne 0) { throw 'Baseline ESC exit failed' }
    if (Select-String -LiteralPath $logPath -Pattern 'ERROR|WARNING' -Quiet) { throw 'Baseline warning/error' }
    Write-Output 'PASS: isolated previous executable, native 1280x720 OS capture, ESC exit 0.'
} finally {
    if (-not $process.HasExited) { $process.Kill(); $process.WaitForExit() }
    $process.Dispose()
}
