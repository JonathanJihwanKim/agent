# sync-from-skill.ps1
#
# Refresh copilot/references/ and copilot/templates/ from the canonical
# Claude Code skill at skills/powerbi-pr-review/. Run from the repo root
# (d:\agent) whenever the upstream skill's references or templates change.
#
# Does NOT touch copilot/agents/*.agent.md — those are authored separately
# and adapted from the Claude Code SKILL.md + subagent files.

$ErrorActionPreference = 'Stop'

$repoRoot   = Split-Path -Parent $PSScriptRoot
$skillRefs  = Join-Path $repoRoot 'skills\powerbi-pr-review\references'
$skillTpls  = Join-Path $repoRoot 'skills\powerbi-pr-review\templates'
$copilotRefs = Join-Path $PSScriptRoot 'references'
$copilotTpls = Join-Path $PSScriptRoot 'templates'

if (-not (Test-Path $skillRefs)) { throw "Source not found: $skillRefs" }
if (-not (Test-Path $skillTpls)) { throw "Source not found: $skillTpls" }

Copy-Item -Path (Join-Path $skillRefs '*') -Destination $copilotRefs -Force
Copy-Item -Path (Join-Path $skillTpls '*') -Destination $copilotTpls -Force

Write-Output "Synced references from: $skillRefs"
Write-Output "Synced templates   from: $skillTpls"
Write-Output "Into:                    $copilotRefs"
Write-Output "                         $copilotTpls"
