# Agentic Pipeline Codex Plugin

Agentic Pipeline packages the `$agentic-pipeline` Codex skill for reusable project pipeline standardization. It helps Codex define project workflow states, delegate role-agent work, capture validation evidence, and retain repeatable project artifacts.

## Install From GitHub

After this repository is published:

```powershell
codex plugin marketplace add https://github.com/BestQ-A/agentic-pipeline --ref main
codex plugin add agentic-pipeline@agentic-pipeline
```

Start a new Codex session after installation so the packaged skill is loaded.

## Install From A Local Clone

```powershell
git clone https://github.com/BestQ-A/agentic-pipeline C:\tools\agentic-pipeline
codex plugin marketplace add C:\tools\agentic-pipeline
codex plugin add agentic-pipeline@agentic-pipeline
```

## Use

In a Codex session:

```text
$agentic-pipeline
```

The skill expects a project context and will audit local guidance, scripts, skills, agents, and validation surfaces before standardizing a project-specific workflow.

## Included Files

- `.agents/plugins/marketplace.json`: Codex marketplace entry for this repository.
- `plugins/agentic-pipeline/.codex-plugin/plugin.json`: Plugin manifest.
- `plugins/agentic-pipeline/skills/agentic-pipeline/SKILL.md`: Skill instructions.
- `plugins/agentic-pipeline/skills/agentic-pipeline/scripts/audit_project_surfaces.ps1`: Read-only project surface audit script.

Runtime state, logs, caches, `.omx`, local credentials, and generated artifacts are intentionally excluded.

## Validate

From this repository root:

```powershell
python C:\Users\61643\.codex\skills\.system\plugin-creator\scripts\validate_plugin.py .\plugins\agentic-pipeline
python C:\Users\61643\.codex\skills\.system\skill-creator\scripts\quick_validate.py .\plugins\agentic-pipeline\skills\agentic-pipeline
```

## Release Notes

This package is local-install ready after validation passes. Before a public open-source release, choose and add a license file deliberately.
