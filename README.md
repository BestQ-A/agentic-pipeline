# Agentic Pipeline

Agentic Pipeline packages the `$agentic-pipeline` Codex skill, a Claude Code
plugin skill, a Hermes Agent skill, and a parallel Devin skill
`/agentic-pipeline` for reusable project pipeline standardization.
It helps an agent define project workflow states, delegate role-agent work,
capture validation evidence, and retain repeatable project artifacts.
The skill now treats loop engineering as a completeness contract: discovery,
handoff isolation, independent verification, persistent state, scheduling,
connector scope, budget caps, and human checkpoints must be explicit before a
workflow is called an unattended loop.

Four runtimes are supported:

| Runtime | Trigger | Skill location | Subagent mechanism |
| --- | --- | --- | --- |
| Codex CLI | `$agentic-pipeline` | `plugins/agentic-pipeline/skills/agentic-pipeline/SKILL.md` | native subagents / OMX |
| Claude Code | installed skill/plugin surface | `plugins/agentic-pipeline/skills/agentic-pipeline/SKILL.md` | Claude Code task/subagent surface when available |
| Hermes Agent | `hermes -s agentic-pipeline` or `/skill agentic-pipeline` | `.hermes/skills/software-development/agentic-pipeline/SKILL.md` | `delegate_task`, `hermes -w`, cron, kanban |
| Devin CLI | `/agentic-pipeline` | `.devin/skills/agentic-pipeline/SKILL.md` | `run_subagent` + custom `AGENT.md` profiles |

---

## Codex CLI

### Install From GitHub

After this repository is published:

```powershell
codex plugin marketplace add https://github.com/BestQ-A/agentic-pipeline --ref main
codex plugin add agentic-pipeline@agentic-pipeline
```

Start a new Codex session after installation so the packaged skill is loaded.

### Install From A Local Clone

```powershell
git clone https://github.com/BestQ-A/agentic-pipeline C:\tools\agentic-pipeline
codex plugin marketplace add C:\tools\agentic-pipeline
codex plugin add agentic-pipeline@agentic-pipeline
```

### Use (Codex)

In a Codex session:

```text
$agentic-pipeline
```

The skill expects a project context and will audit local guidance, scripts,
skills, agents, and validation surfaces before standardizing a project-specific
workflow.

Agentic Pipeline maintains a central project dashboard under
`.pipeline/dashboard/`. The preferred human view is
`agentic-pipeline-dashboard.html`; `agentic-pipeline-dashboard.json` is the live
data source and `agentic-pipeline-dashboard.md` is the audit-friendly text copy.
The leader session uses the dashboard for macro/orchestration answers, while
goal-specific questions are routed to the logical agent that owns the relevant
goal slice when the dashboard is stale or incomplete.

For a dynamically refreshing browser view:

```powershell
.\plugins\agentic-pipeline\skills\agentic-pipeline\scripts\serve_agent_dashboard.ps1 -ProjectRoot .
```

The server listens on `127.0.0.1` by default. For future phone/LAN viewing, bind
explicitly after deciding the project state can be exposed on the local network:

```powershell
.\plugins\agentic-pipeline\skills\agentic-pipeline\scripts\serve_agent_dashboard.ps1 -ProjectRoot . -Host 0.0.0.0 -Port 8765
```

---

## Claude Code

### Install From GitHub

```powershell
claude plugin marketplace add BestQ-A/agentic-pipeline --sparse .claude-plugin plugins
claude plugin install agentic-pipeline@agentic-pipeline
```

Restart Claude Code after installation so the packaged skill is loaded.

### Install From A Local Clone

```powershell
git clone https://github.com/BestQ-A/agentic-pipeline C:\tools\agentic-pipeline
cd C:\tools\agentic-pipeline
claude plugin marketplace add ./ --scope user
claude plugin install agentic-pipeline@agentic-pipeline
```

### Use (Claude Code)

Ask Claude Code to use the installed Agentic Pipeline skill for a target
project. The skill keeps the same state-machine, preflight, dashboard, and
goal-ownership contract as the Codex package.

The central dashboard paths are shared across runtimes:
`.pipeline/dashboard/agentic-pipeline-dashboard.html`,
`.pipeline/dashboard/agentic-pipeline-dashboard.json`, and
`.pipeline/dashboard/agentic-pipeline-dashboard.md`.

---

## Hermes Agent

The repo ships a Hermes-native skill at
`.hermes/skills/software-development/agentic-pipeline/SKILL.md`. It adapts the
same loop-engineering contract to Hermes primitives: `delegate_task` for quick
subagents, `hermes -w` for isolated worktrees, `cronjob` / `hermes cron` for
scheduling, and `kanban` for durable multi-worker queues.

### Install (Hermes, user/global scope)

```powershell
git clone https://github.com/BestQ-A/agentic-pipeline C:\tools\agentic-pipeline
cd C:\tools\agentic-pipeline
.\scripts\install-hermes.ps1
.\scripts\install-hermes.ps1 -Force
```

```bash
git clone https://github.com/BestQ-A/agentic-pipeline ~/tools/agentic-pipeline
cd ~/tools/agentic-pipeline
chmod +x scripts/install-hermes.sh
./scripts/install-hermes.sh
./scripts/install-hermes.sh --force
```

Targets:

- Windows: `%LOCALAPPDATA%\hermes\skills\software-development\agentic-pipeline\`
- Linux/macOS: `${HERMES_HOME:-$HOME/.hermes}/skills/software-development/agentic-pipeline/`

### Install (Hermes, project scope)

```powershell
.\scripts\install-hermes.ps1 -Scope Project
```

```bash
./scripts/install-hermes.sh --project
```

This copies the skill into the current project's `.hermes/skills/` directory so
the project can carry the workflow with it.

### Use (Hermes)

Start a new Hermes session or reload skills, then:

```text
/skill agentic-pipeline
```

or preload it from the command line:

```powershell
hermes -s agentic-pipeline
hermes -s agentic-pipeline -z "Standardize this project's agent pipeline."
```

The Hermes skill keeps the shared dashboard convention under
`.pipeline/dashboard/` and uses the bundled scripts from its installed skill
directory.

---

## Devin CLI

The repo ships a Devin-native skill at `.devin/skills/agentic-pipeline/SKILL.md`
plus nine custom subagent profiles at `.devin/agents/<role>/AGENT.md`
(`explore`, `planner`, `architect`, `scriptification-engineer`, `executor`,
`test-engineer`, `code-reviewer`, `verifier`, `writer`).

### Install (Devin, user/global scope)

Clone, then run the installer for your platform.

```powershell
git clone https://github.com/BestQ-A/agentic-pipeline C:\tools\agentic-pipeline
cd C:\tools\agentic-pipeline
.\scripts\install-devin.ps1                # user scope (all projects)
.\scripts\install-devin.ps1 -Force         # overwrite existing
```

```bash
git clone https://github.com/BestQ-A/agentic-pipeline ~/tools/agentic-pipeline
cd ~/tools/agentic-pipeline
chmod +x scripts/install-devin.sh
./scripts/install-devin.sh                 # user scope (all projects)
./scripts/install-devin.sh --force         # overwrite existing
```

Targets (user scope):

- Windows: `%APPDATA%\devin\skills\agentic-pipeline\` and `%APPDATA%\devin\agents\<role>\`
- Linux/macOS: `~/.config/devin/skills/agentic-pipeline/` and `~/.config/devin/agents/<role>/`

### Install (Devin, project scope — committed to git, team-shared)

```powershell
.\scripts\install-devin.ps1 -Scope Project
```

```bash
./scripts/install-devin.sh --project
```

This copies the skill and agents into the current project's `.devin/` directory.

### Use (Devin)

Start a new Devin session, then:

```text
/agentic-pipeline [project-root]
```

The skill will:

1. Run the bundled `scripts/audit_project_surfaces.ps1` audit (read-only, emits JSON).
2. Spawn read-only `explore` / `planner` / `architect` subagents to map and plan.
3. Spawn write-capable `executor` / `test-engineer` / `scriptification-engineer` / `writer` subagents for scoped edits.
4. Spawn `code-reviewer` and `verifier` subagents for review and acceptance.
5. Report the standardized pipeline, changed files, validation evidence, and retained artifacts.

Subagents are spawned with `run_subagent` (background by default) and results are
collected with `read_subagent`. Each subagent returns the `subagent_result` shape
defined in the skill.

The Devin skill uses the same central dashboard convention as Codex:
`.pipeline/dashboard/agentic-pipeline-dashboard.html`,
`.pipeline/dashboard/agentic-pipeline-dashboard.json`, and
`.pipeline/dashboard/agentic-pipeline-dashboard.md`.

### Verify Devin sees the skill

After installation, in a Devin session:

```text
/help
```

`/agentic-pipeline` should appear in the slash-command list. The custom agent
profiles appear when Devin lists available subagent profiles.

---

## Included Files

Codex surface:

- `.agents/plugins/marketplace.json`: Codex marketplace entry for this repository.
- `plugins/agentic-pipeline/.codex-plugin/plugin.json`: Plugin manifest.
- `plugins/agentic-pipeline/skills/agentic-pipeline/SKILL.md`: Codex skill instructions.
- `plugins/agentic-pipeline/skills/agentic-pipeline/scripts/audit_project_surfaces.ps1`: Read-only project surface audit script.
- `plugins/agentic-pipeline/skills/agentic-pipeline/scripts/update_agent_dashboard.ps1`: Writes JSON, HTML, and Markdown dashboard outputs.
- `plugins/agentic-pipeline/skills/agentic-pipeline/scripts/serve_agent_dashboard.ps1`: Optional local HTTP server for the live web dashboard.

Claude Code surface:

- `.claude-plugin/marketplace.json`: Claude Code marketplace entry for this repository.
- `plugins/agentic-pipeline/.claude-plugin/plugin.json`: Claude Code plugin manifest.
- `plugins/agentic-pipeline/skills/agentic-pipeline/SKILL.md`: Shared Codex/Claude skill instructions.
- `plugins/agentic-pipeline/skills/agentic-pipeline/scripts/update_agent_dashboard.ps1`: Dashboard updater used by the shared skill.
- `plugins/agentic-pipeline/skills/agentic-pipeline/scripts/serve_agent_dashboard.ps1`: Optional local HTTP server for the live web dashboard.

Hermes Agent surface:

- `.hermes/skills/software-development/agentic-pipeline/SKILL.md`: Hermes Agent skill instructions.
- `.hermes/skills/software-development/agentic-pipeline/scripts/audit_project_surfaces.ps1`: Read-only project surface audit script, including `.hermes/skills`.
- `.hermes/skills/software-development/agentic-pipeline/scripts/update_agent_dashboard.ps1`: Dashboard updater.
- `.hermes/skills/software-development/agentic-pipeline/scripts/serve_agent_dashboard.ps1`: Optional local HTTP server for the live web dashboard.
- `.hermes/skills/software-development/agentic-pipeline/scripts/validate_agentic_pipeline_contract.ps1`: Hermes skill contract validator.
- `scripts/install-hermes.ps1` / `scripts/install-hermes.sh`: Cross-platform installers for Hermes user or project scope.

Devin surface:

- `.devin/skills/agentic-pipeline/SKILL.md`: Devin skill instructions (slash command `/agentic-pipeline`).
- `.devin/skills/agentic-pipeline/scripts/audit_project_surfaces.ps1`: Same audit script, bundled with the Devin skill.
- `.devin/skills/agentic-pipeline/scripts/update_agent_dashboard.ps1`: Writes JSON, HTML, and Markdown dashboard outputs.
- `.devin/skills/agentic-pipeline/scripts/serve_agent_dashboard.ps1`: Optional local HTTP server for the live web dashboard.
- `.devin/agents/<role>/AGENT.md`: Nine custom subagent profiles for the pipeline roles.
- `scripts/install-devin.ps1` / `scripts/install-devin.sh`: Cross-platform installers for Devin (user or project scope).

Runtime state, logs, caches, `.pipeline`, `.omx`, local credentials, and generated artifacts are intentionally excluded.

## Validate (Codex)

From this repository root:

```powershell
python <codex-home>\skills\.system\plugin-creator\scripts\validate_plugin.py .\plugins\agentic-pipeline
python <codex-home>\skills\.system\skill-creator\scripts\quick_validate.py .\plugins\agentic-pipeline\skills\agentic-pipeline
.\plugins\agentic-pipeline\skills\agentic-pipeline\scripts\validate_agentic_pipeline_contract.ps1 -SkillRoot .\plugins\agentic-pipeline\skills\agentic-pipeline
.\plugins\agentic-pipeline\skills\agentic-pipeline\scripts\update_agent_dashboard.ps1 -ProjectRoot . -LogicalAgent leader -Role leader -Status ready -OwnsGoalSlices orchestration -Objective "validate dashboard updater" -CurrentState dashboard_smoke -Summary "dashboard updater smoke test"
```

For manual browser preview, run `serve_agent_dashboard.ps1` from the usage
section and stop it with `Ctrl+C`.

## Validate (Claude Code)

From this repository root:

```powershell
claude plugin validate .\plugins\agentic-pipeline --strict
claude plugin validate .\.claude-plugin\marketplace.json --strict
```

## Validate (Hermes Agent)

From this repository root:

```powershell
.\.hermes\skills\software-development\agentic-pipeline\scripts\validate_agentic_pipeline_contract.ps1 -SkillRoot .\.hermes\skills\software-development\agentic-pipeline
.\scripts\install-hermes.ps1 -Force
hermes skills list --source all
```

Then start a fresh Hermes session and load:

```text
/skill agentic-pipeline
```

## Validate (Devin)

From this repository root:

```powershell
.\.devin\skills\agentic-pipeline\scripts\validate_agentic_pipeline_contract.ps1 -SkillRoot .\.devin\skills\agentic-pipeline
.\.devin\skills\agentic-pipeline\scripts\update_agent_dashboard.ps1 -ProjectRoot . -DashboardDir .pipeline\dashboard-devin-smoke -LogicalAgent devin-leader -Role leader -Status ready -OwnsGoalSlices orchestration -Objective "validate Devin dashboard updater" -CurrentState dashboard_smoke -Summary "Devin dashboard updater smoke test"
```

## License

This project is released under the Apache License 2.0, matching the Codex CLI license.
