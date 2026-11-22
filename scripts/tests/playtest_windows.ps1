[CmdletBinding()]
param([string]$Executable = 'build/windows/MagicOdyssey.exe', [string]$ReviewDir = 'docs/art/reviews/p005-r05', [switch]$EditorPreview, [ValidateRange(0,10)][int]$HandCount = 10, [switch]$AnimateResources, [switch]$UtilityHud, [double]$UtilityButtonY = 915.73, [switch]$BattlefieldSlots, [ValidateSet("", "empty", "single", "full_board")][string]$TokenScenario = "")
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
    [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hwnd, IntPtr after, int x, int y, int w, int h, uint flags);
    [DllImport("user32.dll")] public static extern IntPtr WindowFromPoint(Point point);
    [DllImport("user32.dll")] public static extern IntPtr GetAncestor(IntPtr hwnd, uint flags);
    [DllImport("user32.dll")] public static extern bool GetClientRect(IntPtr hwnd, out Rect rect);
    [DllImport("user32.dll")] public static extern bool ClientToScreen(IntPtr hwnd, ref Point point);
    [DllImport("user32.dll")] public static extern int GetSystemMetrics(int index);
    [DllImport("user32.dll")] public static extern void keybd_event(byte key, byte scan, uint flags, UIntPtr extra);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int X, int Y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint dwFlags, int dx, int dy, int dwData, UIntPtr dwExtraInfo);
}
'@
[PreviewDesktop]::SetProcessDPIAware() | Out-Null
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$outDir = Join-Path $repoRoot $ReviewDir
if (-not (Test-Path -LiteralPath $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
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
    if (-not $EditorPreview) {
        if ($mode -eq 'default') { $start.Arguments += ' --' }
        $start.Arguments += " --preview-hand=$HandCount"
        if ($AnimateResources) { $start.Arguments += ' --preview-animate' }
        if ($UtilityHud) { $start.Arguments += ' --preview-utility' }
        if ($BattlefieldSlots) { $start.Arguments += ' --preview-slots' }
        if ($TokenScenario) { $start.Arguments += " --preview-tokens=$TokenScenario" }
    }
    $process = [System.Diagnostics.Process]::Start($start)
    try {
        $deadline = [DateTime]::UtcNow.AddSeconds(30)
        $ready = $false
        while ([DateTime]::UtcNow -lt $deadline -and -not $process.HasExited) {
            if ((Test-Path -LiteralPath $logPath) -and (Select-String -LiteralPath $logPath -Pattern '^COMBAT_PREVIEW_READY$' -Quiet)) { $ready = $true; break }
            Start-Sleep -Milliseconds 200
        }
        if (-not $ready) { throw "Scene did not render within 30 seconds: $mode" }
        if ($TokenScenario -and -not (Select-String -LiteralPath $logPath -SimpleMatch "TOKEN_REVIEW_READY $TokenScenario" -Quiet)) { throw "Token fixture not confirmed: $TokenScenario / $mode" }
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
        # A refused foreground request must never send test input to another app.
        # Raise only this test window, then use a verified native click to focus it.
        if ([PreviewDesktop]::GetForegroundWindow() -ne $process.MainWindowHandle) {
            [PreviewDesktop]::SetWindowPos($process.MainWindowHandle, [IntPtr](-1), 0, 0, 0, 0, 0x0053) | Out-Null
            Start-Sleep -Milliseconds 300
            $focusPoint = New-Object PreviewDesktop+Point
            $focusPoint.X = $point.X + $width - 10
            $focusPoint.Y = $point.Y + $height - 10
            $underPointer = [PreviewDesktop]::GetAncestor([PreviewDesktop]::WindowFromPoint($focusPoint), 2)
            if ($underPointer -ne $process.MainWindowHandle) { throw 'Test window is occluded; refusing OS input' }
            [PreviewDesktop]::SetCursorPos($focusPoint.X, $focusPoint.Y) | Out-Null
            [PreviewDesktop]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
            [PreviewDesktop]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
            Start-Sleep -Milliseconds 300
        }
        $assertForeground = {
            if ([PreviewDesktop]::GetForegroundWindow() -ne $process.MainWindowHandle) { throw 'Test window lost foreground; refusing OS input' }
        }
        & $assertForeground
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
        # Real Windows pointer hover verification across player hand
        if (-not $EditorPreview) {
            $scale = [Math]::Min($width / 1920.0, $height / 1080.0)
            $gameW = 1920.0 * $scale
            $gameH = 1080.0 * $scale
            $offsetX = ($width - $gameW) * 0.5
            $offsetY = ($height - $gameH) * 0.5
            $scrW = [PreviewDesktop]::GetSystemMetrics(0)
            $scrH = [PreviewDesktop]::GetSystemMetrics(1)

            # Helper scriptblock for screen coordinates from 1920x1080 reference
            $refToScreen = {
                param([double]$rx, [double]$ry)
                $sx = $point.X + [int]($offsetX + $rx * $scale)
                $sy = $point.Y + [int]($offsetY + $ry * $scale)
                return @($sx, $sy)
            }

            $sendMouseMove = {
                param([int]$sx, [int]$sy)
                & $assertForeground
                [PreviewDesktop]::SetCursorPos($sx, $sy) | Out-Null
                $nx = [int]($sx * 65535.0 / [Math]::Max(1, $scrW - 1))
                $ny = [int]($sy * 65535.0 / [Math]::Max(1, $scrH - 1))
                [PreviewDesktop]::mouse_event(0x8001, $nx, $ny, 0, [UIntPtr]::Zero)
            }

            if ($BattlefieldSlots) {
                $captureSlot = {
                    param([string]$name)
                    $slotBmp = New-Object System.Drawing.Bitmap($width, $height)
                    $slotG = [System.Drawing.Graphics]::FromImage($slotBmp)
                    try {
                        $slotG.CopyFromScreen($point.X, $point.Y, 0, 0, $slotBmp.Size)
                        $slotBmp.Save((Join-Path $outDir ("desktop-$mode-$name.png")))
                    } finally { $slotG.Dispose(); $slotBmp.Dispose() }
                }
                $slotClick = {
                    & $assertForeground
                    [PreviewDesktop]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero)
                    Start-Sleep -Milliseconds 50
                    [PreviewDesktop]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero)
                    Start-Sleep -Milliseconds 160
                }
                $neutral = & $refToScreen 960 500
                & $sendMouseMove $neutral[0] $neutral[1]
                Start-Sleep -Milliseconds 250
                # Windows can deny SetForegroundWindow to a background launcher.
                # A real click in the empty divider activates the game first.
                & $slotClick
                $countBefore = @(Select-String -LiteralPath $logPath -Pattern '^SLOT_CLICK ').Count
                $rowSpecs = @(@(1,1,282), @(1,0,418), @(0,0,582), @(0,1,718))
                foreach ($rowSpec in $rowSpecs) {
                    $camp = $rowSpec[0]; $row = $rowSpec[1]; $ry = $rowSpec[2]
                    foreach ($column in 1..6) {
                        $slotPoint = & $refToScreen (561 + ($column - 1) * 180) $ry
                        & $sendMouseMove $slotPoint[0] $slotPoint[1]
                        Start-Sleep -Milliseconds 180
                        if (-not (Select-String -LiteralPath $logPath -SimpleMatch "SLOT_ENTER $camp $column $row" -Quiet)) { throw "Slot hover missing: $mode / $camp $column $row" }
                        if ($column -in @(1,6)) { & $captureSlot "hover-c$camp-r$row-n$column" }
                        & $slotClick
                        $latest = (Select-String -LiteralPath $logPath -Pattern '^SLOT_CLICK ' | Select-Object -Last 1).Line
                        if ($latest -ne "SLOT_CLICK $camp $column $row SELECTED $camp $column $row") { throw "Wrong selection: $latest" }
                    }
                }
                $clickCount = @(Select-String -LiteralPath $logPath -Pattern '^SLOT_CLICK ').Count
                if ($clickCount - $countBefore -ne 24) { throw "Duplicate or missing slot clicks: $mode" }
                & $slotClick
                if ((Select-String -LiteralPath $logPath -Pattern '^SLOT_CLICK ' | Select-Object -Last 1).Line -ne 'SLOT_CLICK 0 6 1 SELECTED NONE') { throw 'Selection toggle failed' }
                foreach ($target in @(@(0,3,0,921,582,'player-attack'), @(1,1,1,561,282,'opponent-defense'))) {
                    $slotPoint = & $refToScreen $target[3] $target[4]
                    & $sendMouseMove $slotPoint[0] $slotPoint[1]
                    Start-Sleep -Milliseconds 200
                    & $captureSlot ("hover-" + $target[5])
                    & $slotClick
                    & $captureSlot ("selected-" + $target[5])
                }
                & $slotClick
                $clicksAfterBoard = @(Select-String -LiteralPath $logPath -Pattern '^SLOT_CLICK ').Count
                Write-Output "$mode : all 24 OS pointer hover/click identities PASS; eight row extremes captured; selection switch/toggle PASS"
            }

            # 1. Hover leftmost card (Card 0 exposed mana: refX=386, refY=830)
            $c0 = & $refToScreen 386.0 830.0
            & $sendMouseMove $c0[0] $c0[1]
            Start-Sleep -Milliseconds 320
            $hoverLeftBmp = New-Object System.Drawing.Bitmap($width, $height)
            $hoverLeftG = [System.Drawing.Graphics]::FromImage($hoverLeftBmp)
            try {
                $hoverLeftG.CopyFromScreen($point.X, $point.Y, 0, 0, $hoverLeftBmp.Size)
                $hoverLeftBmp.Save((Join-Path $outDir ("desktop-$mode-hover-left.png")))
            } finally { $hoverLeftG.Dispose(); $hoverLeftBmp.Dispose() }

            # 2. Hover center card (Card 4: refX=904, refY=880)
            $cMid = & $refToScreen 904.0 880.0
            & $sendMouseMove $cMid[0] $cMid[1]
            Start-Sleep -Milliseconds 320
            $hoverCenterBmp = New-Object System.Drawing.Bitmap($width, $height)
            $hoverCenterG = [System.Drawing.Graphics]::FromImage($hoverCenterBmp)
            try {
                $hoverCenterG.CopyFromScreen($point.X, $point.Y, 0, 0, $hoverCenterBmp.Size)
                $hoverCenterBmp.Save((Join-Path $outDir ("desktop-$mode-hover-center.png")))
            } finally { $hoverCenterG.Dispose(); $hoverCenterBmp.Dispose() }

            if ($BattlefieldSlots) {
                $handPoint = & $refToScreen 960 900
                & $sendMouseMove $handPoint[0] $handPoint[1]
                Start-Sleep -Milliseconds 300
                $raisedPoint = & $refToScreen 960 620
                & $sendMouseMove $raisedPoint[0] $raisedPoint[1]
                Start-Sleep -Milliseconds 250
                & $slotClick
                & $captureSlot 'raised-hand-no-slot-leak'
                if (@(Select-String -LiteralPath $logPath -Pattern '^SLOT_CLICK ').Count -ne $clicksAfterBoard) { throw 'Slot click leaked through raised inspection' }
                if (-not (Select-String -LiteralPath $logPath -Pattern '^SLOT_REVIEW_HAND [0-9]+$' -Quiet)) { throw 'Actual hand hover not observed' }
                Write-Output "$mode : actual hand hover and raised inspection click isolation PASS"
            }

            # 3. Hover rightmost card (Card 9: refX=1420, refY=880)
            $cRight = & $refToScreen 1420.0 880.0
            & $sendMouseMove $cRight[0] $cRight[1]
            Start-Sleep -Milliseconds 400
            $hoverRightBmp = New-Object System.Drawing.Bitmap($width, $height)
            $hoverRightG = [System.Drawing.Graphics]::FromImage($hoverRightBmp)
            try {
                $hoverRightG.CopyFromScreen($point.X, $point.Y, 0, 0, $hoverRightBmp.Size)
                $hoverRightBmp.Save((Join-Path $outDir ("desktop-$mode-hover-right.png")))
            } finally { $hoverRightG.Dispose(); $hoverRightBmp.Dispose() }

            # 4. Rapid scrub across cards (Card 0 -> Card 2 -> Card 4 -> Card 6 -> Card 8 -> Card 9)
            foreach ($rx in @(386.0, 620.0, 850.0, 1080.0, 1310.0, 1468.0)) {
                $cs = & $refToScreen $rx 880.0
                & $sendMouseMove $cs[0] $cs[1]
                Start-Sleep -Milliseconds 50
            }

            # 5. Move outside hand (into battlefield at refX=960, refY=500) -> cards return to rest
            $cOut = & $refToScreen 960.0 500.0
            & $sendMouseMove $cOut[0] $cOut[1]
            Start-Sleep -Milliseconds 320
        }
        if ($UtilityHud -and -not $EditorPreview) {
            $buttonPoint = & $refToScreen 1760.0 $UtilityButtonY
            & $sendMouseMove $buttonPoint[0] $buttonPoint[1]
            foreach ($buttonState in @('hover', 'pressed', 'released')) {
                if ($buttonState -eq 'pressed') { [PreviewDesktop]::mouse_event(0x0002, 0, 0, 0, [UIntPtr]::Zero) }
                if ($buttonState -eq 'released') { [PreviewDesktop]::mouse_event(0x0004, 0, 0, 0, [UIntPtr]::Zero) }
                Start-Sleep -Milliseconds 200
                $buttonBitmap = New-Object System.Drawing.Bitmap($width, $height)
                $buttonGraphics = [System.Drawing.Graphics]::FromImage($buttonBitmap)
                try {
                    $buttonGraphics.CopyFromScreen($point.X, $point.Y, 0, 0, $buttonBitmap.Size)
                    $buttonBitmap.Save((Join-Path $outDir ("desktop-$mode-button-$buttonState.png")))
                } finally { $buttonGraphics.Dispose(); $buttonBitmap.Dispose() }
            }
            if (-not (Select-String -LiteralPath $logPath -Pattern '^UTILITY_PREVIEW_ACTIVATED$' -Quiet)) { throw "End Turn native activation not received: $mode" }
            if (-not (Select-String -LiteralPath $logPath -Pattern '^UTILITY_PREVIEW_FOCUSED$' -Quiet)) { throw "End Turn native focus not received: $mode" }
            & $assertForeground
            [PreviewDesktop]::keybd_event(0x20, 0, 0, [UIntPtr]::Zero)
            Start-Sleep -Milliseconds 150
            [PreviewDesktop]::keybd_event(0x20, 0, 2, [UIntPtr]::Zero)
            Start-Sleep -Milliseconds 200
            $activationCount = @(Select-String -LiteralPath $logPath -Pattern '^UTILITY_PREVIEW_ACTIVATED$').Count
            if ($activationCount -ne 2) { throw "Expected mouse and Space activation exactly once each: $mode ($activationCount)" }
            $outsidePoint = & $refToScreen 960.0 500.0
            & $sendMouseMove $outsidePoint[0] $outsidePoint[1]
            Write-Output "$mode : native End Turn hover/press/release, focus and mouse/Space activation PASS (preview only)"
        }
        if ($AnimateResources) {
            for ($frameIndex = 0; $frameIndex -lt 8; $frameIndex++) {
                Start-Sleep -Milliseconds 140
                $motionBitmap = New-Object System.Drawing.Bitmap($width, $height)
                $motionGraphics = [System.Drawing.Graphics]::FromImage($motionBitmap)
                try {
                    $motionGraphics.CopyFromScreen($point.X, $point.Y, 0, 0, $motionBitmap.Size)
                    $motionBitmap.Save((Join-Path $outDir ("desktop-$mode-motion-$frameIndex.png")))
                } finally { $motionGraphics.Dispose(); $motionBitmap.Dispose() }
            }
        }
        if ($BattlefieldSlots -and @(Select-String -LiteralPath $logPath -Pattern '^SLOT_CLICK ').Count -ne $clicksAfterBoard) { throw 'Slot input leaked through hand or utility controls' }
        & $assertForeground
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
