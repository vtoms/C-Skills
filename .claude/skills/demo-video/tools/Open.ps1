# Opens the project's browser at the app without driving it, and leaves it open: for signing in by hand to a
# dedicated profile (profile: dedicated) before rehearsing or recording, or for opening the window that
# profile: attach will use. No debug or automation flags.
#
#   Open.ps1 -Dir demo
param([Parameter(Mandatory)][string]$Dir)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'WinDrive.psm1') -Force
$Dir = (Resolve-Path $Dir).Path
$pj = Read-DemoJson (Join-Path $Dir 'project.json')
$browser = if ($pj.browser) { $pj.browser } else { 'msedge' }
$mode = if ($pj.profile) { $pj.profile } else { 'private' }
$profileDir = if ($mode -eq 'dedicated') { Join-Path $Dir '.browser-profile' } else { '' }
$w = Start-DemoBrowser $browser $pj.app_url $profileDir '*' -Private:($mode -eq 'private')
Write-DemoLog $Dir 'open-browser' @{ profile = $mode }
"Opened $browser ($mode profile): '$($w.Current.Name)'. The window stays open."
if ($mode -eq 'dedicated') { 'Sign in by hand in this window, then close it (the sign-in is kept in demo\.browser-profile for every take).' }
