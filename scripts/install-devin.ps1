<#
.SYNOPSIS
  Install the Agentic Pipeline skill and subagent profiles into Devin CLI.

.DESCRIPTION
  Copies the .devin/skills/agentic-pipeline skill and the .devin/agents/*
  subagent profiles into the user-level Devin directories so they are available
  in every project on this machine.

  Target paths:
    Skills  -> %APPDATA%\devin\skills\<name>\           (Windows global)
               ~/.config/devin/skills/<name>/           (Linux/macOS global)
    Agents  -> %APPDATA%\devin\agents\<name>\           (Windows global)
               ~/.config/devin/agents/<name>/           (Linux/macOS global)

  Use -Scope Project to install into the current project's .devin/ directory
  instead (committed to git, team-shared).

.PARAMETER Scope
  User (default) or Project.

.PARAMETER Force
  Overwrite existing destination files.

.EXAMPLE
  .\install-devin.ps1
  .\install-devin.ps1 -Scope Project
  .\install-devin.ps1 -Scope User -Force
#>
param(
    [ValidateSet('User', 'Project')]
    [string]$Scope = 'User',

    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$srcSkill = Join-Path $repoRoot '.devin\skills\agentic-pipeline'
$srcAgents = Join-Path $repoRoot '.devin\agents'

if (-not (Test-Path -LiteralPath $srcSkill)) {
    throw "Source skill not found: $srcSkill"
}
if (-not (Test-Path -LiteralPath $srcAgents)) {
    throw "Source agents dir not found: $srcAgents"
}

if ($Scope -eq 'User') {
    $appData = [Environment]::GetFolderPath('ApplicationData')
    $destSkillsRoot = Join-Path $appData 'devin\skills'
    $destAgentsRoot = Join-Path $appData 'devin\agents'
} else {
    $destSkillsRoot = Join-Path (Get-Location).Path '.devin\skills'
    $destAgentsRoot = Join-Path (Get-location).Path '.devin\agents'
}

Write-Host "Installing Agentic Pipeline for Devin ($Scope scope)"
Write-Host "  Skills  -> $destSkillsRoot"
Write-Host "  Agents  -> $destAgentsRoot"

# Skill
$destSkill = Join-Path $destSkillsRoot 'agentic-pipeline'
if ((Test-Path -LiteralPath $destSkill) -and -not $Force) {
    Write-Warning "Skill already exists at $destSkill. Use -Force to overwrite."
} else {
    New-Item -ItemType Directory -Force -Path $destSkill | Out-Null
    Copy-Item -Path (Join-Path $srcSkill '*') -Destination $destSkill -Recurse -Force
    Write-Host "  Installed skill: agentic-pipeline"
}

# Agents
$agentCount = 0
foreach ($srcAgent in (Get-ChildItem -LiteralPath $srcAgents -Directory)) {
    $destAgent = Join-Path $destAgentsRoot $srcAgent.Name
    if ((Test-Path -LiteralPath $destAgent) -and -not $Force) {
        Write-Warning "Agent already exists: $($srcAgent.Name). Use -Force to overwrite."
        continue
    }
    New-Item -ItemType Directory -Force -Path $destAgent | Out-Null
    Copy-Item -Path (Join-Path $srcAgent.FullName '*') -Destination $destAgent -Recurse -Force
    $agentCount++
}
Write-Host "  Installed $agentCount agent profile(s)."

Write-Host ""
Write-Host "Done. Start a new Devin session, then invoke:"
Write-Host "  /agentic-pipeline [project-root]"
Write-Host "List discovered skills with:  devin skill list   (or the in-session /help)"
