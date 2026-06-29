# Agentic Pipeline Repository Notes

## Project Layout

- This repository is the source clone for the Agentic Pipeline package. The Codex plugin surface lives under `plugins/agentic-pipeline/`, the Claude Code plugin surface lives under `.claude-plugin/` and `plugins/agentic-pipeline/.claude-plugin/`, the Hermes Agent skill surface lives under `.hermes/skills/software-development/agentic-pipeline/`, and the Devin slash-command surface lives under `.devin/`.
- Use `rg --files -uu` when auditing this repository so hidden package surfaces such as `.devin/`, `.hermes/skills/`, `.codex-plugin/`, and `.claude-plugin/` are included.
- Only `.hermes/skills/**` is intended to be versioned for Hermes. Keep Hermes runtime state, local profile data, logs, credentials, caches, and non-skill `.hermes/*` paths ignored.

## Installation And Cache Checks

- Before reinstalling from a local clone, run `codex plugin marketplace list` and `claude plugin marketplace list` to confirm the `agentic-pipeline` marketplace points at the intended source checkout; sibling clones can otherwise leave Codex or Claude Code loading stale plugin content.
- The Codex plugin manifest is `plugins/agentic-pipeline/.codex-plugin/plugin.json`; compare its `version` with the installed Codex plugin cache before assuming the active `$agentic-pipeline` skill matches the source tree.
- Devin installation is handled by `scripts/install-devin.ps1` and `scripts/install-devin.sh`; user scope installs to the Devin user config directories, while project scope copies into the current project's `.devin/` directory.
- Hermes installation is handled by `scripts/install-hermes.ps1` and `scripts/install-hermes.sh`; user scope installs to the Hermes user skills directory, while project scope copies into the current project's `.hermes/skills/` directory.
- Dashboard support includes `serve_agent_dashboard.ps1` beside the skill scripts for Codex, Devin, and Hermes surfaces; keep dashboard-related script changes mirrored across those packaged surfaces unless the runtime behavior intentionally diverges.

## Loop Contract Maintenance

- The shared Codex/Claude skill, the Devin skill, and the Hermes skill all enforce a `loop_engineering_gate` inspired by the Loop Engineering paper: discovery source, handoff isolation, independent verification, persistent state, scheduling trigger, connector scope, budget caps, and human checkpoint. Keep these markers and the matching validator checks mirrored across runtime surfaces.
- The contract validator intentionally checks for the loop anti-pattern names `nodding loop`, `amnesiac loop`, `manual loop`, `blind loop`, and `tangled loop`; update both validator copies when changing those terms.
