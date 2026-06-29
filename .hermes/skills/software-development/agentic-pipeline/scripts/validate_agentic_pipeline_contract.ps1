param(
    [Parameter(Mandatory = $false)]
    [string]$SkillRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Contains {
    param(
        [string]$Content,
        [string]$Pattern,
        [string]$Name
    )
    if ($Content -notmatch $Pattern) {
        throw "Missing contract marker: $Name"
    }
}

$skillPath = Join-Path $SkillRoot 'SKILL.md'
if (-not (Test-Path -LiteralPath $skillPath)) {
    throw "SKILL.md not found: $skillPath"
}

$content = Get-Content -LiteralPath $skillPath -Raw

$requiredMarkers = [ordered]@{
    hermesBinding = '## Hermes Runtime Binding'
    loopEngineeringGate = '## Loop Engineering Completeness Gate'
    loopEngineeringShape = 'loop_engineering_gate:'
    discoverySource = 'discovery_source:'
    handoffIsolation = 'handoff_isolation:'
    verificationCheck = 'verification_check:'
    persistenceState = 'persistence_state:'
    schedulingTrigger = 'scheduling_trigger:'
    budgetCaps = 'budget_caps:'
    humanCheckpoint = 'human_checkpoint:'
    noddingLoop = 'nodding loop'
    amnesiacLoop = 'amnesiac loop'
    manualLoop = 'manual loop'
    blindLoop = 'blind loop'
    tangledLoop = 'tangled loop'
    guidanceBindingShape = 'guidance_binding:'
    environmentPreflightShape = 'environment_preflight:'
    delegateTask = 'delegate_task'
    hermesWorktree = 'hermes -w'
    cronjob = 'cronjob'
    kanban = 'kanban'
    dashboardUpdate = 'update_agent_dashboard.ps1'
    subagentGuidance = 'guidance_followed:'
    subagentPreflight = 'preflight_used:'
    growthRule = 'Grow loops in this order'
}

foreach ($entry in $requiredMarkers.GetEnumerator()) {
    Assert-Contains -Content $content -Pattern ([regex]::Escape($entry.Value)) -Name $entry.Key
}

[pscustomobject]@{
    status = 'pass'
    skill = $skillPath
    checkedMarkers = @($requiredMarkers.Keys)
    checkedAt = [DateTime]::UtcNow.ToString('o')
} | ConvertTo-Json -Depth 4
