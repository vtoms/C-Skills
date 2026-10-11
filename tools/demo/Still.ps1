# Saves still frames from a video at given times (for reviewing a clip or a final cut).
#   Still.ps1 -Video demo\final\demo-v001.mp4 -At 3.5,10,21.2 [-OutDir review] [-Width 960] [-Sheet]
# -Sheet also builds one contact sheet image with the stills in a grid, labelled with their times.
param(
    [Parameter(Mandatory)][string]$Video,
    [Parameter(Mandatory)][string]$At,       # comma-separated seconds, e.g. "1.5,4,7.25"
    [string]$OutDir,
    [int]$Width = 960,
    [switch]$Sheet
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
[void][Windows.Graphics.Imaging.ImageStream, Windows.Graphics, ContentType = WindowsRuntime]
$Video = (Resolve-Path $Video).Path
$times = @($At.Split(",") | ForEach-Object { [double]::Parse($_.Trim(), [Globalization.CultureInfo]::InvariantCulture) })
if (-not $OutDir) { $OutDir = [IO.Path]::ChangeExtension($Video, $null).TrimEnd('.') + '-stills' }
New-Item -ItemType Directory -Force $OutDir | Out-Null
$clip = Wait-WinRT ([Windows.Media.Editing.MediaClip]::CreateFromFileAsync((Get-StorageFile $Video))) ([Windows.Media.Editing.MediaClip])
$props = $clip.GetVideoEncodingProperties()
$H = [int]($Width * $props.Height / $props.Width)
$comp = [Windows.Media.Editing.MediaComposition]::new(); Add-WinRTItem $comp.Clips $clip ([Windows.Media.Editing.MediaClip])
$files = @()
foreach ($t in $times) {
    $t = [math]::Min($t, $clip.OriginalDuration.TotalSeconds - 0.05)
    $stream = Wait-WinRT ($comp.GetThumbnailAsync([TimeSpan]::FromSeconds($t), $Width, $H, [Windows.Media.Editing.VideoFramePrecision]::NearestFrame)) ([Windows.Graphics.Imaging.ImageStream])
    $reader = [Windows.Storage.Streams.DataReader]::new($stream.GetInputStreamAt(0)); $size = [uint32]$stream.Size
    [void](Wait-WinRT ($reader.LoadAsync($size)) ([uint32])); $bytes = New-Object byte[] $size; $reader.ReadBytes($bytes)
    $f = Join-Path $OutDir ('t{0:000.00}.jpg' -f $t); [IO.File]::WriteAllBytes($f, $bytes); $files += $f
}
if ($Sheet -and $files.Count) {
    $cols = [math]::Min(3, $files.Count); $rows = [math]::Ceiling($files.Count / $cols)
    $cw = [int]($Width / 2); $ch = [int]($H / 2)
    $bmp = New-Object Drawing.Bitmap ($cols * $cw), ($rows * ($ch + 24)); $g = [Drawing.Graphics]::FromImage($bmp); $g.Clear([Drawing.Color]::FromArgb(30, 30, 36))
    $font = New-Object Drawing.Font 'Segoe UI', 11
    for ($i = 0; $i -lt $files.Count; $i++) {
        $img = [Drawing.Image]::FromFile($files[$i]); $x = ($i % $cols) * $cw; $y = [math]::Floor($i / $cols) * ($ch + 24)
        $g.DrawImage($img, $x, $y + 24, $cw, $ch); $g.DrawString(('{0:N2}s' -f $times[$i]), $font, [Drawing.Brushes]::White, $x + 6, $y + 3); $img.Dispose()
    }
    $sheetPath = Join-Path $OutDir 'sheet.jpg'; $bmp.Save($sheetPath, [Drawing.Imaging.ImageFormat]::Jpeg); $g.Dispose(); $bmp.Dispose()
    $sheetPath
} else { $files }
