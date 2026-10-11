# Records one monitor to numbered JPEG frames until a stop file appears.
# Run it as its own process (Start-Process) while the driver acts; create the stop file to end it.
param(
    [Parameter(Mandatory)][string]$OutDir,
    [int]$Monitor = 0,
    [double]$Fps = 15,
    [string]$StopFile = (Join-Path $OutDir 'STOP'),
    [int]$Quality = 85,
    [double]$MaxSeconds = 900
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
Enable-DemoDpiAwareness
$screen = Get-DemoMonitor $Monitor; $b = $screen.Bounds
New-Item -ItemType Directory -Force $OutDir | Out-Null
Remove-Item -Force $StopFile -ErrorAction SilentlyContinue
Write-DemoJson ([ordered]@{ monitor = $Monitor; x = $b.X; y = $b.Y; width = $b.Width; height = $b.Height; fps = $Fps; started = [DateTime]::UtcNow.Ticks }) (Join-Path $OutDir 'capture.json')
$n = [DemoKit.FrameCapture]::Run($OutDir, $screen.DeviceName, $b.X, $b.Y, $b.Width, $b.Height, $Fps, $StopFile, [long]$Quality, $MaxSeconds)
Set-Content -Path (Join-Path $OutDir 'DONE') -Value $n -Encoding ASCII
"captured $n frames with $([DemoKit.FrameCapture]::Backend)"
