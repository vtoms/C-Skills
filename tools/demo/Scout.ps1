# Scouts a web app for demo planning: opens it (or attaches to an open window), then for each screenful saves a
# screenshot and the list of visible page elements (UI Automation), scrolling down the page.
# Output: <OutDir>/screen-NN.png (downscaled) and <OutDir>/screen-NN.json, plus scout.json (summary).
#
#   Scout.ps1 -Url https://example.com -OutDir demo\scout [-Screens 6] [-Browser msedge] [-Attach 'Title*'] [-KeepOpen]
param(
    [string]$Url,
    [Parameter(Mandatory)][string]$OutDir,
    [int]$Screens = 5,
    [string]$Browser = 'msedge',
    [string]$Attach,
    [int]$Monitor = 0,
    [int]$Zoom = 100,
    [int]$SettleMs = 4000,
    [switch]$KeepOpen
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'WinDrive.psm1') -Force
New-Item -ItemType Directory -Force $OutDir | Out-Null
$OutDir = (Resolve-Path $OutDir).Path
if ($Attach) {
    $w = Get-DemoBrowserWindow $Browser $Attach
    if (-not $w) { throw "No $Browser window titled '$Attach'." }
} else {
    if (-not $Url) { throw 'Give -Url or -Attach.' }
    $w = Start-DemoBrowser $Browser $Url '' '*' -Private
}
[void](Initialize-DemoView $w $Monitor $false $Zoom)
Start-Sleep -Milliseconds $SettleMs
$screen = Get-DemoMonitor $Monitor
$dx = $null
try { $dx = New-Object DemoKit.DxgiCapture $screen.DeviceName } catch { }
function Save-Shot([string]$Path) {
    $b = $screen.Bounds
    $bmp = $null; if ($dx) { try { $bmp = $dx.Grab(500) } catch { } }
    if (-not $bmp) { $x = New-Object Drawing.Bitmap $b.Width, $b.Height; $g = [Drawing.Graphics]::FromImage($x); $g.CopyFromScreen($b.X, $b.Y, 0, 0, $x.Size); $g.Dispose(); $bmp = $x }
    $small = New-Object Drawing.Bitmap $bmp, ([int]($bmp.Width / 2)), ([int]($bmp.Height / 2))
    $small.Save($Path, [Drawing.Imaging.ImageFormat]::Png); $small.Dispose(); $bmp.Dispose()
}
$summary = @()
$doc = Get-DemoDocument $w
for ($i = 1; $i -le $Screens; $i++) {
    $png = Join-Path $OutDir ('screen-{0:D2}.png' -f $i)
    Save-Shot $png
    $map = @(Get-DemoElementMap $w 500)
    Write-DemoJson $map (Join-Path $OutDir ('screen-{0:D2}.json' -f $i))
    $summary += [pscustomobject]@{ screen = $i; png = [IO.Path]::GetFileName($png); elements = $map.Count
        buttons = @($map | Where-Object { $_.type -eq 'Button' } | ForEach-Object { $_.name } | Select-Object -First 25)
        links = @($map | Where-Object { $_.type -eq 'Hyperlink' } | ForEach-Object { $_.name } | Select-Object -First 25)
        edits = @($map | Where-Object { $_.type -in 'Edit', 'ComboBox' } | ForEach-Object { "$($_.name) [$($_.id)]" }) }
    if ($i -lt $Screens) {
        if ($doc) { $r = $doc.Current.BoundingRectangle; [DemoKit.Win32Input]::Glide([int]($r.X + $r.Width - 60), [int]($r.Y + $r.Height / 2), 200) }
        [DemoKit.Win32Input]::Wheel(-8); Start-Sleep -Milliseconds 1500
    }
}
if ($dx) { $dx.Dispose() }
Write-DemoJson ([ordered]@{ url = $Url; title = $w.Current.Name; screens = $summary }) (Join-Path $OutDir 'scout.json')
if (-not $KeepOpen -and -not $Attach) { try { ($w.GetCurrentPattern([System.Windows.Automation.WindowPattern]::Pattern)).Close() } catch { }; Remove-DemoThrowawayProfile }
$summary | ForEach-Object { "screen $($_.screen): $($_.elements) elements; buttons: $(($_.buttons | Select-Object -First 12) -join ' | ')" }
