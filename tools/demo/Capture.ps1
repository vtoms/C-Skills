# Records one monitor to numbered JPEG frames (and, with -Audio, what the speakers play) until a stop file appears.
# Run it as its own process (Start-Process) while the driver acts; create the stop file to end it.
param(
    [Parameter(Mandatory)][string]$OutDir,
    [int]$Monitor = 0,
    [double]$Fps = 15,
    [string]$StopFile = (Join-Path $OutDir 'STOP'),
    [int]$Quality = 85,
    [double]$MaxSeconds = 900,
    [switch]$Audio,      # also record system audio (WASAPI loopback) to app-audio.wav, with a levels log
    [switch]$NoVideo     # audio only (used by rehearsals that wait for the app to finish speaking)
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
Enable-DemoDpiAwareness
$screen = Get-DemoMonitor $Monitor; $b = $screen.Bounds
New-Item -ItemType Directory -Force $OutDir | Out-Null
Remove-Item -Force $StopFile -ErrorAction SilentlyContinue
Write-DemoJson ([ordered]@{ monitor = $Monitor; x = $b.X; y = $b.Y; width = $b.Width; height = $b.Height; fps = $Fps; started = [DateTime]::UtcNow.Ticks }) (Join-Path $OutDir 'capture.json')
$audioThread = $null
if ($Audio) { $audioThread = [DemoKit.LoopbackCapture]::Start((Join-Path $OutDir 'app-audio.wav'), (Join-Path $OutDir 'levels.tsv'), $StopFile, $MaxSeconds) }
if ($NoVideo) {
    Set-Content -Path (Join-Path $OutDir 'READY') -Value '' -Encoding ASCII
    while (-not (Test-Path $StopFile)) { Start-Sleep -Milliseconds 100 }
    $n = 0
} else {
    $n = [DemoKit.FrameCapture]::Run($OutDir, $screen.DeviceName, $b.X, $b.Y, $b.Width, $b.Height, $Fps, $StopFile, [long]$Quality, $MaxSeconds)
}
if ($audioThread) {
    [void]$audioThread.Join(10000)
    Write-DemoJson ([ordered]@{ file = 'app-audio.wav'; started = [DemoKit.LoopbackCapture]::StartedUtcTicks; rate = [DemoKit.LoopbackCapture]::SampleRate
                                channels = [DemoKit.LoopbackCapture]::Channels; error = [DemoKit.LoopbackCapture]::Error }) (Join-Path $OutDir 'audio.json')
}
Set-Content -Path (Join-Path $OutDir 'DONE') -Value $n -Encoding ASCII
"captured $n frames with $([DemoKit.FrameCapture]::Backend)$(if ($Audio) { "; audio: $(if ([DemoKit.LoopbackCapture]::Error) { [DemoKit.LoopbackCapture]::Error } else { 'ok' })" })"
