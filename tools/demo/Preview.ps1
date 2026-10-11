# Makes a smaller copy of a video for sharing or quick review (Windows' built-in MediaComposition).
#   Preview.ps1 -Video demo\final\demo-v001.mp4 [-Width 1280] [-Bitrate 3000000] [-Out path]
param(
    [Parameter(Mandatory)][string]$Video,
    [int]$Width = 1280,
    [int]$Bitrate = 3000000,
    [string]$Out
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
[void][Windows.Media.MediaProperties.MediaEncodingProfile, Windows.Media.MediaProperties, ContentType = WindowsRuntime]
[void][Windows.Media.Transcoding.TranscodeFailureReason, Windows.Media.Transcoding, ContentType = WindowsRuntime]
$Video = (Resolve-Path $Video).Path
if (-not $Out) { $Out = [IO.Path]::ChangeExtension($Video, $null).TrimEnd('.') + "-$Width.mp4" }
$clip = Wait-WinRT ([Windows.Media.Editing.MediaClip]::CreateFromFileAsync((Get-StorageFile $Video))) ([Windows.Media.Editing.MediaClip])
$props = $clip.GetVideoEncodingProperties()
$H = [int]([math]::Round($Width * $props.Height / $props.Width / 2) * 2)
$comp = [Windows.Media.Editing.MediaComposition]::new(); Add-WinRTItem $comp.Clips $clip ([Windows.Media.Editing.MediaClip])
$profile = [Windows.Media.MediaProperties.MediaEncodingProfile]::CreateMp4([Windows.Media.MediaProperties.VideoEncodingQuality]::HD720p)
$profile.Video.Width = $Width; $profile.Video.Height = $H; $profile.Video.Bitrate = [uint32]$Bitrate
$profile.Video.FrameRate.Numerator = 30; $profile.Video.FrameRate.Denominator = 1
$r = Wait-WinRTProgress ($comp.RenderToFileAsync((New-StorageFile $Out), [Windows.Media.Editing.MediaTrimmingPreference]::Precise, $profile)) ([Windows.Media.Transcoding.TranscodeFailureReason]) ([double])
if ("$r" -ne 'None') { throw "Preview failed: $r" }
"{0} ({1:N1} MB, {2}x{3})" -f $Out, ((Get-Item $Out).Length / 1MB), $Width, $H
