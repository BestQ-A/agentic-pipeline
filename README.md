# Agentic Pipeline

Agentic Pipeline packages the `$agentic-pipeline` Codex skill (and a parallel
Devin skill `/agentic-pipeline`) for reusable project pipeline standardization.
It helps an agent define project workflow states, delegate role-agent work,
capture validation evidence, and retain repeatable project artifacts.

Two runtimes are supported:

| Runtime | Trigger | Skill location | Subagent mechanism |
| --- | --- | --- | --- |
| Codex CLI | `$agentic-pipeline` | `plugins/agentic-pipeline/skills/agentic-pipeline/SKILL.md` | native subagents / OMX |
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

Devin surface:

- `.devin/skills/agentic-pipeline/SKILL.md`: Devin skill instructions (slash command `/agentic-pipeline`).
- `.devin/skills/agentic-pipeline/scripts/audit_project_surfaces.ps1`: Same audit script, bundled with the Devin skill.
- `.devin/agents/<role>/AGENT.md`: Nine custom subagent profiles for the pipeline roles.
- `scripts/install-devin.ps1` / `scripts/install-devin.sh`: Cross-platform installers for Devin (user or project scope).

Runtime state, logs, caches, `.omx`, local credentials, and generated artifacts are intentionally excluded.

## Validate (Codex)

From this repository root:

```powershell
python C:\Users\61643\.codex\skills\.system\plugin-creator\scripts\validate_plugin.py .\plugins\agentic-pipeline
python C:\Users\61643\.codex\skills\.system\skill-creator\scripts\quick_validate.py .\plugins\agentic-pipeline\skills\agentic-pipeline
.\plugins\agentic-pipeline\skills\agentic-pipeline\scripts\validate_agentic_pipeline_contract.ps1 -SkillRoot .\plugins\agentic-pipeline\skills\agentic-pipeline
```

## Validate (Devin)

From this repository root:

```powershell
.\.devin\skills\agentic-pipeline\scripts\validate_agentic_pipeline_contract.ps1 -SkillRoot .\.devin\skills\agentic-pipeline
```

## License

This project is released under the Apache License 2.0, matching the Codex CLI license.
