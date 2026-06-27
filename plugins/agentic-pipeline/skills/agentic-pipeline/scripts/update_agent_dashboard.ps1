param(
    [Parameter(Mandatory = $false)]
    [string]$ProjectRoot = (Get-Location).Path,

    [Parameter(Mandatory = $false)]
    [string]$DashboardDir = '.pipeline\dashboard',

    [Parameter(Mandatory = $true)]
    [string]$LogicalAgent,

    [Parameter(Mandatory = $true)]
    [string]$Role,

    [Parameter(Mandatory = $true)]
    [ValidateSet('pending', 'ready', 'blocked', 'needs-human', 'complete')]
    [string]$Status,

    [Parameter(Mandatory = $false)]
    [string[]]$OwnsGoalSlices = @(),

    [Parameter(Mandatory = $false)]
    [string]$Objective = '',

    [Parameter(Mandatory = $false)]
    [string]$CurrentState = '',

    [Parameter(Mandatory = $false)]
    [string]$Summary = '',

    [Parameter(Mandatory = $false)]
    [string[]]$Evidence = @(),

    [Parameter(Mandatory = $false)]
    [string[]]$OpenQuestions = @(),

    [Parameter(Mandatory = $false)]
    [string]$NextAction = '',

    [Parameter(Mandatory = $false)]
    [string]$Question = '',

    [Parameter(Mandatory = $false)]
    [ValidateSet('', 'routed', 'answered', 'blocked')]
    [string]$QuestionStatus = '',

    [Parameter(Mandatory = $false)]
    [string]$Decision = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ExistingRoot {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "ProjectRoot does not exist: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

function Resolve-ContainedPath {
    param(
        [string]$Root,
        [string]$Path
    )
    if ([System.IO.Path]::IsPathRooted($Path)) {
        $candidate = [System.IO.Path]::GetFullPath($Path)
    }
    else {
        $candidate = [System.IO.Path]::GetFullPath((Join-Path $Root $Path))
    }
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\') + '\'
    if (-not $candidate.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "DashboardDir must be inside ProjectRoot. ProjectRoot=$Root DashboardDir=$candidate"
    }
    return $candidate
}

function ConvertTo-Array {
    param($Value)
    if ($null -eq $Value) { return @() }
    return @($Value)
}

$root = Resolve-ExistingRoot -Path $ProjectRoot
$dashboardPath = Resolve-ContainedPath -Root $root -Path $DashboardDir
New-Item -ItemType Directory -Force -Path $dashboardPath | Out-Null

$jsonPath = Join-Path $dashboardPath 'agentic-pipeline-dashboard.json'
$mdPath = Join-Path $dashboardPath 'agentic-pipeline-dashboard.md'
$now = [DateTime]::UtcNow.ToString('o')

if (Test-Path -LiteralPath $jsonPath) {
    $dashboard = Get-Content -LiteralPath $jsonPath -Raw | ConvertFrom-Json
}
else {
    $dashboard = [pscustomobject]@{
        project_root = $root
        updated_at = $now
        leader_state = [pscustomobject]@{
            objective = ''
            current_state = ''
            stop_condition = ''
        }
        coverage = [pscustomobject]@{
            required_roles = @()
            active_logical_agents = @()
            missing_roles = @()
        }
        goal_ownership_map = @()
        guidance_binding = $null
        environment_preflight = $null
        agent_updates = @()
        question_routes = @()
        decisions = @()
    }
}

if ($Objective) { $dashboard.leader_state.objective = $Objective }
if ($CurrentState) { $dashboard.leader_state.current_state = $CurrentState }

$existingUpdates = @($dashboard.agent_updates | Where-Object { $_.logical_agent -ne $LogicalAgent })
$agentUpdate = [pscustomobject]@{
    logical_agent = $LogicalAgent
    role = $Role
    status = $Status
    owns_goal_slices = ConvertTo-Array $OwnsGoalSlices
    summary = $Summary
    evidence = ConvertTo-Array $Evidence
    open_questions = ConvertTo-Array $OpenQuestions
    next_action = $NextAction
    updated_at = $now
}
$dashboard.agent_updates = @($existingUpdates + $agentUpdate)

$existingOwners = @($dashboard.goal_ownership_map | Where-Object { $_.logical_agent -ne $LogicalAgent })
$owner = [pscustomobject]@{
    logical_agent = $LogicalAgent
    role = $Role
    owns_goal_slices = ConvertTo-Array $OwnsGoalSlices
    answers_questions_about = ConvertTo-Array $OwnsGoalSlices
    current_status = $Status
    updated_at = $now
}
$dashboard.goal_ownership_map = @($existingOwners + $owner)
$dashboard.coverage.active_logical_agents = @($dashboard.agent_updates | ForEach-Object { $_.logical_agent } | Sort-Object -Unique)

if ($Question) {
    $dashboard.question_routes = @($dashboard.question_routes + [pscustomobject]@{
        question = $Question
        owner = $LogicalAgent
        status = $QuestionStatus
        evidence = ConvertTo-Array $Evidence
        updated_at = $now
    })
}

if ($Decision) {
    $dashboard.decisions = @($dashboard.decisions + [pscustomobject]@{
        decision = $Decision
        owner = $LogicalAgent
        evidence = ConvertTo-Array $Evidence
        updated_at = $now
    })
}

$dashboard.updated_at = $now
$dashboard | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# Agentic Pipeline Dashboard') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("- Project: $root") | Out-Null
$lines.Add("- Updated: $now") | Out-Null
$lines.Add("- Objective: $($dashboard.leader_state.objective)") | Out-Null
$lines.Add("- Current state: $($dashboard.leader_state.current_state)") | Out-Null
$lines.Add('') | Out-Null
$lines.Add('## Agent Updates') | Out-Null
foreach ($entry in @($dashboard.agent_updates | Sort-Object logical_agent)) {
    $slices = (@($entry.owns_goal_slices) -join ', ')
    $lines.Add("- $($entry.logical_agent) [$($entry.role)] $($entry.status): $($entry.summary)") | Out-Null
    if ($slices) { $lines.Add("  - Owns: $slices") | Out-Null }
    if ($entry.next_action) { $lines.Add("  - Next: $($entry.next_action)") | Out-Null }
}
$lines.Add('') | Out-Null
$lines.Add('## Question Routes') | Out-Null
foreach ($route in @($dashboard.question_routes)) {
    $lines.Add("- $($route.status): $($route.question) -> $($route.owner)") | Out-Null
}
$lines.Add('') | Out-Null
$lines.Add('## Decisions') | Out-Null
foreach ($decisionEntry in @($dashboard.decisions)) {
    $lines.Add("- $($decisionEntry.owner): $($decisionEntry.decision)") | Out-Null
}

Set-Content -LiteralPath $mdPath -Value $lines -Encoding UTF8

[pscustomobject]@{
    status = 'pass'
    dashboard_json = $jsonPath
    dashboard_markdown = $mdPath
    logical_agent = $LogicalAgent
    updated_at = $now
} | ConvertTo-Json -Depth 4
