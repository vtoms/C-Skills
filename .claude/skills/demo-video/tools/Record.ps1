# Records scenes as separate, self-contained takes. Narration comes first (its length sets each scene's
# length); then the browser is driven with the real cursor while one monitor is captured.
#
#   Record.ps1 -Dir demo                   # record every scene whose take is missing or stale
#   Record.ps1 -Dir demo -Scenes s02,s03   # (re)record just these scenes
#   Record.ps1 -Dir demo -All              # re-record everything
#   Record.ps1 -Dir demo -Rehearse         # drive the scenes at real pace without capturing (finds broken steps)
#   Record.ps1 -Dir demo -VoiceOnly        # only make the narration audio and print its timing
#
# Each take is written to <Dir>/takes/<scene>/<take-id>/ with its frames, action log, page snapshots
# (UI Automation element maps after every step), and copies of the scene and project settings it used.
# The manifest points each scene at its newest take; older takes stay for comparison or rollback.
param(
    [string]$Dir = 'demo',
    [string[]]$Scenes,
    [switch]$All,
    [switch]$Rehearse,
    [switch]$VoiceOnly,
    [switch]$KeepBrowser
)
$ErrorActionPreference = 'Stop'
if ($Scenes) { $Scenes = @($Scenes | ForEach-Object { $_ -split '[,\s]+' } | Where-Object { $_ }) }   # 's02,s05' arrives as one string through -File
Import-Module (Join-Path $PSScriptRoot 'WinDrive.psm1') -Force
$Dir = (Resolve-Path $Dir).Path
$project = Read-DemoJson (Join-Path $Dir 'project.json')
$board = Read-DemoJson (Join-Path $Dir 'storyboard.json')
$manifest = Read-DemoManifest $Dir
$audioDir = Join-Path $Dir 'audio'
New-Item -ItemType Directory -Force $audioDir | Out-Null
$LeadIn = 0.4; $Tail = 0.7; $AfterAction = 0.4
$glideMs = 700
$moves = 'click', 'double_click', 'right_click', 'hover', 'type'
$lookahead = 1.5   # seconds before a timed click to start finding its target
$started = [DateTime]::UtcNow

# Which scenes: named ones, or all with -All, or (default) those without an up-to-date take.
$sceneList = @(foreach ($s in $board.scenes) {
    $hash = Get-DemoSceneRecordHash $s $project
    $cur = $manifest.scenes.($s.id)
    $stale = -not $cur -or -not $cur.take -or $cur.record_hash -ne $hash
    if ($Scenes) { if ($s.id -in $Scenes) { $s } }
    elseif ($All -or $Rehearse -or $VoiceOnly -or $stale) { $s }
})
if (-not $sceneList) { 'Every scene already has an up-to-date take. Use -Scenes or -All to record again.'; return }

# --- 1. Voice first. A scene's narration may contain [pause 600ms] markers: the phrases between them are
# synthesised separately (Edge's voice service rejects SSML breaks) and laid out with those gaps.
# Each phrase is cached by a hash of (text, voice, rate, pitch, volume, lexicon), so only changed phrases are re-made.
$voices = @{}
foreach ($s in $sceneList) {
    $v = $project.voice
    $engine = if ($v.engine) { $v.engine } else { 'aria' }
    $voiceName = if ($v.name) { $v.name } else { 'en-US-AriaNeural' }
    $rate = if ($s.voice.rate) { $s.voice.rate } elseif ($v.rate) { $v.rate } else { '+0%' }
    $pitch = if ($s.voice.pitch) { $s.voice.pitch } elseif ($v.pitch) { $v.pitch } else { '+0Hz' }
    $volume = if ($v.volume) { $v.volume } else { '+0%' }
    $pieces = [regex]::Split([string]$s.narration, '\[pause\s+(\d+)\s*ms\]', 'IgnoreCase')   # text, gap, text, gap, ...
    $parts = @(); $words = @(); $clock = 0.0
    for ($i = 0; $i -lt $pieces.Count; $i += 2) {
        $phrase = $pieces[$i].Trim()
        $gap = if ($i + 1 -lt $pieces.Count) { [double]$pieces[$i + 1] / 1000 } else { 0 }
        if ($phrase) {
            $key = Get-DemoHash ([ordered]@{ text = $phrase; engine = $engine; voice = $voiceName; rate = $rate; pitch = $pitch; volume = $volume; lexicon = $v.lexicon })
            $base = Join-Path $audioDir "$($s.id)-$key"
            $cached = if (Test-Path "$base.words.json") { Read-DemoJson "$base.words.json" } else { $null }
            if ($cached -and $cached.fallback -and $engine -eq 'aria') { $cached = $null }   # Aria failed last time: try it again
            if (-not $cached) {
                $spoken = $phrase
                foreach ($lp in @($v.lexicon.PSObject.Properties)) { if ($lp) { $spoken = $spoken -replace "\b$([regex]::Escape($lp.Name))\b", $lp.Value } }  # pronunciation fixes
                $speak = Join-Path $PSScriptRoot 'Speak.ps1'
                $fellBack = $false
                try { & $speak -Text $spoken -OutBase $base -Voice $engine -AriaVoiceName $voiceName -BuiltinVoiceName ([string]$v.builtin_name) -Rate $rate -Pitch $pitch -Volume $volume | Out-Host }
                catch {
                    if ($engine -ne 'aria') { throw }
                    Write-Warning "Aria failed for $($s.id) ($($_.Exception.Message)); using the built-in Windows voice."
                    & $speak -Text $spoken -OutBase $base -Voice builtin -BuiltinVoiceName ([string]$v.builtin_name) -Rate $rate | Out-Host
                    $fellBack = $true
                }
                $m = Read-DemoJson "$base.words.json"
                $m | Add-Member -Force written $phrase
                if ($fellBack) { $m | Add-Member -Force fallback $true }
                Write-DemoJson $m "$base.words.json"
                Write-DemoLog $Dir 'voice' @{ scene = $s.id; audio = (Get-DemoRelativePath $Dir (Join-Path $audioDir $m.audio)); voice = $m.voice; seconds = $m.duration; key = $key; rate = $rate; pitch = $pitch }
            }
            $m = Read-DemoJson "$base.words.json"
            $parts += [pscustomobject]@{ file = (Get-DemoRelativePath $Dir (Join-Path $audioDir $m.audio)); offset = [math]::Round($clock, 3); duration = [double]$m.duration; voice = $m.voice }
            foreach ($w in @($m.words)) { $words += [pscustomobject]@{ text = $w.text; start = [math]::Round($clock + $w.start, 3); end = [math]::Round($clock + $w.end, 3) } }
            $clock += [double]$m.duration
        }
        $clock += $gap
    }
    $written = ([regex]::Replace([string]$s.narration, '\s*\[pause\s+\d+\s*ms\]\s*', ' ', 'IgnoreCase')).Trim()
    $meta = [pscustomobject]@{ parts = $parts; words = $words; duration = [math]::Round($clock, 3); narration = $written; voice = (@($parts)[0]).voice }
    $wps = if ($meta.duration -gt 0) { $words.Count / $meta.duration } else { 0 }
    "{0}: {1:N2}s, {2} words, {3:N2} words/s, {4} part(s) ({5})" -f $s.id, $meta.duration, $words.Count, $wps, $parts.Count, $meta.voice
    $voices[$s.id] = $meta
    Write-DemoJson $meta (Join-Path $audioDir "$($s.id).timing.json")   # merged timing, read by Test-Storyboard.ps1
}$usedVoices = @($voices.Values | ForEach-Object { $_.voice } | Select-Object -Unique)
if ($usedVoices.Count -gt 1) { Write-Warning "Scenes use different voices ($($usedVoices -join ', ')); a fallback probably happened. Run -VoiceOnly again before recording." }
if ($VoiceOnly) { return }

# --- helpers ---
function Get-Offset($Item, $Meta) {
    # Seconds after the narration starts. at_word is a 0-based index into the narration's words.
    if ($null -ne $Item.at_word) {
        $w = @($Meta.words); $i = [math]::Min([int]$Item.at_word, $w.Count - 1)
        if ($i -lt 0) { return 0 }
        return [double]$w[$i].start
    }
    if ($null -ne $Item.at) { return [double]$Item.at }
    $null
}
# Waits for the app's own sound (system audio level) to start, then to stay quiet for quiet_ms.
function Wait-DemoAppAudio($Item) {
    $levels = Join-Path $session 'levels.tsv'
    if (-not (Test-Path $levels)) { throw "wait_audio needs the project setting app_audio: true (system audio is not being recorded)." }
    $threshold = if ($Item.threshold) { [double]$Item.threshold } else { 0.01 }
    $quietMs = if ($Item.quiet_ms) { [int]$Item.quiet_ms } else { 1200 }
    $startBy = [DateTime]::UtcNow.AddMilliseconds($(if ($Item.start_timeout_ms) { [int]$Item.start_timeout_ms } else { 15000 }))
    $giveUp = [DateTime]::UtcNow.AddMilliseconds($(if ($Item.timeout_ms) { [int]$Item.timeout_ms } else { 90000 }))
    $since = [DateTime]::UtcNow.Ticks; $heard = $false; [long]$lastLoud = 0
    while ([DateTime]::UtcNow -lt $giveUp) {
        Start-Sleep -Milliseconds 100
        $tail = @(Get-Content $levels -Tail 30 -ErrorAction SilentlyContinue | ForEach-Object { $q = $_.Split("`t"); [pscustomobject]@{ t = [long]$q[0]; v = [double]::Parse($q[1], [Globalization.CultureInfo]::InvariantCulture) } } | Where-Object { $_.t -ge $since })
        foreach ($x in $tail) { if ($x.v -gt $threshold) { $heard = $true; $lastLoud = [math]::Max([long]$lastLoud, [long]$x.t) } }
        if (-not $heard -and [DateTime]::UtcNow -gt $startBy) { throw "wait_audio: the app made no sound in time." }
        if ($heard -and ([DateTime]::UtcNow.Ticks - $lastLoud) / 1e4 -ge $quietMs) { return [math]::Round(($lastLoud - $since) / 1e7, 2) }
    }
    throw 'wait_audio: the app was still making sound at the timeout.'
}
function Wait-Until([long]$Ticks) { $ms = [int](($Ticks - [DateTime]::UtcNow.Ticks) / 1e4); if ($ms -gt 0) { Start-Sleep -Milliseconds $ms } }
function Save-Snapshot($Window, [bool]$Settle = $false) {
    # Page element map with screen rectangles: lets post-production place highlights without re-recording.
    # With -Settle, waits (up to 1.5 s) until two maps agree, so smooth scrolling and animations have finished.
    $map = @(Get-DemoElementMap $Window 600); $same = $true
    if ($Settle) {
        $deadline = [DateTime]::UtcNow.AddMilliseconds(1500)
        do {
            Start-Sleep -Milliseconds 150
            $again = @(Get-DemoElementMap $Window 600)
            $same = ($again.Count -eq $map.Count) -and -not (Compare-Object @($map | ForEach-Object { "$($_.name)|$($_.x)|$($_.y)" }) @($again | ForEach-Object { "$($_.name)|$($_.x)|$($_.y)" }))
            $map = $again
        } while (-not $same -and [DateTime]::UtcNow -lt $deadline)
    }
    $texts = @(Get-DemoTextRects $Window $script:effectTexts)
    [pscustomobject]@{ t = [DateTime]::UtcNow.Ticks; settled = $same; elements = $map; texts = $texts }
}

# --- 2. Browser ---
$title = if ($project.window_title) { $project.window_title } else { '*' }
$browser = if ($project.browser) { $project.browser } else { 'msedge' }
$mode = if ($project.profile) { $project.profile } else { 'private' }
if ($mode -eq 'attach') {
    $window = Get-DemoBrowserWindow $browser $title
    if (-not $window) { throw "No open $browser window titled '$title'. Open the app first, or set profile to 'private' or 'dedicated'." }
} else {
    $profileDir = if ($mode -eq 'dedicated') { Join-Path $Dir '.browser-profile' } else { '' }
    $window = Start-DemoBrowser $browser $project.app_url $profileDir $title -Private:($mode -eq 'private')
}
$zoomUsed = Initialize-DemoView $window ([int]$project.monitor) ([bool]$project.fullscreen) ([int]$(if ($project.zoom) { $project.zoom } else { 100 }))
Start-Sleep -Milliseconds 800

# --- 3. Capture (separate process for the whole session; frames are split into per-scene takes afterwards) ---
$session = Join-Path $Dir ('takes\_session-' + [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'))
$capture = $null
$appAudio = [bool]$project.app_audio
if (-not $Rehearse -or $appAudio) {
    $fps = if ($project.fps) { $project.fps } else { 15 }
    # Start-Process does not quote array arguments in PowerShell 5.1: quote paths (they may contain spaces).
    $capArgs = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$(Join-Path $PSScriptRoot 'Capture.ps1')`"", '-OutDir', "`"$session`"",
                 '-Monitor', ([int]$project.monitor), '-Fps', $fps, '-MaxSeconds', 7200)
    if ($appAudio) { $capArgs += '-Audio' }
    if ($Rehearse) { $capArgs += '-NoVideo' }   # rehearsals still listen, so wait_audio works
    $capture = Start-Process powershell -WindowStyle Hidden -PassThru -ArgumentList $capArgs
    $t = [DateTime]::UtcNow.AddSeconds(30)
    while (-not (Test-Path (Join-Path $session 'READY'))) { if ([DateTime]::UtcNow -gt $t -or $capture.HasExited) { throw 'Screen capture did not start.' }; Start-Sleep -Milliseconds 100 }
    Start-Sleep -Milliseconds 300
}
if (-not $capture) { New-Item -ItemType Directory -Force $session | Out-Null }
$actionLog = Join-Path $session 'actions.jsonl'
Set-DemoActionLog $actionLog
function Assert-CaptureAlive {
    if ($capture -and $capture.HasExited) { throw 'Screen capture stopped unexpectedly (a UAC prompt, lock screen or display change can do this). Nothing from this run was marked current.' }
}

# Off-camera replay of a scene's steps, to rebuild the app state a later scene starts from.
function Invoke-DemoReplay($Scene) {
    Write-Host "  replaying $($Scene.id) off-camera"
    Set-DemoFindTimeout 20000   # replayed steps run fast, so give slow-loading parts of the app more time
    try {
        foreach ($a in @($Scene.pre) + @($Scene.actions)) {
            if (-not $a) { continue }
            if ($a.do -eq 'wait_audio') { if ($appAudio) { [void](Wait-DemoAppAudio $a) } else { Start-Sleep -Seconds 5 }; continue }
            $fast = $a.PSObject.Copy(); if ($fast.do -eq 'type') { $fast | Add-Member -Force cps 60 }
            try { Invoke-DemoAction $window $fast 250 } catch { if (-not $a.optional) { throw } }
        }
    } finally { Set-DemoFindTimeout 5000 }
    Start-Sleep -Milliseconds 1000
}

# --- 4. Scenes ---
# Walk the storyboard in order from the start up to the last selected scene: selected scenes are recorded, the others
# are replayed off-camera so every recorded scene starts from the state the scenes before it leave behind.
$results = @(); $failed = $null; $s = $null; $replayed = @()
$selectedIds = @($sceneList | ForEach-Object { $_.id })
$allScenes = @($board.scenes)
$lastIdx = [array]::LastIndexOf(@($allScenes | ForEach-Object { $_.id }), $selectedIds[-1])
try {
    for ($k = 0; $k -le $lastIdx; $k++) {
        $s = $allScenes[$k]
        if ($selectedIds -notcontains $s.id) {
            if (-not $Rehearse -and $project.replay_earlier -ne $false) { [DemoKit.Win32Input]::Activate([IntPtr]$window.Current.NativeWindowHandle) | Out-Null; Invoke-DemoReplay $s; $replayed += $s.id }
            continue
        }
        $meta = $voices[$s.id]
        $script:effectTexts = @($s.effects | Where-Object { $_.target.text } | ForEach-Object { [string]$_.target.text } | Select-Object -Unique)
        [DemoKit.Win32Input]::Activate([IntPtr]$window.Current.NativeWindowHandle) | Out-Null
        foreach ($a in @($s.pre)) {   # setup steps: run before the scene, cut from the video
            if (-not $a) { continue }
            try { Invoke-DemoAction $window $a $glideMs } catch { if (-not $a.optional) { throw }; Write-Host "  (optional step skipped: $($_.Exception.Message))" }
        }
        Start-Sleep -Milliseconds 300
        $snaps = @(Save-Snapshot $window $true)
        $start = [DateTime]::UtcNow.Ticks
        $voiceStart = $start + [long]($LeadIn * 1e7)
        Write-DemoAction 'scene' @{ id = $s.id }

        # Schedule actions by their word; untimed actions follow the one before them.
        $events = @(); $seq = 0; $key = 0.0
        foreach ($a in @($s.actions)) {
            if (-not $a) { continue }
            $off = Get-Offset $a $meta
            if ($null -ne $off) { $key = $off }
            $events += [pscustomobject]@{ offset = $off; key = $key; seq = $seq++; item = $a }
        }
        $events = @($events | Sort-Object key, seq)
        $done = @()
        foreach ($e in $events) {
            $at = 0
            if ($null -ne $e.offset) {
                $at = $voiceStart + [long]($e.offset * 1e7)
                if ($e.item.do -in $moves) { Wait-Until ($at - [long]($lookahead * 1e7)) } else { Wait-Until $at }
            }
            $t0 = [DateTime]::UtcNow.Ticks; $skipped = $false; $clickBefore = Get-DemoLastClick
            if ($e.item.do -eq 'wait_audio') { $heardFor = Wait-DemoAppAudio $e.item; Write-DemoAction 'app_audio' @{ seconds = $heardFor } }
            else {
                try { Invoke-DemoAction $window $e.item $glideMs $(if ($e.item.do -in $moves) { $at } else { 0 }) }
                catch { if (-not $e.item.optional) { throw }; $skipped = $true; Write-Host "  (optional step skipped: $($_.Exception.Message))" }
            }
            $entry = [ordered]@{ do = $e.item.do; target = $e.item.target; start = $t0; end = [DateTime]::UtcNow.Ticks }
            if ($skipped) { $entry.skipped = $true }
            elseif ($at -gt 0 -and $e.item.do -in $moves -and $e.item.do -ne 'hover' -and (Get-DemoLastClick) -ne $clickBefore) {
                $entry.late = [math]::Round(((Get-DemoLastClick) - $at) / 1e7, 2)   # seconds after its word (negative = early)
                if ([math]::Abs($entry.late) -gt 0.4) { Write-Warning ("{0}: '{1}' landed {2:N2}s off its word" -f $s.id, $e.item.do, $entry.late) }
            }
            $done += $entry
            # Page snapshot for post-production targets; wait for movement to settle only after scrolling or navigating.
            $snaps += Save-Snapshot $window ($e.item.do -in 'scroll', 'navigate', 'key')
        }
        $lastAction = if ($done) { ($done | ForEach-Object { $_.end } | Measure-Object -Maximum).Maximum } else { $voiceStart }
        $end = [math]::Max($voiceStart + [long](($meta.duration + $Tail) * 1e7), [long]$lastAction + [long]($AfterAction * 1e7))
        Wait-Until $end
        Assert-CaptureAlive
        $results += [pscustomobject]@{ scene = $s; start = $start; voice_start = $voiceStart; end = $end; actions = $done; snapshots = $snaps; meta = $meta }
        $lates = @($done | Where-Object { $null -ne $_.late } | ForEach-Object { "$($_.do) $('{0:+0.00;-0.00}' -f $_.late)s" })
        '{0}: {1} {2:N2}s ({3} actions{4})' -f $s.id, $(if ($Rehearse) { 'rehearsed' } else { 'recorded' }), (($end - $start) / 1e7), $done.Count, $(if ($lates) { '; landed vs word: ' + ($lates -join ', ') } else { '' })
    }
} catch { $failed = $_ }
finally {
    if ($capture) { New-Item -ItemType File -Force (Join-Path $session 'STOP') | Out-Null; $capture.WaitForExit(120000) | Out-Null }
    Set-DemoActionLog $null
    if (-not $KeepBrowser -and $mode -ne 'attach') {
        if ([bool]$project.fullscreen) { Exit-DemoFullScreen }
        try { ($window.GetCurrentPattern([System.Windows.Automation.WindowPattern]::Pattern)).Close() } catch { }
        Remove-DemoThrowawayProfile
    }
}

# --- 5. Split the session into one self-contained take per scene ---
$cap = if (-not $Rehearse -and (Test-Path (Join-Path $session 'capture.json'))) { Read-DemoJson (Join-Path $session 'capture.json') } else { $null }
$backend = if (Test-Path (Join-Path $session 'backend.txt')) { (Get-Content -Raw (Join-Path $session 'backend.txt')).Trim() } else { $null }
$frames = if (-not $Rehearse -and (Test-Path (Join-Path $session 'frames.tsv'))) { @(Get-Content (Join-Path $session 'frames.tsv') | ForEach-Object { $p = $_.Split("`t"); [pscustomobject]@{ i = [int]$p[0]; t = [long]$p[1]; rest = (@($p | Select-Object -Skip 2) -join "`t") } }) } else { @() }
$allActions = @(if (Test-Path $actionLog) { Get-Content $actionLog | ForEach-Object { $_ | ConvertFrom-Json } })
$takeIds = @{}; $incomplete = @()
foreach ($r in $results) {
    $id = $r.scene.id
    $takeId = [DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss') + '-' + (Get-DemoHash "$id$($r.start)").Substring(0, 4)
    $takeDir = Join-Path $Dir "takes\$id\$takeId"
    if ($Rehearse) { $takeDir = Join-Path $Dir "takes\$id\_rehearsal" ; Remove-Item -Recurse -Force $takeDir -ErrorAction SilentlyContinue }
    New-Item -ItemType Directory -Force $takeDir | Out-Null
    $n = 0; $firstT = $null; $lastT = $null
    foreach ($f in $frames) {
        if ($f.t -ge $r.start - 1000000 -and $f.t -lt $r.end + 1000000) {   # 0.1 s margin each side
            Move-Item (Join-Path $session ('f{0:D6}.jpg' -f $f.i)) (Join-Path $takeDir ('f{0:D6}.jpg' -f $n))
            Add-Content -Encoding ASCII (Join-Path $takeDir 'frames.tsv') ("$n`t$($f.t)" + $(if ($f.rest) { "`t" + $f.rest } else { '' }))   # keeps the cursor columns
            if ($null -eq $firstT) { $firstT = $f.t }; $lastT = $f.t; $n++
        }
    }
    # A take is usable only if its frames cover the scene (capture may have died or stalled).
    $covered = $Rehearse -or ($n -gt 1 -and $firstT -le $r.start + 4000000 -and $lastT -ge $r.end - 4000000)
    $sceneActions = @($allActions | Where-Object { $_.t -ge $r.start - 1000000 -and $_.t -lt $r.end + 1000000 })
    $appInfo = $null
    if (-not $Rehearse -and (Test-Path (Join-Path $session 'audio.json'))) {
        $aj = Read-DemoJson (Join-Path $session 'audio.json')
        if (-not $aj.error -and $aj.started) {
            $from = [long]$r.start; $to = [long]$r.end
            [DemoKit.LoopbackCapture]::Slice((Join-Path $session 'app-audio.wav'), [long]$aj.started, (Join-Path $takeDir 'app-audio.wav'), $from, $to)
            $lv = @(Get-Content (Join-Path $session 'levels.tsv') | ForEach-Object { $q = $_.Split("`t"); if ([long]$q[0] -ge $from -and [long]$q[0] -lt $to) { , @([long]$q[0], [double]::Parse($q[1], [Globalization.CultureInfo]::InvariantCulture)) } })
            $appInfo = [ordered]@{ file = 'app-audio.wav'; start = $from; rate = $aj.rate; channels = 2; levels = $lv }
        } elseif ($appAudio) { $covered = $false; Write-Warning "${id}: app audio was not recorded ($($aj.error))." }
    } elseif ($appAudio -and -not $Rehearse) { $covered = $false; Write-Warning "${id}: app audio was not recorded." }
    Write-DemoJson ([ordered]@{
        scene = $id; take = $takeId; rehearsal = [bool]$Rehearse; complete = $covered
        recorded_utc = [DateTime]::new($r.start, [DateTimeKind]::Utc).ToString('o')
        record_hash = (Get-DemoSceneRecordHash $r.scene $project)
        capture = $(if ($cap) { [ordered]@{ x = $cap.x; y = $cap.y; width = $cap.width; height = $cap.height; fps = $cap.fps; frames = $n; backend = $backend } } else { $null })
        start = $r.start; voice_start = $r.voice_start; end = $r.end; lead_in = $LeadIn
        audio = @($r.meta.parts); narration = $r.meta.narration; voice = $r.meta.voice; duration = $r.meta.duration; words = @($r.meta.words)
        actions = @($r.actions); events = $sceneActions; snapshots = @($r.snapshots); app_audio = $appInfo
        replayed_before = $replayed                                   # scenes replayed off-camera in this run
        scene_definition = $r.scene                                   # exactly what was recorded
        project_settings = [ordered]@{ app_url = $project.app_url; browser = $browser; profile = $mode; monitor = $project.monitor; fullscreen = $project.fullscreen; zoom = $zoomUsed; fps = $project.fps; voice = $project.voice; app_audio = $appAudio }
    }) (Join-Path $takeDir 'take.json') 30
    if (-not $Rehearse) {
        if ($covered) {
            Set-DemoManifestScene $manifest $id @{ take = $takeId; record_hash = (Get-DemoSceneRecordHash $r.scene $project) }
            $takeIds[$id] = $takeId
        } else { $incomplete += $id; Write-Warning "${id}: take $takeId is incomplete (frames cover $([math]::Round(($lastT - $firstT) / 1e7, 1)) of $([math]::Round(($r.end - $r.start) / 1e7, 1)) s); kept for reference but not made current. Record the scene again." }
    }
}
if (-not $Rehearse) { Save-DemoManifest $Dir $manifest }
Remove-Item -Recurse -Force $session -ErrorAction SilentlyContinue

$log = @{ scenes = @($results | ForEach-Object { $_.scene.id }); takes = $takeIds; rehearsal = [bool]$Rehearse; seconds = [math]::Round(([DateTime]::UtcNow - $started).TotalSeconds, 1)
          late = @($results | ForEach-Object { $sid = $_.scene.id; $_.actions | Where-Object { $null -ne $_.late } | ForEach-Object { "${sid}:$($_.do)=$($_.late)" } })
          skipped = @($results | ForEach-Object { $sid = $_.scene.id; $_.actions | Where-Object { $_.skipped } | ForEach-Object { "${sid}:$($_.do)" } })
          replayed = $replayed; incomplete = $incomplete; capture_backend = $backend }
if ($failed) { $log.failed = [ordered]@{ scene = $(if ($s) { $s.id }); error = "$failed" } }
Write-DemoLog $Dir $(if ($Rehearse) { 'rehearse' } else { 'record' }) $log
if ($failed) { throw "Scene $($s.id) failed: $failed. Scenes recorded before it were kept." }
if ($Rehearse) { "Rehearsal passed: $($results.Count) scenes." } else { "Recorded $($takeIds.Count) scene take(s): $(($takeIds.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', ')" }
if ($incomplete) { throw "Incomplete takes (not made current): $($incomplete -join ', '). Record them again." }