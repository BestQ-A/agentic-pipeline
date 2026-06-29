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
$htmlPath = Join-Path $dashboardPath 'agentic-pipeline-dashboard.html'
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

$embeddedJson = ($dashboard | ConvertTo-Json -Depth 12).Replace('</', '<\/')
$htmlTemplate = @'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Agentic Pipeline Dashboard</title>
  <style>
    :root {
      color-scheme: light dark;
      --bg: #f6f7f9;
      --panel: #ffffff;
      --text: #17191f;
      --muted: #657085;
      --line: #d8dde7;
      --accent: #0f766e;
      --blocked: #b42318;
      --ready: #0f766e;
      --pending: #6d5bd0;
      --shadow: 0 1px 2px rgba(18, 25, 38, 0.08);
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #101318;
        --panel: #171b22;
        --text: #eef2f7;
        --muted: #a7b0c0;
        --line: #2b3340;
        --shadow: none;
      }
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--bg);
      color: var(--text);
      font: 14px/1.45 system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    header {
      position: sticky;
      top: 0;
      z-index: 2;
      background: color-mix(in srgb, var(--panel) 94%, transparent);
      border-bottom: 1px solid var(--line);
      backdrop-filter: blur(10px);
    }
    .wrap { width: min(1120px, 100%); margin: 0 auto; padding: 16px; }
    .topline { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
    h1 { margin: 0; font-size: 20px; letter-spacing: 0; }
    h2 { margin: 0 0 10px; font-size: 15px; letter-spacing: 0; }
    .muted { color: var(--muted); }
    .grid { display: grid; grid-template-columns: repeat(12, 1fr); gap: 12px; }
    .panel {
      background: var(--panel);
      border: 1px solid var(--line);
      border-radius: 8px;
      box-shadow: var(--shadow);
      padding: 14px;
    }
    .span-12 { grid-column: span 12; }
    .span-8 { grid-column: span 8; }
    .span-4 { grid-column: span 4; }
    .status-row { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
    .pill {
      border: 1px solid var(--line);
      border-radius: 999px;
      padding: 4px 9px;
      font-size: 12px;
      color: var(--muted);
      white-space: nowrap;
    }
    .status-ready, .status-complete { color: var(--ready); border-color: color-mix(in srgb, var(--ready) 40%, var(--line)); }
    .status-blocked, .status-needs-human { color: var(--blocked); border-color: color-mix(in srgb, var(--blocked) 40%, var(--line)); }
    .status-pending { color: var(--pending); border-color: color-mix(in srgb, var(--pending) 40%, var(--line)); }
    .agent-list { display: grid; gap: 10px; }
    .agent {
      border: 1px solid var(--line);
      border-radius: 8px;
      padding: 12px;
    }
    .agent-head { display: flex; align-items: start; justify-content: space-between; gap: 10px; }
    .agent-name { font-weight: 650; overflow-wrap: anywhere; }
    .summary { margin-top: 8px; overflow-wrap: anywhere; }
    .kv { display: grid; grid-template-columns: 120px 1fr; gap: 8px; padding: 6px 0; border-top: 1px solid var(--line); }
    .kv:first-child { border-top: 0; }
    ul { margin: 8px 0 0; padding-left: 18px; }
    li { margin: 4px 0; overflow-wrap: anywhere; }
    code { font: 12px/1.4 ui-monospace, SFMono-Regular, Consolas, monospace; color: var(--muted); }
    @media (max-width: 760px) {
      .wrap { padding: 12px; }
      .grid { display: block; }
      .panel { margin-bottom: 12px; }
      .topline { align-items: start; flex-direction: column; }
      .kv { grid-template-columns: 1fr; gap: 2px; }
    }
  </style>
</head>
<body>
  <header>
    <div class="wrap topline">
      <div>
        <h1>Agentic Pipeline Dashboard</h1>
        <div class="muted" id="project"></div>
      </div>
      <div class="pill" id="refresh">loading</div>
    </div>
  </header>
  <main class="wrap">
    <section class="grid">
      <div class="panel span-8">
        <h2>Leader State</h2>
        <div class="kv"><div class="muted">Objective</div><div id="objective"></div></div>
        <div class="kv"><div class="muted">Current state</div><div id="current-state"></div></div>
        <div class="kv"><div class="muted">Stop condition</div><div id="stop-condition"></div></div>
      </div>
      <div class="panel span-4">
        <h2>Coverage</h2>
        <div class="status-row" id="coverage"></div>
      </div>
      <div class="panel span-12">
        <h2>Agent Updates</h2>
        <div class="agent-list" id="agents"></div>
      </div>
      <div class="panel span-8">
        <h2>Question Routes</h2>
        <ul id="questions"></ul>
      </div>
      <div class="panel span-4">
        <h2>Decisions</h2>
        <ul id="decisions"></ul>
      </div>
    </section>
  </main>
  <script>
    const embedded = __DASHBOARD_JSON__;
    const jsonUrl = 'agentic-pipeline-dashboard.json';
    const refreshMs = 5000;

    function asArray(value) {
      if (!value) return [];
      return Array.isArray(value) ? value : [value];
    }

    function text(value, fallback = '') {
      return value === null || value === undefined || value === '' ? fallback : String(value);
    }

    function setText(id, value, fallback = '') {
      document.getElementById(id).textContent = text(value, fallback);
    }

    function pill(label, status) {
      const el = document.createElement('span');
      el.className = `pill status-${text(status, '').replace(/\s+/g, '-').toLowerCase()}`;
      el.textContent = label;
      return el;
    }

    function listItems(target, rows, formatter) {
      target.replaceChildren();
      if (!rows.length) {
        const li = document.createElement('li');
        li.className = 'muted';
        li.textContent = 'None';
        target.appendChild(li);
        return;
      }
      rows.forEach(row => {
        const li = document.createElement('li');
        li.textContent = formatter(row);
        target.appendChild(li);
      });
    }

    function render(data, source) {
      setText('project', data.project_root, 'No project root recorded');
      setText('objective', data.leader_state && data.leader_state.objective, 'No objective recorded');
      setText('current-state', data.leader_state && data.leader_state.current_state, 'No state recorded');
      setText('stop-condition', data.leader_state && data.leader_state.stop_condition, 'No stop condition recorded');
      setText('refresh', `${source} - ${text(data.updated_at, 'unknown update time')}`);

      const coverage = document.getElementById('coverage');
      coverage.replaceChildren();
      asArray(data.coverage && data.coverage.active_logical_agents).forEach(agent => coverage.appendChild(pill(agent, 'ready')));
      if (!coverage.childElementCount) coverage.appendChild(pill('no agents recorded', 'pending'));

      const agents = document.getElementById('agents');
      agents.replaceChildren();
      asArray(data.agent_updates).sort((a, b) => text(a.logical_agent).localeCompare(text(b.logical_agent))).forEach(agent => {
        const card = document.createElement('article');
        card.className = 'agent';
        const head = document.createElement('div');
        head.className = 'agent-head';
        const name = document.createElement('div');
        name.className = 'agent-name';
        name.textContent = `${text(agent.logical_agent, 'unknown-agent')} - ${text(agent.role, 'role')}`;
        head.appendChild(name);
        head.appendChild(pill(text(agent.status, 'unknown'), agent.status));
        card.appendChild(head);
        const summary = document.createElement('div');
        summary.className = 'summary';
        summary.textContent = text(agent.summary, 'No summary recorded');
        card.appendChild(summary);
        const slices = asArray(agent.owns_goal_slices).join(', ');
        if (slices) {
          const owns = document.createElement('div');
          owns.className = 'muted summary';
          owns.textContent = `Owns: ${slices}`;
          card.appendChild(owns);
        }
        if (agent.next_action) {
          const next = document.createElement('div');
          next.className = 'muted summary';
          next.textContent = `Next: ${agent.next_action}`;
          card.appendChild(next);
        }
        agents.appendChild(card);
      });
      if (!agents.childElementCount) {
        const empty = document.createElement('div');
        empty.className = 'muted';
        empty.textContent = 'No agent updates recorded';
        agents.appendChild(empty);
      }

      listItems(document.getElementById('questions'), asArray(data.question_routes), row => `${text(row.status, 'unknown')}: ${text(row.question)} -> ${text(row.owner)}`);
      listItems(document.getElementById('decisions'), asArray(data.decisions), row => `${text(row.owner, 'unknown')}: ${text(row.decision)}`);
    }

    async function refresh() {
      if (location.protocol === 'file:') {
        render(embedded, 'embedded snapshot');
        return;
      }
      try {
        const response = await fetch(`${jsonUrl}?t=${Date.now()}`, { cache: 'no-store' });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        render(await response.json(), 'live json');
      } catch (error) {
        render(embedded, `embedded fallback (${error.message})`);
      }
    }

    refresh();
    setInterval(refresh, refreshMs);
  </script>
</body>
</html>
'@
$html = $htmlTemplate.Replace('__DASHBOARD_JSON__', $embeddedJson)
Set-Content -LiteralPath $htmlPath -Value $html -Encoding UTF8

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# Agentic Pipeline Dashboard') | Out-Null
$lines.Add('') | Out-Null
$lines.Add("- Web: $htmlPath") | Out-Null
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
    dashboard_html = $htmlPath
    dashboard_markdown = $mdPath
    logical_agent = $LogicalAgent
    updated_at = $now
} | ConvertTo-Json -Depth 4
