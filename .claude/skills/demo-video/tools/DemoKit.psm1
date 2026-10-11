# DemoKit: shared helpers for the demo-video skills.
# Windows PowerShell 5.1 + .NET Framework + WinRT only. No external libraries.

Add-Type -AssemblyName System.Runtime.WindowsRuntime, System.Drawing, System.Windows.Forms

# Per-monitor DPI awareness so screen coordinates and captures use real pixels.
if (-not ('DemoKit.Dpi' -as [type])) {
    Add-Type -Namespace DemoKit -Name Dpi -MemberDefinition @'
[DllImport("user32.dll")] public static extern bool SetProcessDpiAwarenessContext(System.IntPtr value);
[DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
'@
}
function Enable-DemoDpiAwareness {
    # -4 = DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2; fall back to system-aware.
    if (-not [DemoKit.Dpi]::SetProcessDpiAwarenessContext([IntPtr]-4)) { [void][DemoKit.Dpi]::SetProcessDPIAware() }
}

# Native helpers (real cursor/keyboard input, screen recorder), compiled once per session by the built-in C# compiler.
if (-not ('DemoKit.Win32Input' -as [type])) {
    Add-Type -Path (Join-Path $PSScriptRoot 'Win32Input.cs'), (Join-Path $PSScriptRoot 'FrameCapture.cs'), (Join-Path $PSScriptRoot 'FrameCompose.cs'), (Join-Path $PSScriptRoot 'DxgiCapture.cs'), (Join-Path $PSScriptRoot 'LoopbackCapture.cs') -ReferencedAssemblies System.Drawing, System.Core, System.Windows.Forms
}

# --- WinRT async bridging (PowerShell 5.1 cannot await IAsync* directly) ---
$script:ext = [System.WindowsRuntimeSystemExtensions].GetMethods()
$script:asOp = ($script:ext | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
$script:asAct = ($script:ext | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction' })[0]
$script:asProg = ($script:ext | Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperationWithProgress`2' })[0]

function Wait-WinRT($Operation, [Type]$ResultType) {
    $task = $script:asOp.MakeGenericMethod($ResultType).Invoke($null, @($Operation))
    $task.Wait(-1) | Out-Null
    $task.Result
}
function Wait-WinRTAction($Operation) { $script:asAct.Invoke($null, @($Operation)).Wait(-1) | Out-Null }
function Wait-WinRTProgress($Operation, [Type]$ResultType, [Type]$ProgressType) {
    $task = $script:asProg.MakeGenericMethod($ResultType, $ProgressType).Invoke($null, @($Operation))
    $task.Wait(-1) | Out-Null
    $task.Result
}

# Load the WinRT types the kit uses.
[void][Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime]
[void][Windows.Storage.StorageFolder, Windows.Storage, ContentType = WindowsRuntime]
[void][Windows.Storage.Streams.DataReader, Windows.Storage.Streams, ContentType = WindowsRuntime]
[void][Windows.Media.Editing.MediaComposition, Windows.Media.Editing, ContentType = WindowsRuntime]
[void][Windows.Media.Editing.MediaOverlay, Windows.Media.Editing, ContentType = WindowsRuntime]
[void][Windows.Media.SpeechSynthesis.SpeechSynthesizer, Windows.Media.SpeechSynthesis, ContentType = WindowsRuntime]

function Get-StorageFile([string]$Path) {
    Wait-WinRT ([Windows.Storage.StorageFile]::GetFileFromPathAsync((Resolve-Path $Path).Path)) ([Windows.Storage.StorageFile])
}
function New-StorageFile([string]$Path) {
    $full = [IO.Path]::GetFullPath($Path)
    $folder = Wait-WinRT ([Windows.Storage.StorageFolder]::GetFolderFromPathAsync([IO.Path]::GetDirectoryName($full))) ([Windows.Storage.StorageFolder])
    Wait-WinRT ($folder.CreateFileAsync([IO.Path]::GetFileName($full), [Windows.Storage.CreationCollisionOption]::ReplaceExisting)) ([Windows.Storage.StorageFile])
}
# WinRT collections projected into PowerShell lack .Add(); call it through the interface.
function Add-WinRTItem($Collection, $Item, [Type]$ItemType) {
    [void][System.Collections.Generic.ICollection`1].MakeGenericType($ItemType).GetMethod('Add').Invoke($Collection, @($Item))
}

# --- Project settings (demo/project.json) and JSON helpers ---
function Read-DemoJson([string]$Path) { Get-Content -Raw -Encoding UTF8 $Path | ConvertFrom-Json }
function Write-DemoJson($Object, [string]$Path, [int]$Depth = 12) {
    $json = $Object | ConvertTo-Json -Depth $Depth
    [IO.File]::WriteAllText([IO.Path]::GetFullPath($Path), $json, (New-Object Text.UTF8Encoding $false))
}
# --- Traceability: content hashes, the append-only project log, and the manifest ---
function Get-DemoHash($Value) {
    # Short SHA-256 of a string or of an object's compact JSON; identifies inputs so work is redone only when they change.
    $text = if ($Value -is [string]) { $Value } else { $Value | ConvertTo-Json -Depth 20 -Compress }
    $sha = [Security.Cryptography.SHA256]::Create()
    (-join ($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($text)) | ForEach-Object { $_.ToString('x2') })).Substring(0, 12)
}
function Get-DemoToolkitVersion {
    # Hash of the toolkit's own source, logged with every step so a result can be tied to the code that made it.
    $files = Get-ChildItem $PSScriptRoot -File | Where-Object { $_.Extension -in '.ps1', '.psm1', '.cs' } | Sort-Object Name
    Get-DemoHash (($files | ForEach-Object { $_.Name + ':' + (Get-FileHash $_.FullName -Algorithm SHA256).Hash }) -join ';')
}
function Get-DemoRelativePath([string]$Dir, [string]$Path) {
    # Paths in logs are relative to the project so logs never carry user names or machine layout.
    $full = [IO.Path]::GetFullPath($Path); $root = [IO.Path]::GetFullPath($Dir).TrimEnd('\') + '\'
    if ($full.StartsWith($root, [StringComparison]::OrdinalIgnoreCase)) { $full.Substring($root.Length) } else { [IO.Path]::GetFileName($full) }
}
function Write-DemoLog([string]$Dir, [string]$Step, [hashtable]$Data = @{}) {
    $entry = [ordered]@{ time = [DateTime]::UtcNow.ToString('o'); step = $Step; toolkit = (Get-DemoToolkitVersion) }
    foreach ($k in $Data.Keys) { $entry[$k] = $Data[$k] }
    $line = $entry | ConvertTo-Json -Depth 12 -Compress
    [IO.File]::AppendAllText((Join-Path $Dir 'log.jsonl'), $line + "`n", (New-Object Text.UTF8Encoding $false))
}
function Read-DemoManifest([string]$Dir) {
    $p = Join-Path $Dir 'manifest.json'
    if (Test-Path $p) { Read-DemoJson $p } else { [pscustomobject]@{ scenes = [pscustomobject]@{}; finals = @() } }
}
function Save-DemoManifest([string]$Dir, $Manifest) { Write-DemoJson $Manifest (Join-Path $Dir 'manifest.json') }
function Set-DemoManifestScene($Manifest, [string]$Id, [hashtable]$Values) {
    $cur = $Manifest.scenes.$Id
    if (-not $cur) { $cur = [pscustomobject]@{}; $Manifest.scenes | Add-Member -Force $Id $cur }
    foreach ($k in $Values.Keys) { $cur | Add-Member -Force $k $Values[$k] }
}
# What a scene's recording depends on; when this changes, the scene's take is stale and must be re-recorded.
function Get-DemoSceneRecordHash($Scene, $Project) {
    $h = [ordered]@{
        narration = $Scene.narration; voice_override = $Scene.voice; pre = $Scene.pre; actions = $Scene.actions
        phrases = @($Scene.effects | Where-Object { $_.target.text } | ForEach-Object { [string]$_.target.text } | Sort-Object -Unique)   # measured during the take; other effect changes never need a new take
        app_url = $Project.app_url; monitor = $Project.monitor; fullscreen = $Project.fullscreen; zoom = $Project.zoom; browser = $Project.browser; voice = $Project.voice }
    if ($Project.app_audio) { $h.app_audio = $true }   # only when on, so projects without app sound keep their hashes
    if ($Project.crop) { $h.crop = [string]$Project.crop }   # decides whether the window area is recorded
    Get-DemoHash $h
}

function Get-DemoMonitor([int]$Index) {
    $all = [System.Windows.Forms.Screen]::AllScreens
    if ($Index -lt 0 -or $Index -ge $all.Count) { throw "Monitor index $Index not found; available: 0..$($all.Count - 1)" }
    $all[$Index]
}
function Get-DemoMonitors {
    Enable-DemoDpiAwareness
    $i = 0
    foreach ($s in [System.Windows.Forms.Screen]::AllScreens) {
        [pscustomobject]@{ Index = $i; Device = $s.DeviceName; Primary = $s.Primary
                           X = $s.Bounds.X; Y = $s.Bounds.Y; Width = $s.Bounds.Width; Height = $s.Bounds.Height }
        $i++
    }
}

Export-ModuleMember -Function *
