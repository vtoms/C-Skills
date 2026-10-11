# WinDrive: drives a real browser with Windows UI Automation + the real cursor and keyboard.
# Works with any browser (no debug flag needed). Built-in only: UIAutomationClient, Win32 via Add-Type.

Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
Add-Type -AssemblyName UIAutomationClient, UIAutomationTypes

Enable-DemoDpiAwareness

$script:ActionLog = $null
$script:Settle = 350   # ms to let the page react after an action
$script:LastClick = 0
function Get-DemoLastClick { $script:LastClick }

$VK = @{ Ctrl = 0x11; Shift = 0x10; Alt = 0x12; Win = 0x5B; Enter = 0x0D; Tab = 0x09; Esc = 0x1B; Space = 0x20
         Back = 0x08; Delete = 0x2E; Up = 0x26; Down = 0x28; Left = 0x25; Right = 0x27; Home = 0x24; End = 0x23
         PageUp = 0x21; PageDown = 0x22; F5 = 0x74; F11 = 0x7A; Plus = 0xBB; Minus = 0xBD; Zero = 0x30; L = 0x4C; A = 0x41 }

function Set-DemoActionLog([string]$Path) { $script:ActionLog = $Path; if ($Path -and -not (Test-Path $Path)) { New-Item -ItemType File -Force $Path | Out-Null } }
function Write-DemoAction([string]$Kind, [hashtable]$Data = @{}) {
    if (-not $script:ActionLog) { return }
    $Data['kind'] = $Kind; $Data['t'] = [DateTime]::UtcNow.Ticks
    $p = [DemoKit.Win32Input]::CursorPosition(); $Data['x'] = $p.X; $Data['y'] = $p.Y
    Add-Content -Encoding UTF8 -Path $script:ActionLog -Value ($Data | ConvertTo-Json -Compress)
}

# --- Browser window ---
function Get-DemoBrowserWindow([string]$Browser = 'msedge', [string]$TitleLike = '*') {
    # Top-level windows of that browser's processes whose title matches (a process can own several windows).
    $ids = @(Get-Process -Name $Browser -ErrorAction SilentlyContinue | ForEach-Object Id)
    if (-not $ids) { return $null }
    $AE = [System.Windows.Automation.AutomationElement]
    foreach ($w in $AE::RootElement.FindAll([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition)) {
        try { if ($ids -contains $w.Current.ProcessId -and $w.Current.Name -like $TitleLike -and $w.Current.Name) { return $w } } catch { }
    }
    $null
}
function Start-DemoBrowser([string]$Browser, [string]$Url, [string]$ProfileDir, [string]$TitleLike = '*', [switch]$Private) {
    $candidates = switch ($Browser) {
        'msedge' { @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe") }
        'chrome' { @("$env:ProgramFiles\Google\Chrome\Application\chrome.exe", "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe", "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe") }
        default { @($Browser) }
    }
    $exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) { throw "Browser '$Browser' not found." }
    # A separate profile folder keeps takes clean (no sign-in, extensions or leftover state). No debug or special flags:
    # page content is reached through UI Automation exactly as in a browser the user opened (see Enable-DemoPageAccessibility).
    if (-not $ProfileDir) { $ProfileDir = Join-Path $env:TEMP ("demo-browser-" + [guid]::NewGuid().ToString("N").Substring(0, 8)); $script:ThrowawayProfile = $ProfileDir }
    $argList = @('--new-window', '--no-first-run', '--disable-session-crashed-bubble', '--no-default-browser-check', "--user-data-dir=$ProfileDir")
    # Private window: no account sign-in, no extensions, no leftover state between takes.
    if ($Private) { $argList += $(if ($Browser -eq 'chrome') { '--incognito' } else { '--inprivate' }) }
    $argList += $Url
    $p = Start-Process -FilePath $exe -ArgumentList $argList -PassThru
    $deadline = (Get-Date).AddSeconds(20)
    do { Start-Sleep -Milliseconds 400; $w = Get-DemoBrowserWindow ([IO.Path]::GetFileNameWithoutExtension($exe)) $TitleLike } while (-not $w -and (Get-Date) -lt $deadline)
    if (-not $w) { throw "Browser window did not appear within 20 s." }
    $w
}
# Puts the window on the chosen monitor, maximised, optionally F11 full screen, and sets page zoom.
function Initialize-DemoView($Window, [int]$Monitor = 0, [bool]$FullScreen = $false, [int]$ZoomPercent = 100) {
    $hwnd = [IntPtr]$Window.Current.NativeWindowHandle
    $screen = Get-DemoMonitor $Monitor; $m = $screen.WorkingArea; $b = $screen.Bounds
    [void][DemoKit.Win32Input]::ShowWindow($hwnd, 9)
    [void][DemoKit.Win32Input]::MoveWindow($hwnd, $m.X + 20, $m.Y + 20, [math]::Max(800, $m.Width - 40), [math]::Max(600, $m.Height - 40), $true)
    [void][DemoKit.Win32Input]::ShowWindow($hwnd, 3)  # maximise on that monitor
    $ladder = @(25, 33, 50, 67, 75, 80, 90, 100, 110, 125, 150, 175, 200, 250, 300)
    $target = ($ladder | Sort-Object { [math]::Abs($_ - $ZoomPercent) } | Select-Object -First 1)
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        # A freshly started browser may not have keyboard focus yet: activate, click the page body, then send keys.
        [void][DemoKit.Win32Input]::Activate($hwnd); Start-Sleep -Milliseconds 600
        $doc = Get-DemoDocument $Window 4000
        if ($doc) { $r = $doc.Current.BoundingRectangle; [DemoKit.Win32Input]::Glide([int]($r.X + 12), [int]($r.Y + $r.Height - 12), 150); [DemoKit.Win32Input]::Click($false, 40); Start-Sleep -Milliseconds 200 }
        [DemoKit.Win32Input]::Chord(@($VK.Ctrl, $VK.Zero)); Start-Sleep -Milliseconds 250
        $from = $ladder.IndexOf(100); $to = $ladder.IndexOf($target)
        $key = if ($to -gt $from) { $VK.Plus } else { $VK.Minus }
        for ($i = 0; $i -lt [math]::Abs($to - $from); $i++) { [DemoKit.Win32Input]::Chord(@($VK.Ctrl, $key)); Start-Sleep -Milliseconds 150 }
        Start-Sleep -Milliseconds 300
        $zoomOk = ($target -eq 100) -or ((Get-DemoBrowserZoom $Window) -eq $target)   # check before F11 hides the toolbar
        if ($zoomOk -and $FullScreen) { [DemoKit.Win32Input]::KeyPress($VK.F11); Start-Sleep -Milliseconds 1200 }
        $script:DocCache = @{}
        $rect = New-Object DemoKit.Win32Input+RECT; [void][DemoKit.Win32Input]::GetWindowRect($hwnd, [ref]$rect)
        $fsNow = ($rect.Left -le $b.X -and $rect.Top -le $b.Y -and $rect.Right -ge $b.Right -and $rect.Bottom -ge $b.Bottom)
        $fsOk = $fsNow -eq $FullScreen
        if ($zoomOk -and $fsOk) { break }
        if ($fsNow) { [DemoKit.Win32Input]::KeyPress($VK.F11); Start-Sleep -Milliseconds 1000 }   # leave full screen before retrying
        Write-Warning "View setup attempt $attempt did not stick (zoom ok: $zoomOk, full screen ok: $fsOk); retrying."
    }
    if (-not ($zoomOk -and $fsOk)) { throw "Could not set the browser view (zoom $target%, full screen $FullScreen). Check the window is on monitor $Monitor and not blocked by a dialog." }
    Write-DemoAction 'view' @{ monitor = $Monitor; fullscreen = $FullScreen; zoom = $target }
    $target
}
# Reads Edge/Chrome's own zoom indicator ("Zoom: 125%"), shown in the toolbar whenever zoom is not 100%.
function Get-DemoBrowserZoom($Window) {
    $AE = [System.Windows.Automation.AutomationElement]
    foreach ($e in $Window.FindAll([System.Windows.Automation.TreeScope]::Descendants, (New-Object System.Windows.Automation.PropertyCondition $AE::ControlTypeProperty, ([System.Windows.Automation.ControlType]::Button)))) {
        try { if ($e.Current.Name -match '^Zoom:?\s*(\d+)\s*%') { return [int]$matches[1] } } catch { }
    }
    100
}# Deletes the throwaway profile of a private take once its browser has closed.
function Remove-DemoThrowawayProfile {
    if (-not $script:ThrowawayProfile) { return }
    $deadline = [DateTime]::UtcNow.AddSeconds(15)
    do { Start-Sleep -Milliseconds 500; try { Remove-Item -Recurse -Force $script:ThrowawayProfile -ErrorAction Stop; break } catch { } } while ([DateTime]::UtcNow -lt $deadline)
    $script:ThrowawayProfile = $null
}
function Exit-DemoFullScreen { [DemoKit.Win32Input]::KeyPress($VK.F11); Start-Sleep -Milliseconds 600 }

# --- Finding elements ---
$script:DocCache = @{}
function Test-DemoDocumentAlive($Doc) {
    try { $r = $Doc.Current.BoundingRectangle; return (-not $r.IsEmpty -and -not $Doc.Current.IsOffscreen) } catch { return $false }
}
function Get-DemoDocument($Window, [int]$TimeoutMs = 6000) {
    # Walking the whole browser window is slow (~1 s under load), so reuse the page document until it goes stale.
    $key = [string]$Window.Current.NativeWindowHandle
    $cached = $script:DocCache[$key]
    if ($cached -and (Test-DemoDocumentAlive $cached)) { return $cached }
    $doc = Find-DemoDocumentUncached $Window $TimeoutMs
    if ($doc) { $script:DocCache[$key] = $doc }
    $doc
}
function Enable-DemoPageAccessibility($Window) {
    foreach ($h in [DemoKit.Win32Input]::ChildWindows([IntPtr]$Window.Current.NativeWindowHandle, 'Chrome_RenderWidgetHostHWND')) {
        try { $e = [System.Windows.Automation.AutomationElement]::FromHandle($h); [void]$e.Current.Name; [void]$e.FindFirst([System.Windows.Automation.TreeScope]::Children, [System.Windows.Automation.Condition]::TrueCondition) } catch { }
    }
}
function Find-DemoDocumentUncached($Window, [int]$TimeoutMs) {
    # The page is the largest visible Document; browser dialogs and side panes are smaller documents.
    $cond = New-Object System.Windows.Automation.PropertyCondition ([System.Windows.Automation.AutomationElement]::ControlTypeProperty), ([System.Windows.Automation.ControlType]::Document)
    # Edge and Chrome build the page's accessibility tree only once an assistive client asks the page window for it,
    # so ask it directly (the same request Narrator makes), then retry briefly.
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    $woke = $false
    do {
        if (-not $woke) { Enable-DemoPageAccessibility $Window; $woke = $true }
        $best = $null; $area = 0
        foreach ($d in $Window.FindAll([System.Windows.Automation.TreeScope]::Descendants, $cond)) {
            try { $r = $d.Current.BoundingRectangle; if (-not $d.Current.IsOffscreen -and -not $r.IsEmpty -and $r.Width * $r.Height -gt $area) { $best = $d; $area = $r.Width * $r.Height } } catch { }
        }
        if ($best) { return $best }
        Start-Sleep -Milliseconds 250
    } while ([DateTime]::UtcNow -lt $deadline)
    Write-Warning 'No page document found; searching the whole browser window.'
    $null
}
# target: @{ name = 'text or *wildcard*'; type = 'Button'|'Hyperlink'|'Edit'|...; id = 'automationId'; index = 0 }
function Find-DemoElement($Window, $Target, [int]$TimeoutMs = 5000) {
    $root = Get-DemoDocument $Window; if (-not $root) { $root = $Window }
    $deadline = [DateTime]::UtcNow.AddMilliseconds($TimeoutMs)
    $AE = [System.Windows.Automation.AutomationElement]
    do {
        $conds = New-Object System.Collections.Generic.List[System.Windows.Automation.Condition]
        if ($Target.type) { $ct = [System.Windows.Automation.ControlType]::($Target.type); $conds.Add((New-Object System.Windows.Automation.PropertyCondition $AE::ControlTypeProperty, $ct)) }
        if ($Target.id) { $conds.Add((New-Object System.Windows.Automation.PropertyCondition $AE::AutomationIdProperty, $Target.id)) }
        if ($Target.name -and -not $Target.name.Contains('*')) { $conds.Add((New-Object System.Windows.Automation.PropertyCondition $AE::NameProperty, $Target.name)) }  # filtered by the browser: fast
        $cond = if ($conds.Count -eq 0) { [System.Windows.Automation.Condition]::TrueCondition } elseif ($conds.Count -eq 1) { $conds[0] } else { New-Object System.Windows.Automation.AndCondition (, $conds.ToArray()) }
        $all = $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, $cond)
        $hits = foreach ($e in $all) {
            try {
                $c = $e.Current
                if ($c.IsOffscreen -or $c.BoundingRectangle.IsEmpty -or $c.BoundingRectangle.Width -lt 2) { continue }
                if ($Target.name) { if ($Target.name.Contains('*')) { if ($c.Name -notlike $Target.name) { continue } } elseif ($c.Name -ne $Target.name) { continue } }
                $e
            } catch { }
        }
        $hits = @($hits)
        $idx = if ($Target.index) { [int]$Target.index } else { 0 }
        if ($hits.Count -gt $idx) { return $hits[$idx] }
        Start-Sleep -Milliseconds 250
        $script:DocCache.Remove([string]$Window.Current.NativeWindowHandle)   # the page may have changed: look it up again
        $root = Get-DemoDocument $Window 1500; if (-not $root) { $root = $Window }
    } while ([DateTime]::UtcNow -lt $deadline)
    $null
}
function Get-DemoElementCenter($Element) {
    $r = $Element.Current.BoundingRectangle
    @{ X = [int]($r.X + $r.Width / 2); Y = [int]($r.Y + $r.Height / 2); Rect = @{ x = [int]$r.X; y = [int]$r.Y; w = [int]$r.Width; h = [int]$r.Height } }
}
# Lists visible, nameable page elements: the raw material for feature discovery and target resolution.
function Get-DemoElementMap($Window, [int]$Max = 400) {
    $root = Get-DemoDocument $Window; if (-not $root) { $root = $Window }
    $interesting = 'Button', 'Hyperlink', 'Edit', 'ComboBox', 'CheckBox', 'RadioButton', 'MenuItem', 'TabItem', 'ListItem', 'TreeItem', 'Header', 'HeaderItem', 'DataItem', 'Text', 'Group', 'Table', 'Image'
    $out = New-Object System.Collections.Generic.List[object]
    foreach ($e in $root.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition)) {
        try {
            $c = $e.Current
            $type = $c.ControlType.ProgrammaticName -replace '^ControlType\.', ''
            if ($type -notin $interesting -or $c.IsOffscreen -or $c.BoundingRectangle.IsEmpty) { continue }
            if ([string]::IsNullOrWhiteSpace($c.Name) -and -not $c.AutomationId) { continue }
            $r = $c.BoundingRectangle
            $out.Add([pscustomobject]@{ type = $type; name = $c.Name; id = $c.AutomationId; x = [int]$r.X; y = [int]$r.Y; w = [int]$r.Width; h = [int]$r.Height })
            if ($out.Count -ge $Max) { break }
        } catch { }
    }
    $out.ToArray()
}

# Tight on-screen rectangles of phrases in the page, for underlining or highlighting a piece of text instead of a
# whole element. Finds the smallest element whose name contains the phrase, measures its text with UI Automation's
# TextPattern (RangeFromChild gives text-tight bounds), and, for a phrase inside a longer label, takes the matching
# share of that line. (Chromium's TextPattern.FindText returns wrong ranges, so it is not used.)
function Get-DemoTextRects($Window, [string[]]$Texts) {
    $doc = Get-DemoDocument $Window 2000
    if (-not $doc -or -not $Texts) { return @() }
    try { $tp = $doc.GetCurrentPattern([System.Windows.Automation.TextPattern]::Pattern) } catch { $tp = $null }
    $all = @($doc.FindAll([System.Windows.Automation.TreeScope]::Descendants, [System.Windows.Automation.Condition]::TrueCondition))
    foreach ($t in $Texts) {
        $best = $null; $bestArea = [double]::MaxValue
        foreach ($e in $all) {
            try {
                $cur = $e.Current
                if ($cur.IsOffscreen -or $cur.BoundingRectangle.IsEmpty -or $cur.Name.IndexOf($t, [StringComparison]::OrdinalIgnoreCase) -lt 0) { continue }
                $a = $cur.BoundingRectangle.Width * $cur.BoundingRectangle.Height
                if ($a -lt $bestArea) { $best = $e; $bestArea = $a }
            } catch { }
        }
        if (-not $best) { continue }
        $name = $best.Current.Name; $box = $best.Current.BoundingRectangle
        if ($tp) {
            try {
                $rects = @($tp.RangeFromChild($best).GetBoundingRectangles() | Where-Object { -not $_.IsEmpty -and $_.Width -gt 1 })
                if ($rects) {
                    $maxH = ($rects | Measure-Object Height -Maximum).Maximum
                    $box = $rects | Where-Object { $_.Height -ge 0.6 * $maxH } | Sort-Object { $_.Width * $_.Height } -Descending | Select-Object -First 1
                }
            } catch { }
        }
        $k = $name.IndexOf($t, [StringComparison]::OrdinalIgnoreCase)
        $x = $box.X; $w = $box.Width
        if ($name.Length -gt $t.Length -and $k -ge 0) { $x = $box.X + $box.Width * $k / $name.Length; $w = $box.Width * $t.Length / $name.Length }   # share of the line
        [pscustomobject]@{ text = $t; x = [int]$x; y = [int]$box.Y; w = [int][math]::Max(2, $w); h = [int]$box.Height }
    }
}
# --- Actions (each one logged with a UTC timestamp for the recorder) ---
# -At (UTC ticks): when the click should land. The target is found first, then the glide starts so the click hits on time.
function Invoke-DemoAction($Window, $Action, [int]$GlideMs = 700, [long]$At = 0) {
    $do = $Action.do
    switch ($do) {
        { $_ -in 'click', 'double_click', 'right_click', 'hover', 'type' } {
            $el = Find-DemoElement $Window $Action.target
            if (-not $el) { throw "Target not found for '$do': $($Action.target | ConvertTo-Json -Compress)" }
            $pt = Get-DemoElementCenter $el
            if ($At -gt 0) { $wait = [int](($At - [DateTime]::UtcNow.Ticks) / 1e4) - $GlideMs; if ($wait -gt 0) { Start-Sleep -Milliseconds $wait; $pt = Get-DemoElementCenter $el } }
            [DemoKit.Win32Input]::Glide($pt.X, $pt.Y, $GlideMs)
            Write-DemoAction 'move' @{ rect = $pt.Rect }
            if ($do -eq 'hover') { break }
            if ($do -eq 'double_click') { [DemoKit.Win32Input]::DoubleClick() } else { [DemoKit.Win32Input]::Click(($do -eq 'right_click')) }
            $script:LastClick = [DateTime]::UtcNow.Ticks
            Write-DemoAction 'click' @{ rect = $pt.Rect }
            if ($do -eq 'type') {
                Start-Sleep -Milliseconds 150
                if ($Action.clear) { [DemoKit.Win32Input]::Chord(@($VK.Ctrl, $VK.A)); [DemoKit.Win32Input]::KeyPress($VK.Delete) }
                [DemoKit.Win32Input]::TypeText([string]$Action.text, $(if ($Action.cps) { [int](1000 / $Action.cps) } else { 55 }))
                Write-DemoAction 'type' @{ chars = ([string]$Action.text).Length }
            }
        }
        'key' {
            $keys = @(([string]$Action.keys).Split('+') | ForEach-Object { $k = $_.Trim(); if ($VK.ContainsKey($k)) { $VK[$k] } elseif ($k.Length -eq 1) { [int][char]$k.ToUpper() } else { throw "Unknown key '$k'" } })
            if ($keys.Count -eq 1) { [DemoKit.Win32Input]::KeyPress($keys[0]) } else { [DemoKit.Win32Input]::Chord([uint16[]]$keys) }
            Write-DemoAction 'key' @{ keys = $Action.keys }
        }
        'scroll' {
            if ($Action.target) { $el = Find-DemoElement $Window $Action.target; if ($el) { $pt = Get-DemoElementCenter $el; [DemoKit.Win32Input]::Glide($pt.X, $pt.Y, $GlideMs) } }
            [DemoKit.Win32Input]::Wheel(-1 * [int]$Action.notches)
            Write-DemoAction 'scroll' @{ notches = $Action.notches }
        }
        'navigate' {
            [DemoKit.Win32Input]::Chord(@($VK.Ctrl, $VK.L)); Start-Sleep -Milliseconds 150
            [DemoKit.Win32Input]::TypeText([string]$Action.url, 8); [DemoKit.Win32Input]::KeyPress($VK.Enter)
            $script:DocCache = @{}
            Write-DemoAction 'navigate' @{ url = $Action.url }
        }
        'wait' {
            if ($Action.for) { if (-not (Find-DemoElement $Window $Action.for ([int]($Action.timeout_ms | ForEach-Object { if ($_) { $_ } else { 8000 } })))) { throw "Wait condition not met: $($Action.for | ConvertTo-Json -Compress)" } }
            else { Start-Sleep -Milliseconds ([int]$Action.ms) }
        }
        default { throw "Unknown action '$do'" }
    }
    Start-Sleep -Milliseconds $script:Settle
}

Export-ModuleMember -Function * -Variable VK
