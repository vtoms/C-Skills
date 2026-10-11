# Joins the current scene clips into the final video with Windows' built-in MediaComposition:
# title card, crossfades between scenes, optional outro card and music bed, merged captions and chapters.
# Each run writes a new numbered version to <Dir>/final and records exactly which clips went into it.
#
#   Stitch.ps1 -Dir demo [-Name demo] [-NoTransitions]
param(
    [string]$Dir = 'demo',
    [string]$Name,
    [switch]$NoTransitions,
    [switch]$NoRender      # skip the automatic RenderClip pass (normally it brings every clip up to date first)
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
[void][Windows.Media.MediaProperties.MediaEncodingProfile, Windows.Media.MediaProperties, ContentType = WindowsRuntime]
[void][Windows.Media.Transcoding.TranscodeFailureReason, Windows.Media.Transcoding, ContentType = WindowsRuntime]
[void][Windows.Graphics.Imaging.ImageStream, Windows.Graphics, ContentType = WindowsRuntime]
$Dir = (Resolve-Path $Dir).Path
$project = Read-DemoJson (Join-Path $Dir 'project.json')
$board = Read-DemoJson (Join-Path $Dir 'storyboard.json')
$manifest = Read-DemoManifest $Dir
if (-not $Name) { $Name = if ($project.output.name) { $project.output.name } else { 'demo' } }
$font = if ($project.brand.font) { $project.brand.font } else { 'Segoe UI' }
function ColorOf($hex, [string]$fallback) { $h = if ($hex) { ([string]$hex).TrimStart('#') } else { $fallback }; if ($h.Length -eq 6) { $h = 'FF' + $h }; [Convert]::ToInt32($h, 16) }
$colA = ColorOf $project.brand.background_from '181C2C'; $colB = ColorOf $project.brand.background_to '2E408C'
$fade = if ($NoTransitions) { 0 } else { 0.4 }
$sw = [Diagnostics.Stopwatch]::StartNew()
# Bring clips up to date first, so changed effects, edits or settings are never stitched from an old clip.
if (-not $NoRender) { & (Join-Path $PSScriptRoot 'RenderClip.ps1') -Dir $Dir | Out-Host; $manifest = Read-DemoManifest $Dir }

# Every scene needs an up-to-date clip.
$problems = @(); $items = @()
foreach ($s in $board.scenes) {
    $e = $manifest.scenes.($s.id)
    if (-not $e -or -not $e.clip) { $problems += "$($s.id): no clip (record and render it)"; continue }
    $clipPath = Join-Path $Dir $e.clip
    if (-not (Test-Path $clipPath)) { $problems += "$($s.id): clip file missing ($($e.clip))"; continue }
    if ($e.record_hash -ne (Get-DemoSceneRecordHash $s $project)) { $problems += "$($s.id): storyboard changed since its take (re-record)" }
    $info = Read-DemoJson ([IO.Path]::ChangeExtension($clipPath, '.json'))
    $items += [pscustomobject]@{ id = $s.id; title = $s.title; clip = $clipPath; info = $info; first = [IO.Path]::ChangeExtension($clipPath, '.first.jpg'); last = [IO.Path]::ChangeExtension($clipPath, '.last.jpg') }
}
if ($problems) { throw ("Not ready to stitch:`n  " + ($problems -join "`n  ") + "`nRun RenderClip.ps1 (and Record.ps1 for stale scenes) first.") }
$W = [int]$items[0].info.width; $H = [int]$items[0].info.height

$work = Join-Path $Dir 'final\_work'; Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Force $work | Out-Null
$comp = [Windows.Media.Editing.MediaComposition]::new()
$clock = 0.0; $chapters = @(); $srt = @(); $used = @()
function Add-Image([string]$Path, [double]$Sec) {
    $c = Wait-WinRT ([Windows.Media.Editing.MediaClip]::CreateFromImageFileAsync((Get-StorageFile $Path), [TimeSpan]::FromTicks([long]($Sec * 1e7)))) ([Windows.Media.Editing.MediaClip])
    Add-WinRTItem $comp.Clips $c ([Windows.Media.Editing.MediaClip]); $script:clock += $Sec
}
function Add-Crossfade([string]$From, [string]$To, [string]$Tag) {
    if ($fade -le 0) { return }
    $n = 12; $pattern = Join-Path $work ($Tag + '-{0:D2}.jpg')
    [DemoKit.FrameCompose]::Crossfade($From, $To, $pattern, $n, $W, $H, 90)
    for ($i = 0; $i -lt $n; $i++) { Add-Image ($pattern -f $i) ($fade / $n) }
}

# Title card.
$prevLast = $null
if ($project.title_card -ne $false -and $board.title) {
    $card = Join-Path $work 'title.jpg'
    [DemoKit.FrameCompose]::TitleCard($card, $W, $H, [string]$board.title, [string]$board.subtitle, $font, 92, $colA, $colB)
    Add-Image $card 2.3; $prevLast = $card
}
# Scene clips: a crossfade replaces the last 0.2 s of one and the first 0.2 s of the next (silent lead-in and tail),
# so the narration timing inside each clip is untouched.
for ($k = 0; $k -lt $items.Count; $k++) {
    $it = $items[$k]
    if ($prevLast) { Add-Crossfade $prevLast $it.first "x$k" }
    $c = Wait-WinRT ([Windows.Media.Editing.MediaClip]::CreateFromFileAsync((Get-StorageFile $it.clip))) ([Windows.Media.Editing.MediaClip])
    $trimIn = if ($prevLast) { $fade / 2 } else { 0 }
    $hasNext = ($k + 1 -lt $items.Count) -or $board.outro
    $trimOut = if ($hasNext) { $fade / 2 } else { 0 }
    $c.TrimTimeFromStart = [TimeSpan]::FromTicks([long]($trimIn * 1e7)); $c.TrimTimeFromEnd = [TimeSpan]::FromTicks([long]($trimOut * 1e7))
    $start = $clock
    Add-WinRTItem $comp.Clips $c ([Windows.Media.Editing.MediaClip])
    $len = $c.OriginalDuration.TotalSeconds - $trimIn - $trimOut
    $clock += $len
    $chapters += [pscustomobject]@{ at = [math]::Max(0, $start - $(if ($prevLast) { $fade } else { 0 })); title = $(if ($it.title) { $it.title } else { $it.id }) }
    foreach ($cue in @($it.info.captions)) {
        $a = $start + [double]$cue.start - $trimIn; $b = $start + [double]$cue.end - $trimIn
        if ($b -gt $start -and $a -lt $start + $len) { $srt += [pscustomobject]@{ text = $cue.text; start = [math]::Max($start, $a); end = [math]::Min($start + $len, $b) } }
    }
    $used += [ordered]@{ scene = $it.id; clip = (Get-DemoRelativePath $Dir $it.clip); take = $it.info.take; render_hash = $it.info.render_hash; at = [math]::Round($start, 3); seconds = [math]::Round($len, 3) }
    $prevLast = $it.last
}
if ($board.outro) {
    $card = Join-Path $work 'outro.jpg'
    [DemoKit.FrameCompose]::TitleCard($card, $W, $H, [string]$board.outro.title, [string]$board.outro.subtitle, $font, 92, $colA, $colB)
    Add-Crossfade $prevLast $card 'xo'
    Add-Image $card 3.0
}
# Music bed: repeated to cover the video, kept quiet under the narration.
if ($project.music.file) {
    $mf = Join-Path $Dir $project.music.file
    $vol = if ($project.music.volume) { [double]$project.music.volume } else { 0.12 }
    $at = 0.0
    while ($at -lt $clock - 0.5) {
        $tr = Wait-WinRT ([Windows.Media.Editing.BackgroundAudioTrack]::CreateFromFileAsync((Get-StorageFile $mf))) ([Windows.Media.Editing.BackgroundAudioTrack])
        $tr.Volume = $vol; $tr.Delay = [TimeSpan]::FromTicks([long]($at * 1e7))
        $len = $tr.OriginalDuration.TotalSeconds
        if ($at + $len -gt $clock) { $tr.TrimTimeFromEnd = [TimeSpan]::FromTicks([long](($at + $len - $clock) * 1e7)) }
        Add-WinRTItem $comp.BackgroundAudioTracks $tr ([Windows.Media.Editing.BackgroundAudioTrack])
        $at += $len
    }
}

# Version number and render.
$finalDir = Join-Path $Dir 'final'
$ver = 1 + [int]@(Get-ChildItem $finalDir -Filter "$Name-v*.mp4" -ErrorAction SilentlyContinue | ForEach-Object { if ($_.BaseName -match '-v(\d+)$') { [int]$matches[1] } } | Measure-Object -Maximum).Maximum
$out = Join-Path $finalDir ('{0}-v{1:D3}.mp4' -f $Name, $ver)
$profile = [Windows.Media.MediaProperties.MediaEncodingProfile]::CreateMp4([Windows.Media.MediaProperties.VideoEncodingQuality]::HD1080p)
$profile.Video.Width = $W; $profile.Video.Height = $H; $profile.Video.FrameRate.Numerator = 30; $profile.Video.FrameRate.Denominator = 1
$profile.Video.Bitrate = [uint32]([math]::Min(12000000, $W * $H * 3))
$result = Wait-WinRTProgress ($comp.RenderToFileAsync((New-StorageFile $out), [Windows.Media.Editing.MediaTrimmingPreference]::Precise, $profile)) ([Windows.Media.Transcoding.TranscodeFailureReason]) ([double])
if ("$result" -ne 'None') { throw "Stitch failed: $result" }

function Fmt([double]$s) { $t = [TimeSpan]::FromSeconds($s); '{0:00}:{1:00}:{2:00},{3:000}' -f [int][math]::Floor($t.TotalHours), $t.Minutes, $t.Seconds, $t.Milliseconds }
$lines = @(for ($i = 0; $i -lt $srt.Count; $i++) { ($i + 1); "$(Fmt $srt[$i].start) --> $(Fmt $srt[$i].end)"; $srt[$i].text; '' })
[IO.File]::WriteAllText([IO.Path]::ChangeExtension($out, '.srt'), (($lines | ForEach-Object { "$_" }) -join "`r`n"), (New-Object Text.UTF8Encoding $false))
$chap = @(@('0:00 Intro') + @($chapters | ForEach-Object { $t = [TimeSpan]::FromSeconds([math]::Floor($_.at)); '{0}:{1:00} {2}' -f [int][math]::Floor($t.TotalMinutes), $t.Seconds, $_.title }))
if (-not ($project.title_card -ne $false -and $board.title)) { $chap = @($chap | Select-Object -Skip 1); $chap[0] = $chap[0] -replace '^\S+', '0:00' }
[IO.File]::WriteAllLines([IO.Path]::ChangeExtension($out, '.chapters.txt'), [string[]]$chap, (New-Object Text.UTF8Encoding $false))

# Read back and save review stills (one per scene, 60% through).
$back = Wait-WinRT ([Windows.Media.Editing.MediaClip]::CreateFromFileAsync((Get-StorageFile $out))) ([Windows.Media.Editing.MediaClip])
$review = Join-Path $finalDir ('{0}-v{1:D3}-review' -f $Name, $ver); New-Item -ItemType Directory -Force $review | Out-Null
$probe = [Windows.Media.Editing.MediaComposition]::new(); Add-WinRTItem $probe.Clips $back ([Windows.Media.Editing.MediaClip])
foreach ($u in $used) {
    $at = [TimeSpan]::FromSeconds($u.at + $u.seconds * 0.6)
    $stream = Wait-WinRT ($probe.GetThumbnailAsync($at, [int]($W / 2), [int]($H / 2), [Windows.Media.Editing.VideoFramePrecision]::NearestFrame)) ([Windows.Graphics.Imaging.ImageStream])
    $reader = [Windows.Storage.Streams.DataReader]::new($stream.GetInputStreamAt(0)); $size = [uint32]$stream.Size
    [void](Wait-WinRT ($reader.LoadAsync($size)) ([uint32])); $bytes = New-Object byte[] $size; $reader.ReadBytes($bytes)
    [IO.File]::WriteAllBytes((Join-Path $review "$($u.scene).jpg"), $bytes)
}
Remove-Item -Recurse -Force $work

$record = [ordered]@{ version = $ver; file = (Get-DemoRelativePath $Dir $out); seconds = [math]::Round($back.OriginalDuration.TotalSeconds, 2); planned = [math]::Round($clock, 2)
                      width = $W; height = $H; transitions = $fade; music = $project.music; title = $board.title; subtitle = $board.subtitle; outro = $board.outro; brand = $project.brand
                      clips = $used; made_utc = [DateTime]::UtcNow.ToString('o') }
Write-DemoJson $record ([IO.Path]::ChangeExtension($out, '.json'))
$manifest.finals = @(@($manifest.finals) + [pscustomobject]@{ version = $ver; file = $record.file; seconds = $record.seconds; made_utc = $record.made_utc } | Where-Object { $_ })
Save-DemoManifest $Dir $manifest
Write-DemoLog $Dir 'stitch' @{ version = $ver; file = $record.file; seconds = $record.seconds; clips = @($used | ForEach-Object { "$($_.scene)@$($_.take)/$($_.render_hash)" }); took = [math]::Round($sw.Elapsed.TotalSeconds, 1) }
"final: $($record.file) ($($record.seconds)s; planned $($record.planned)s) with $($used.Count) scenes"
"captions: $([IO.Path]::ChangeExtension($record.file, '.srt'))  chapters: $([IO.Path]::ChangeExtension($record.file, '.chapters.txt'))  review stills: $(Get-DemoRelativePath $Dir $review)"
