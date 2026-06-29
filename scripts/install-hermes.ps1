<#
.SYNOPSIS
  Install the Agentic Pipeline skill into Hermes Agent.

.DESCRIPTION
  Copies the repo-owned Hermes skill surface from
  .hermes/skills/software-development/agentic-pipeline into either the
  user-level Hermes skills directory or the current project's .hermes tree.

  User scope target:
    %LOCALAPPDATA%\hermes\skills\software-development\agentic-pipeline\

  Project scope target:
    .\.hermes\skills\software-development\agentic-pipeline\

.PARAMETER Scope
  User (default) or Project.

.PARAMETER HermesHome
  Optional Hermes home override for User scope. Defaults to $env:HERMES_HOME,
  then %LOCALAPPDATA%\hermes.

.PARAMETER Force
  Overwrite existing destination files.

.EXAMPLE
  .\scripts\install-hermes.ps1
  .\scripts\install-hermes.ps1 -Force
  .\scripts\install-hermes.ps1 -Scope Project
#>
param(
    [ValidateSet('User', 'Project')]
    [string]$Scope = 'User',

    [string]$HermesHome = '',

    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$srcSkill = Join-Path $repoRoot '.hermes\skills\software-development\agentic-pipeline'

if (-not (Test-Path -LiteralPath (Join-Path $srcSkill 'SKILL.md'))) {
    throw "Source Hermes skill not found: $srcSkill"
}

if ($Scope -eq 'User') {
    if (-not $HermesHome) {
        $HermesHome = $env:HERMES_HOME
    }
    if (-not $HermesHome) {
        $localAppData = [Environment]::GetFolderPath('LocalApplicationData')
        $HermesHome = Join-Path $localAppData 'hermes'
    }
    $destRoot = Join-Path $HermesHome 'skills\software-development'
} else {
    $destRoot = Join-Path (Get-Location).Path '.hermes\skills\software-development'
}

$destSkill = Join-Path $destRoot 'agentic-pipeline'

Write-Host "Installing Agentic Pipeline for Hermes Agent ($Scope scope)"
Write-Host "  Source -> $srcSkill"
Write-Host "  Target -> $destSkill"

if ((Test-Path -LiteralPath $destSkill) -and -not $Force) {
    Write-Warning "Skill already exists at $destSkill. Use -Force to overwrite."
} else {
    New-Item -ItemType Directory -Force -Path $destSkill | Out-Null
    Copy-Item -Path (Join-Path $srcSkill '*') -Destination $destSkill -Recurse -Force
    Write-Host "  Installed skill: agentic-pipeline"
}

$validator = Join-Path $destSkill 'scripts\validate_agentic_pipeline_contract.ps1'
if (Test-Path -LiteralPath $validator) {
    $validation = & $validator -SkillRoot $destSkill
    Write-Host $validation
}

Write-Host ""
Write-Host "Done. Start a new Hermes session or reload skills, then use one of:"
Write-Host "  hermes -s agentic-pipeline"
Write-Host "  /skill agentic-pipeline"
Write-Host "  hermes -s agentic-pipeline -z `"Standardize this project's agent pipeline.`""
