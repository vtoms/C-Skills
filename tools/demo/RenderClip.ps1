# Renders each scene's current take into its own clip (MP4 + SRT) with Windows' built-in MediaComposition.
# A clip is rebuilt only when its inputs change (take, effects, edits, render settings or renderer code).
#
#   RenderClip.ps1 -Dir demo                 # every scene whose clip is missing or out of date
#   RenderClip.ps1 -Dir demo -Scenes s02     # just this scene
#   RenderClip.ps1 -Dir demo -Force          # rebuild even if up to date
#
# Edits (storyboard scene "edits", times in seconds from the narration start, or at_word):
#   { "cut":    [from, to] }            remove a stretch of picture AND sound (only where nobody is speaking)
#   { "freeze": [from, to] }            show the frame at 'from' for that stretch; narration keeps playing
#   { "pause":  1.2, "at": 3.4 }        insert a still frame and silence (narration resumes after)
#   "auto_trim": false                  turn off the automatic trimming of idle, silent stretches (on by default)
# Effects (storyboard scene "effects"), timed to words:
#   { "type": "zoom|highlight|spotlight|marker|underline|callout", "target": {name,id,type,index} | "rect": {x,y,w,h},
#     "at_word": 3, "until_word": 7, "scale": 1.4 }
param(
    [string]$Dir = 'demo',
    [string[]]$Scenes,
    [switch]$Force
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
$W = if ($project.output.width) { [int]$project.output.width } else { 1920 }
$font = if ($project.brand.font) { $project.brand.font } else { 'Segoe UI' }
$accent = if ($project.brand.accent) { [Convert]::ToInt32(([string]$project.brand.accent).TrimStart('#').PadLeft(8, 'F').Substring(0, 8), 16) } else { [Convert]::ToInt32('FFFFB000', 16) }
$captionsOn = $project.captions -ne $false
$quality = 90
$rendererVersion = Get-DemoHash ((Get-FileHash (Join-Path $PSScriptRoot 'RenderClip.ps1')).Hash + (Get-FileHash (Join-Path $PSScriptRoot 'FrameCompose.cs')).Hash)

# --- easing (smootherstep: no overshoot on UI moves) ---
function Smooth([double]$x) { $x = [math]::Max(0, [math]::Min(1, $x)); $x * $x * $x * ($x * ($x * 6 - 15) + 10) }
function Envelope([double]$t, [double]$from, [double]$to, [double]$in, [double]$out) {
    # 0 before 'from', eases to 1 over 'in', holds, eases back to 0 over 'out' ending at 'to'.
    if ($t -lt $from -or $t -gt $to) { return 0.0 }
    [math]::Min((Smooth (($t - $from) / [math]::Max(0.01, $in))), (Smooth (($to - $t) / [math]::Max(0.01, $out))))
}

function Get-WordTime($Take, $Item, [string]$Which) {
    $w = @($Take.words)
    if ($Which -eq 'start') {
        if ($null -ne $Item.at_word) { return [double]$w[[math]::Min([int]$Item.at_word, $w.Count - 1)].start }
        if ($null -ne $Item.at) { return [double]$Item.at }
        return 0.0
    }
    if ($null -ne $Item.until_word) { return [double]$w[[math]::Min([int]$Item.until_word, $w.Count - 1)].end }
    if ($null -ne $Item.until) { return [double]$Item.until }
    $null
}

# Find a target in the take's page snapshots (the latest one taken before time t; t in seconds from the narration start).
function Resolve-TargetRect($Take, $Effect, [double]$T) {
    if ($Effect.rect) { return @{ x = [double]$Effect.rect.x; y = [double]$Effect.rect.y; w = [double]$Effect.rect.w; h = [double]$Effect.rect.h } }
    $tt = $Take.voice_start + [long]($T * 1e7)
    $snaps = @($Take.snapshots | Sort-Object t)
    # The page as it looks at time T: the first snapshot taken after the last action that started before T
    # (a snapshot is stamped when the page settled, which can be after T); else the latest one before T.
    $lastAct = @($Take.actions | Where-Object { [long]$_.start -le $tt } | Sort-Object { [long]$_.start } | Select-Object -Last 1)[0]
    $snap = $null
    if ($lastAct) { $snap = @($snaps | Where-Object { $_.t -ge [long]$lastAct.start } | Select-Object -First 1)[0] }
    if (-not $snap) { $snap = @($snaps | Where-Object { $_.t -le $tt } | Select-Object -Last 1)[0] }
    if (-not $snap) { $snap = $snaps[0] }
    $tg = $Effect.target
    if ($tg.text) {
        # A phrase on screen: rectangles were measured during the take (TextPattern) for every phrase the effects named.
        $hit = @($snap.texts | Where-Object { $_.text -eq $tg.text }) | Select-Object -First 1
        if (-not $hit) { $hit = @($snaps | ForEach-Object { $_.texts } | Where-Object { $_.text -eq $tg.text }) | Select-Object -First 1 }
        if (-not $hit) { throw "Phrase '$($tg.text)' was not measured in this take. Phrase targets are measured while recording: re-record the scene (or give a rect)." }
        return @{ x = [double]$hit.x; y = [double]$hit.y; w = [double]$hit.w; h = [double]$hit.h }
    }
    $hits = @($snap.elements | Where-Object {
        (-not $tg.type -or $_.type -eq $tg.type) -and (-not $tg.id -or $_.id -eq $tg.id) -and
        (-not $tg.name -or ($(if (([string]$tg.name).Contains('*')) { $_.name -like $tg.name } else { $_.name -eq $tg.name }))) })
    $idx = if ($tg.index) { [int]$tg.index } else { 0 }
    if ($hits.Count -le $idx) { throw "Effect target not found in the take's page snapshots: $($tg | ConvertTo-Json -Compress). Use a name from the snapshot, give a rect, or re-record." }
    $h = $hits[$idx]
    @{ x = [double]$h.x; y = [double]$h.y; w = [double]$h.w; h = [double]$h.h }
}

# Caption chunks over the narration's written text (keeps punctuation), split at natural breaks.
function Get-CaptionChunks($Take) {
    $text = [string]$Take.narration; $words = @($Take.words); $pos = @(); $cursor = 0
    foreach ($w in $words) { $k = $text.IndexOf([string]$w.text, $cursor, [StringComparison]::OrdinalIgnoreCase); if ($k -lt 0) { $k = $cursor }; $pos += $k; $cursor = $k + ([string]$w.text).Length }
    $chunks = @(); $first = 0
    for ($i = 0; $i -lt $words.Count; $i++) {
        $n = $i - $first + 1
        $soFar = $text.Substring($pos[$first], [math]::Min($text.Length, $pos[$i] + ([string]$words[$i].text).Length + 1) - $pos[$first])
        $gapAfter = if ($i + 1 -lt $words.Count) { [double]$words[$i + 1].start - [double]$words[$i].end } else { 0 }
        if (($i -eq $words.Count - 1) -or ($n -ge 3 -and $soFar.TrimEnd() -match '[\.\!\?;:,]$') -or $n -ge 9 -or $soFar.Length -ge 52 -or $gapAfter -gt 0.45) {
            $endChar = if ($i + 1 -lt $words.Count) { $pos[$i + 1] } else { $text.Length }
            $chunks += [pscustomobject]@{ text = $text.Substring($pos[$first], $endChar - $pos[$first]).Trim(); start = [double]$words[$first].start; end = [double]$words[$i].end }
            $first = $i + 1
        }
    }
    for ($c = 0; $c -lt $chunks.Count; $c++) { $chunks[$c].end = if ($c + 1 -lt $chunks.Count -and $chunks[$c + 1].start - $chunks[$c].end -lt 0.6) { $chunks[$c + 1].start } else { $chunks[$c].end + 0.4 } }
    $chunks
}

$targets = @(foreach ($s in $board.scenes) { if (-not $Scenes -or $s.id -in $Scenes) { $s } })
$built = 0
foreach ($scene in $targets) {
    $id = $scene.id
    $entry = $manifest.scenes.$id
    if (-not $entry -or -not $entry.take) { Write-Warning "${id}: no take yet; record it first."; continue }
    $takeDir = Join-Path $Dir "takes\$id\$($entry.take)"
    $take = Read-DemoJson (Join-Path $takeDir 'take.json')
    $post = [ordered]@{ take = $entry.take; effects = $scene.effects; edits = $scene.edits; auto_trim = $scene.auto_trim; captions = $captionsOn; width = $W; font = $font; accent = $accent; renderer = $rendererVersion }
    $renderHash = Get-DemoHash $post
    $clipDir = Join-Path $Dir "clips\$id"
    $clipPath = Join-Path $clipDir "$($entry.take)-$renderHash.mp4"
    if (-not $Force -and $entry.render_hash -eq $renderHash -and (Test-Path $clipPath)) { "${id}: clip up to date ($([IO.Path]::GetFileName($clipPath)))"; continue }
    if ($entry.record_hash -ne (Get-DemoSceneRecordHash $scene $project)) { Write-Warning "${id}: the storyboard changed since this take (narration or actions); the clip uses the old take. Re-record to update it." }
    $sw = [Diagnostics.Stopwatch]::StartNew()
    $cap = $take.capture
    $H = [int]([math]::Round($W * $cap.height / $cap.width / 2) * 2)
    $vs = [long]$take.voice_start
    function SecOf([long]$ticks) { ($ticks - $vs) / 1e7 }   # seconds from the narration start

    # Frames (source time in seconds from the narration start) with the cursor state logged at capture.
    $frames = @(Get-Content (Join-Path $takeDir 'frames.tsv') | ForEach-Object { $p = $_.Split("`t")
        [pscustomobject]@{ i = [int]$p[0]; t = (SecOf ([long]$p[1])); cx = $(if ($p.Count -gt 4) { [int]$p[2] } else { -1 }); cy = $(if ($p.Count -gt 4) { [int]$p[3] } else { -1 }); ck = $(if ($p.Count -gt 4) { [int]$p[4] } else { 0 }); cv = $(if ($p.Count -gt 5) { [int]$p[5] } else { 0 }) } })
    $sceneFrom = SecOf ([long]$take.start); $sceneTo = SecOf ([long]$take.end)
    $frames = @($frames | Where-Object { $_.t -ge $sceneFrom - 0.07 -and $_.t -lt $sceneTo })
    if ($frames.Count -lt 2) { throw "${id}: the take has too few frames." }
    $clicks = @($take.events | Where-Object { $_.kind -eq 'click' } | ForEach-Object { [pscustomobject]@{ t = (SecOf ([long]$_.t)); x = $_.x; y = $_.y } })
    $words = @($take.words)
    $speaking = { param($a, $b) foreach ($w in $words) { if ([double]$w.end + 0.15 -gt $a -and [double]$w.start - 0.15 -lt $b) { return $true } }; $false }

    # --- Edit list on the source timeline: segments of play / freeze, plus inserted pauses ---
    $cuts = @(); $freezes = @(); $pauses = @()
    foreach ($e in @($scene.edits)) {
        if (-not $e) { continue }
        if ($e.cut) { $a = [double]$e.cut[0]; $b = [double]$e.cut[1]; if (& $speaking $a $b) { Write-Warning "${id}: cut $a-$b overlaps narration; skipped (cut only where nobody is speaking)." } else { $cuts += , @($a, $b) } }
        if ($e.freeze) { $freezes += , @([double]$e.freeze[0], [double]$e.freeze[1]) }
        if ($e.pause) { $pauses += [pscustomobject]@{ at = (Get-WordTime $take $e 'start'); sec = [double]$e.pause } }
    }
    # Automatic: trim idle stretches (nothing moving, nobody speaking, no action) longer than 1.5 s down to 0.6 s.
    $autoCuts = @()
    if ($scene.auto_trim -ne $false) {
        $busy = @($take.actions | ForEach-Object { , @(((SecOf ([long]$_.start)) - 0.2), ((SecOf ([long]$_.end)) + 0.5)) })
        $still = @(); $runStart = $null
        for ($k = 1; $k -lt $frames.Count; $k++) {
            $diff = [DemoKit.FrameCompose]::Difference((Join-Path $takeDir ('f{0:D6}.jpg' -f $frames[$k - 1].i)), (Join-Path $takeDir ('f{0:D6}.jpg' -f $frames[$k].i)))
            $moving = $diff -gt 0.6 -or ($frames[$k].cx -ne $frames[$k - 1].cx -or $frames[$k].cy -ne $frames[$k - 1].cy)
            if (-not $moving) { if ($null -eq $runStart) { $runStart = $frames[$k - 1].t } }
            elseif ($null -ne $runStart) { $still += , @($runStart, $frames[$k - 1].t); $runStart = $null }
        }
        if ($null -ne $runStart) { $still += , @($runStart, $frames[-1].t) }
        foreach ($r in $still) {
            $a = [double]$r[0] + 0.3; $b = [double]$r[1] - 0.3
            if ($a -lt 0.3) { continue }                                          # keep the establishing moment
            if ($b -gt [double]$take.duration) { $b = [math]::Min($b, $sceneTo - 0.7) } # keep a short tail
            if ($b - $a -lt 0.9) { continue }
            if (& $speaking $a $b) { continue }
            $overlapsAction = $false; foreach ($x in $busy) { if ($x[1] -gt $a -and $x[0] -lt $b) { $overlapsAction = $true } }
            if ($overlapsAction) { continue }
            $autoCuts += , @($a, $b)
        }
    }
    $allCuts = @($cuts + $autoCuts | Sort-Object { $_[0] })

    # Output plan: each output frame = (source frame, source time for effects, duration). Holds/pauses repeat a frame.
    $plan = New-Object System.Collections.Generic.List[object]
    $inCut = { param($t) foreach ($c in $allCuts) { if ($t -ge $c[0] -and $t -lt $c[1]) { return $true } }; $false }
    $frozenAt = { param($t) foreach ($f in $freezes) { if ($t -ge $f[0] -and $t -lt $f[1]) { return $f[0] } }; $null }
    $pauseQueue = @($pauses | Sort-Object at)
    $pq = 0; $afterCut = $false
    for ($k = 0; $k -lt $frames.Count; $k++) {
        $f = $frames[$k]
        $from = if ($k -eq 0) { $sceneFrom } else { $f.t }
        $to = if ($k + 1 -lt $frames.Count) { $frames[$k + 1].t } else { $sceneTo }
        if (& $inCut $from) { $afterCut = $true; continue }
        while ($pq -lt $pauseQueue.Count -and $pauseQueue[$pq].at -le $from) {
            $plan.Add([pscustomobject]@{ frame = $f; src = $from; dur = $pauseQueue[$pq].sec; kind = 'pause'; blend = $false }); $pq++
        }
        $fz = & $frozenAt $from
        $useFrame = $f
        if ($null -ne $fz) { $useFrame = ($frames | Where-Object { $_.t -le $fz } | Select-Object -Last 1); if (-not $useFrame) { $useFrame = $f } }
        $plan.Add([pscustomobject]@{ frame = $useFrame; src = $(if ($null -ne $fz) { $fz } else { $from }); dur = [math]::Max(0.001, $to - $from); kind = 'play'; blend = $afterCut; audioFrom = $from })
        $afterCut = $false
    }

    # --- Effects: resolve targets, compute envelopes per output frame ---
    $fx = @()
    foreach ($e in @($scene.effects)) {
        if (-not $e) { continue }
        $cue = Get-WordTime $take $e 'start'
        $phraseEnd = Get-WordTime $take $e 'end'
        $rect = Resolve-TargetRect $take $e $cue
        $vx = [math]::Max(0, [math]::Min($rect.x + $rect.w, $cap.x + $cap.width) - [math]::Max($rect.x, $cap.x))
        $vy = [math]::Max(0, [math]::Min($rect.y + $rect.h, $cap.y + $cap.height) - [math]::Max($rect.y, $cap.y))
        if ($rect.w * $rect.h -le 0 -or ($vx * $vy) / ($rect.w * $rect.h) -lt 0.6) { Write-Warning "${id}: $($e.type) target is mostly off-screen at word $($e.at_word); effect skipped. Scroll it into view first or pick another target."; continue }
        $def = switch ($e.type) {
            'zoom'      { @{ lead = 0.6; in = 0.75; out = 0.9; tail = 0.4; min = 1.5 } }
            'highlight' { @{ lead = 0.0; in = 0.22; out = 0.2; tail = 0.3; min = 1.0 } }
            'marker'    { @{ lead = 0.0; in = 0.2; out = 0.2; tail = 0.3; min = 1.0 } }
            'underline' { @{ lead = 0.0; in = 0.2; out = 0.2; tail = 0.3; min = 1.0 } }
            'spotlight' { @{ lead = 0.2; in = 0.3; out = 0.3; tail = 0.4; min = 1.2 } }
            'callout'   { @{ lead = 0.0; in = 0.2; out = 0.15; tail = 0.4; min = 1.5 } }
        }
        if ($null -eq $phraseEnd) { $phraseEnd = $cue + 1.6 }
        $from = $cue - $def.lead
        $to = [math]::Max($phraseEnd + $def.tail, $cue + $def.min) + $def.out
        $to = [math]::Min($to, $sceneTo - 0.5)                         # every effect ends before the scene's last 0.5 s
        $fx += [pscustomobject]@{ type = $e.type; rect = $rect; from = $from; to = $to; in = $def.in; out = $def.out; cue = $cue
                                  scale = $(if ($e.scale) { [math]::Min(2.0, [double]$e.scale) } elseif ($e.type -eq 'callout') { 1.8 } else { 1.4 }) }
    }
    # Zoom camera: chained zooms closer than 1.5 s pan directly instead of zooming out and back in.
    $zooms = @($fx | Where-Object { $_.type -eq 'zoom' } | Sort-Object from)
    function Get-Camera([double]$t) {
        $full = @{ cx = $cap.width / 2; cy = $cap.height / 2; s = 1.0 }
        $state = $full
        for ($z = 0; $z -lt $zooms.Count; $z++) {
            $zm = $zooms[$z]; $next = if ($z + 1 -lt $zooms.Count) { $zooms[$z + 1] } else { $null }; $prev = if ($z -gt 0) { $zooms[$z - 1] } else { $null }
            $chainIn = $prev -and ($zm.from - $prev.to) -lt 1.5
            $chainOut = $next -and ($next.from - $zm.to) -lt 1.5
            $target = @{ cx = $zm.rect.x + $zm.rect.w / 2 - $cap.x; cy = $zm.rect.y + $zm.rect.h / 2 - $cap.y
                         s = [math]::Max(1.0, [math]::Min($zm.scale, [math]::Min($cap.width / ($zm.rect.w * 1.15), $cap.height / ($zm.rect.h * 1.15)))) }
            $target.s = [math]::Min($target.s, $cap.width / $W)                      # never upscale past the captured pixels
            if ($target.s -lt 1.0) { $target.s = 1.0 }
            if ($t -lt $zm.from) { continue }
            $inEnd = $zm.from + $zm.in; $outStart = $zm.to - $zm.out
            $start = if ($chainIn) { $prevTarget } else { $full }
            if ($t -le $inEnd) { $p = Smooth (($t - $zm.from) / $zm.in); $state = @{ cx = $start.cx + ($target.cx - $start.cx) * $p; cy = $start.cy + ($target.cy - $start.cy) * $p; s = $start.s + ($target.s - $start.s) * $p } }
            elseif ($t -le $outStart -or $chainOut) { $state = $target }
            elseif ($t -le $zm.to) { $p = Smooth (($t - $outStart) / $zm.out); $state = @{ cx = $target.cx + ($full.cx - $target.cx) * $p; cy = $target.cy + ($full.cy - $target.cy) * $p; s = $target.s + (1 - $target.s) * $p } }
            else { $state = if ($chainOut) { $target } else { $full } }
            $prevTarget = $target
        }
        $cw = $cap.width / $state.s; $ch = $cap.height / $state.s
        @{ x = [math]::Max(0, [math]::Min($cap.width - $cw, $state.cx - $cw / 2)); y = [math]::Max(0, [math]::Min($cap.height - $ch, $state.cy - $ch / 2)); w = $cw; h = $ch }
    }

    $chunks = if ($captionsOn) { @(Get-CaptionChunks $take) } else { @() }
    $renderDir = Join-Path $clipDir '_frames'
    Remove-Item -Recurse -Force $renderDir -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Force $renderDir | Out-Null
    $jobs = New-Object System.Collections.Generic.List[DemoKit.FrameJob]
    $timeline = New-Object System.Collections.Generic.List[object]
    $clock = 0.0; $lastDst = $null; $blendLeft = 0.0
    for ($n = 0; $n -lt $plan.Count; $n++) {
        $o = $plan[$n]; $t = [double]$o.src
        $j = New-Object DemoKit.FrameJob
        $j.Src = Join-Path $takeDir ('f{0:D6}.jpg' -f $o.frame.i)
        $j.Dst = Join-Path $renderDir ('o{0:D5}.jpg' -f $n)
        $cam = Get-Camera $t
        $j.CropX = $cam.x; $j.CropY = $cam.y; $j.CropW = $cam.w; $j.CropH = $cam.h
        $list = New-Object System.Collections.Generic.List[DemoKit.Effect]
        foreach ($e in $fx) {
            if ($e.type -eq 'zoom') { continue }
            $p = Envelope $t $e.from $e.to $e.in $e.out
            if ($p -le 0) { continue }
            $ef = New-Object DemoKit.Effect
            $ef.Kind = $e.type; $ef.X = $e.rect.x - $cap.x; $ef.Y = $e.rect.y - $cap.y; $ef.W = $e.rect.w; $ef.H = $e.rect.h
            $ef.P = $(if ($e.type -eq 'callout') { [math]::Min(1, ($t - $e.from) / $e.in) * [math]::Min(1, [math]::Max(0, ($e.to - $t) / $e.out)) } else { $p })
            $ef.Q = [math]::Min(1, [math]::Max(0, ($t - $e.cue) / 0.35)); $ef.Scale = $e.scale; $ef.Color = $accent
            $list.Add($ef)
        }
        if ($list.Count) { $j.Effects = $list.ToArray() }
        if ($o.frame.cv -eq 1 -and $o.frame.cx -ge 0) { $j.CursorX = $o.frame.cx - $cap.x; $j.CursorY = $o.frame.cy - $cap.y; $j.CursorKind = [math]::Min(3, $o.frame.ck) }
        $recent = $clicks | Where-Object { $_.t -le $t -and $t - $_.t -lt 0.45 } | Select-Object -Last 1
        if ($recent -and $o.kind -eq 'play') { $j.RippleX = $recent.x - $cap.x; $j.RippleY = $recent.y - $cap.y; $j.RippleT = ($t - $recent.t) / 0.45 }
        if ($chunks) { $cc = $chunks | Where-Object { $t -ge $_.start - 0.05 -and $t -lt $_.end } | Select-Object -First 1; if ($cc) { $j.Caption = $cc.text } }
        # Crossfade 0.25 s across every cut so nothing jumps.
        if ($o.blend -and $lastDst) { $blendFrom = $lastDst; $blendLeft = 0.25 }
        if ($blendLeft -gt 0) { $j.Blend = $blendFrom; $j.BlendAlpha = [math]::Max(0, $blendLeft / 0.25); $blendLeft -= $o.dur }
        $jobs.Add($j); $timeline.Add([pscustomobject]@{ file = $j.Dst; out = $clock; dur = $o.dur; src = $t; kind = $o.kind; audioFrom = $o.audioFrom })
        $clock += $o.dur
        if ($blendLeft -le 0) { $lastDst = $j.Dst }
    }
    [DemoKit.FrameCompose]::RenderAll($jobs.ToArray(), $W, $H, [long]$quality, $font)

    # --- Narration: place every audio part on the output timeline, following the edits ---
    # Map source narration time -> output time: walk the plan; each 'play' entry carries audio from its source span.
    $audioSpans = New-Object System.Collections.Generic.List[object]
    foreach ($e in $timeline) {
        if ($e.kind -ne 'play') { continue }
        $a = [double]$e.audioFrom; $b = $a + $e.dur
        if ($audioSpans.Count -and [math]::Abs($audioSpans[$audioSpans.Count - 1].srcTo - $a) -lt 0.002 -and [math]::Abs(($audioSpans[$audioSpans.Count - 1].outTo) - $e.out) -lt 0.002) {
            $audioSpans[$audioSpans.Count - 1].srcTo = $b; $audioSpans[$audioSpans.Count - 1].outTo = $e.out + $e.dur
        } else { $audioSpans.Add([pscustomobject]@{ srcFrom = $a; srcTo = $b; outFrom = $e.out; outTo = $e.out + $e.dur }) }
    }
    $comp = [Windows.Media.Editing.MediaComposition]::new()
    foreach ($e in $timeline) {
        $clip = Wait-WinRT ([Windows.Media.Editing.MediaClip]::CreateFromImageFileAsync((Get-StorageFile $e.file), [TimeSpan]::FromTicks([long]($e.dur * 1e7)))) ([Windows.Media.Editing.MediaClip])
        Add-WinRTItem $comp.Clips $clip ([Windows.Media.Editing.MediaClip])
    }
    $placed = 0
    foreach ($part in @($take.audio)) {
        $pFrom = [double]$part.offset; $pTo = $pFrom + [double]$part.duration
        foreach ($sp in $audioSpans) {
            $a = [math]::Max($sp.srcFrom, $pFrom); $b = [math]::Min($sp.srcTo, $pTo)
            if ($b - $a -lt 0.01) { continue }
            $track = Wait-WinRT ([Windows.Media.Editing.BackgroundAudioTrack]::CreateFromFileAsync((Get-StorageFile (Join-Path $Dir $part.file)))) ([Windows.Media.Editing.BackgroundAudioTrack])
            $track.TrimTimeFromStart = [TimeSpan]::FromTicks([long](($a - $pFrom) * 1e7))
            $track.TrimTimeFromEnd = [TimeSpan]::FromTicks([long]([math]::Max(0, $track.OriginalDuration.TotalSeconds - ($b - $pFrom)) * 1e7))
            $track.Delay = [TimeSpan]::FromTicks([long](($sp.outFrom + ($a - $sp.srcFrom)) * 1e7))
            Add-WinRTItem $comp.BackgroundAudioTracks $track ([Windows.Media.Editing.BackgroundAudioTrack])
            $placed++
        }
    }
    $profile = [Windows.Media.MediaProperties.MediaEncodingProfile]::CreateMp4([Windows.Media.MediaProperties.VideoEncodingQuality]::HD1080p)
    $profile.Video.Width = $W; $profile.Video.Height = $H
    $profile.Video.FrameRate.Numerator = 30; $profile.Video.FrameRate.Denominator = 1
    $profile.Video.Bitrate = [uint32]([math]::Min(12000000, $W * $H * 3))
    New-Item -ItemType Directory -Force $clipDir | Out-Null
    $result = Wait-WinRTProgress ($comp.RenderToFileAsync((New-StorageFile $clipPath), [Windows.Media.Editing.MediaTrimmingPreference]::Precise, $profile)) ([Windows.Media.Transcoding.TranscodeFailureReason]) ([double])
    if ("$result" -ne 'None') { throw "${id}: render failed: $result" }

    # Clip captions (clip-relative times), first/last frames for transitions, and the record of how it was made.
    $srt = @(); $toOut = { param($src) foreach ($e in $timeline) { if ($e.kind -eq 'play' -and $src -ge $e.src - 0.001 -and $src -lt $e.src + $e.dur) { return $e.out + ($src - $e.src) } }; $null }
    foreach ($c in $chunks) { $a = & $toOut $c.start; $b = & $toOut ([math]::Max($c.start, $c.end - 0.01)); if ($null -ne $a -and $null -ne $b) { $srt += [pscustomobject]@{ text = $c.text; start = [math]::Round($a, 3); end = [math]::Round($b + 0.01, 3) } } }
    Copy-Item $timeline[0].file (Join-Path $clipDir "$($entry.take)-$renderHash.first.jpg") -Force
    Copy-Item $timeline[$timeline.Count - 1].file (Join-Path $clipDir "$($entry.take)-$renderHash.last.jpg") -Force
    $back = Wait-WinRT ([Windows.Media.Editing.MediaClip]::CreateFromFileAsync((Get-StorageFile $clipPath))) ([Windows.Media.Editing.MediaClip])
    $info = [ordered]@{
        scene = $id; take = $entry.take; render_hash = $renderHash; file = [IO.Path]::GetFileName($clipPath); seconds = [math]::Round($clock, 3)
        readback_seconds = [math]::Round($back.OriginalDuration.TotalSeconds, 3); width = $W; height = $H; frames = $jobs.Count; audio_tracks = $placed
        cuts = @($cuts | ForEach-Object { , @($_) }); auto_cuts = @($autoCuts | ForEach-Object { , @([math]::Round($_[0], 2), [math]::Round($_[1], 2)) }); freezes = $freezes; pauses = $pauses
        effects = @($fx | ForEach-Object { [ordered]@{ type = $_.type; from = [math]::Round($_.from, 2); to = [math]::Round($_.to, 2); rect = $_.rect } })
        captions = $srt; inputs = $post
    }
    Write-DemoJson $info (Join-Path $clipDir "$($entry.take)-$renderHash.json")
    Remove-Item -Recurse -Force $renderDir
    Set-DemoManifestScene $manifest $id @{ clip = (Get-DemoRelativePath $Dir $clipPath); render_hash = $renderHash; clip_seconds = $info.seconds }
    Save-DemoManifest $Dir $manifest
    Write-DemoLog $Dir 'render-clip' @{ scene = $id; take = $entry.take; render_hash = $renderHash; clip = (Get-DemoRelativePath $Dir $clipPath); seconds = $info.seconds
        auto_cuts = $info.auto_cuts.Count; effects = $fx.Count; took = [math]::Round($sw.Elapsed.TotalSeconds, 1) }
    '{0}: clip {1:N2}s ({2} frames, {3} auto-trim, {4} effects) in {5:N1}s -> {6}' -f $id, $clock, $jobs.Count, $autoCuts.Count, $fx.Count, $sw.Elapsed.TotalSeconds, (Get-DemoRelativePath $Dir $clipPath)
    if ([math]::Abs($back.OriginalDuration.TotalSeconds - $clock) -gt 0.3) { Write-Warning "${id}: rendered length $($back.OriginalDuration.TotalSeconds)s differs from plan $clock s." }
    $built++
}
"$built clip(s) rendered."
