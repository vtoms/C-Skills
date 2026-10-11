# Adds a note to the project log (log.jsonl): approvals at the checkpoints, the user's review notes, setup answers,
# decisions made while working autonomously. The tools log their own steps; this is for the human ones.
#
#   Note.ps1 -Dir demo -Kind approval -Text "Script approved by the user (v2 of storyboard)"
#   Note.ps1 -Dir demo -Kind review -Text "s03: zoom too early" -Scene s03
param(
    [Parameter(Mandatory)][string]$Dir,
    [Parameter(Mandatory)][ValidateSet('approval', 'review', 'decision', 'setup', 'note')][string]$Kind,
    [Parameter(Mandatory)][string]$Text,
    [string]$Scene
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'DemoKit.psm1') -Force
$Dir = (Resolve-Path $Dir).Path
$data = @{ kind = $Kind; text = $Text }
if ($Scene) { $data.scene = $Scene }
$sb = Join-Path $Dir 'storyboard.json'
if (Test-Path $sb) { $data.storyboard_hash = Get-DemoHash ([IO.File]::ReadAllText($sb)) }   # ties an approval to the exact script
Write-DemoLog $Dir 'note' $data
"logged $Kind note"
