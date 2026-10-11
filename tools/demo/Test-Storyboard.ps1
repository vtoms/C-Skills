# Checks demo/storyboard.json and demo/project.json before anything moves the mouse.
# Errors stop the pipeline; warnings are for the human checkpoint.
# Uses real word timings from build/audio when Record.ps1 -VoiceOnly has run, otherwise estimates 2.3 words/s.
param([string]$Dir = 'demo', [switch]$Quiet)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
$Dir = (Resolve-Path $Dir).Path
$errors = New-Object System.Collections.Generic.List[string]
$warnings = New-Object System.Collections.Generic.List[string]
function Err($m) { $errors.Add($m) }
function Warn($m) { $warnings.Add($m) }

$projectPath = Join-Path $Dir 'project.json'; $boardPath = Join-Path $Dir 'storyboard.json'
if (-not (Test-Path $projectPath)) { Err 'demo/project.json is missing (run the setup questions first).' }
if (-not (Test-Path $boardPath)) { Err 'demo/storyboard.json is missing.' }
if ($errors.Count) { $errors | ForEach-Object { "ERROR: $_" }; exit 1 }
try { $project = Read-DemoJson $projectPath } catch { Err "project.json is not valid JSON: $($_.Exception.Message)" }
try { $board = Read-DemoJson $boardPath } catch { Err "storyboard.json is not valid JSON: $($_.Exception.Message)" }
if ($errors.Count) { $errors | ForEach-Object { "ERROR: $_" }; exit 1 }

# --- project.json ---
if (-not $project.app_url) { Err 'project.json: app_url is required.' }
if ($null -eq $project.monitor) { Err 'project.json: monitor is required (ask which screen to record).' }
else { $count = [System.Windows.Forms.Screen]::AllScreens.Count; if ([int]$project.monitor -ge $count) { Err "project.json: monitor $($project.monitor) does not exist (this PC has $count)." } }
if ($null -eq $project.fullscreen) { Err 'project.json: fullscreen (true/false) is required (ask whether to use F11).' }
if ($null -eq $project.zoom) { Err 'project.json: zoom is required (ask which browser zoom % to use).' }
elseif ([int]$project.zoom -lt 25 -or [int]$project.zoom -gt 300) { Err 'project.json: zoom must be 25..300.' }
if ($project.profile -and $project.profile -notin 'private', 'dedicated', 'attach') { Err "project.json: profile must be private, dedicated or attach." }
if ($project.profile -eq 'attach' -and -not $project.window_title) { Err "project.json: profile 'attach' needs window_title." }
if ($project.voice.engine -and $project.voice.engine -notin 'aria', 'builtin') { Err 'project.json: voice.engine must be aria or builtin.' }

# --- storyboard.json ---
$scenes = @($board.scenes)
if (-not $board.title) { Warn 'storyboard: no title (the title card will be skipped).' }
if ($scenes.Count -eq 0) { Err 'storyboard: no scenes.' }
$ids = @{}
$pointer = 'click', 'double_click', 'right_click', 'hover', 'type'
$known = $pointer + 'key', 'scroll', 'navigate', 'wait'
$risky = '(?i)\b(delete|remove|destroy|drop|pay|purchase|buy|checkout|send|submit|publish|post|transfer|unsubscribe|deactivate|reset)\b'
$audioDir = Join-Path $Dir 'audio'
$script:callouts = 0
$total = 0.0

foreach ($s in $scenes) {
    $sid = if ($s.id) { $s.id } else { '(no id)' }
    if (-not $s.id) { Err 'storyboard: a scene has no id.' } elseif ($ids.ContainsKey($s.id)) { Err "storyboard: duplicate scene id $($s.id)." } else { $ids[$s.id] = 1 }
    if ($s.id -and $s.id -notmatch '^[A-Za-z0-9_-]+$') { Err "${sid}: id may only use letters, digits, - and _ (it names files)." }
    if (-not $s.narration) { Err "${sid}: narration is empty."; continue }
    $plain = [regex]::Replace([string]$s.narration, '\s*\[pause\s+\d+\s*ms\]\s*', ' ', 'IgnoreCase')
    $words = @($plain -split '\s+' | Where-Object { $_ })

    # Word timings: real ones when the narration audio exists and matches, else an estimate.
    $times = $null; $dur = $null
    $metaPath = Join-Path $audioDir "$($s.id).timing.json"
    if (Test-Path $metaPath) {
        $m = Read-DemoJson $metaPath
        if ($m.narration -eq $plain.Trim()) { $times = @($m.words | ForEach-Object { [double]$_.start }); $dur = [double]$m.duration }
    }
    $estimated = -not $times
    if ($estimated) { $times = @(for ($i = 0; $i -lt $words.Count; $i++) { $i / 2.3 }); $dur = $words.Count / 2.3 + 0.4 }
    $pauseSec = 0.0; foreach ($pm in [regex]::Matches([string]$s.narration, '\[pause\s+(\d+)\s*ms\]', 'IgnoreCase')) { $pauseSec += [double]$pm.Groups[1].Value / 1000 }
    $wps = $times.Count / [math]::Max(0.1, $dur - $pauseSec)   # deliberate pauses do not count against the pace
    if ($wps -gt 3.1) { Warn ("{0}: narration runs {1:N1} words/s (over 3.1 sounds rushed; aim for 2.2-2.7)." -f $sid, $wps) }
    if (-not $estimated -and $wps -lt 1.8) { Warn ("{0}: narration runs {1:N1} words/s (slow; aim for 2.2-2.7)." -f $sid, $wps) }
    if ($words.Count -gt 45) { Warn "${sid}: $($words.Count) words in one scene; split it (one idea per scene)." }
    if ($s.narration -match '\[NEEDS:') { Err "${sid}: narration still has a [NEEDS: ...] marker." }

    # Simulate the schedule: when could each action really land, versus the word it is tied to?
    $clock = 0.0; $prevKey = 0.0
    foreach ($a in @($s.pre) + @($s.actions)) {
        if (-not $a) { continue }
        if ($a.do -notin $known) { Err "${sid}: unknown action '$($a.do)'. Use one of: $($known -join ', ')."; continue }
        if ($a.do -in $pointer -and -not $a.target) { Err "${sid}: '$($a.do)' needs a target." }
        if ($a.target -and -not ($a.target.name -or $a.target.id -or $a.target.type)) { Err "${sid}: a target needs name, id or type." }
        if ($a.do -eq 'type' -and $null -eq $a.text) { Err "${sid}: 'type' needs text." }
        if ($a.do -eq 'key' -and -not $a.keys) { Err "${sid}: 'key' needs keys, e.g. 'Ctrl+K'." }
        if ($a.do -eq 'navigate' -and -not $a.url) { Err "${sid}: 'navigate' needs url." }
        if ($a.do -eq 'wait' -and -not ($a.ms -or $a.for)) { Err "${sid}: 'wait' needs ms or for." }
        $label = "$($a.target.name)$($a.target.id) $($a.text)"
        if ($label -match $risky) { Warn "${sid}: '$($a.do)' on '$($label.Trim())' looks destructive or outward-facing; confirm it is safe test data." }
        if ($null -ne $a.at_word -and ([int]$a.at_word -lt 0 -or [int]$a.at_word -ge $times.Count)) { Err "${sid}: at_word $($a.at_word) is outside 0..$($times.Count - 1)." }
    }
    $clock = 0.0
    foreach ($a in @($s.actions)) {
        if (-not $a -or $a.do -notin $known) { continue }
        $want = if ($null -ne $a.at_word -and [int]$a.at_word -lt $times.Count -and [int]$a.at_word -ge 0) { $times[[int]$a.at_word] } elseif ($null -ne $a.at) { [double]$a.at } else { $null }
        $cost = switch ($a.do) {
            'type' { 0.25 + 0.7 + 0.25 + ([string]$a.text).Length / $(if ($a.cps) { [double]$a.cps } else { 18 }) + 0.35; break }
            'navigate' { 0.3 + ([string]$a.url).Length * 0.01 + 1.5; break }
            'wait' { if ($a.ms) { $a.ms / 1000 } else { 1.0 }; break }
            { $_ -in $pointer } { 0.25 + 0.7 + 0.15 + 0.35 }
            default { 0.5 }
        }
        $landAfter = if ($a.do -in $pointer) { 1.1 } else { 0 }   # find target (~0.25 s) + glide (0.7 s) + press: the click lands this far into the action
        if ($null -ne $want) {
            $ready = $clock + $landAfter
            if ($ready - $want -gt 0.3) { Warn ("{0}: '{1}' is tied to {2:N1}s but the action before it is still running until {3:N1}s; move it to a later word or speed up the earlier step." -f $sid, $a.do, $want, ($ready)) }
            $clock = [math]::Max($clock, $want - $landAfter) + $cost
        } else { $clock += $cost }
    }
    $sceneLen = [math]::Max(0.4 + $dur + 0.7, $clock + 0.4)
    if ($clock -gt $dur + 2) { Warn ("{0}: actions run {1:N1}s past the narration (dead air). Add narration or trim actions." -f $sid, ($clock - $dur)) }
    if ($s.zoom) { Err ("{0}: 'zoom' was replaced by the 'effects' list, e.g. effects: [ {{ type: 'zoom', target: {{...}}, at_word: 3 }} ]." -f $sid) }
    $moveCount = 0
    foreach ($e in @($s.effects)) {
        if (-not $e) { continue }
        if ($e.type -notin 'zoom', 'highlight', 'spotlight', 'marker', 'underline', 'callout') { Err "${sid}: unknown effect type '$($e.type)'."; continue }
        if (-not $e.target -and -not $e.rect) { Err "${sid}: effect '$($e.type)' needs a target (name/id/type) or a rect." }
        foreach ($f in 'at_word', 'until_word') { if ($null -ne $e.$f -and ([int]$e.$f -lt 0 -or [int]$e.$f -ge $times.Count)) { Err "${sid}: effect $f $($e.$f) is outside 0..$($times.Count - 1)." } }
        if ($null -ne $e.until_word -and $null -ne $e.at_word -and [int]$e.until_word -lt [int]$e.at_word) { Err "${sid}: effect until_word is before at_word." }
        if ($e.type -eq 'zoom') {
            $moveCount++
            if ($e.scale -and [double]$e.scale -gt 2.0) { Err "${sid}: zoom scale $($e.scale) is over the 2.0 cap (motion comfort and sharpness)." }
            elseif ($e.scale -and [double]$e.scale -gt 1.8) { Warn "${sid}: zoom scale $($e.scale) is deep; 1.25-1.5 suits most UI, up to 1.8 for dense text." }
        }
        if ($e.type -eq 'callout') { $script:callouts++ }
    }
    if ($moveCount -gt 2) { Warn "${sid}: $moveCount zooms in one scene; keep one dominant camera move per scene (chained pans count as one)." }
    if (@($s.effects | Where-Object { $_.type -eq 'spotlight' }).Count -gt 1) { Warn "${sid}: more than one spotlight in a scene." }
    $total += $sceneLen
}
if ($board.title -and $project.title_card -ne $false) { $total += 2.5 }
if ($script:callouts -gt 2) { Warn "storyboard: $($script:callouts) magnifier callouts; more than two per video gets distracting." }

if (-not $Quiet) {
    $errors | ForEach-Object { "ERROR: $_" }
    $warnings | ForEach-Object { "WARN:  $_" }
    "{0} scenes, about {1:N0}s of video{2}. {3} errors, {4} warnings." -f $scenes.Count, $total, $(if ($estimated) { ' (timing estimated; run Record.ps1 -VoiceOnly for real timings)' } else { '' }), $errors.Count, $warnings.Count
}
if ($errors.Count) { exit 1 }