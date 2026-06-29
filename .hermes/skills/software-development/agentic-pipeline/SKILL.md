---
name: agentic-pipeline
description: Use when a Hermes Agent session should standardize a project into an evidence-backed loop with discovery, isolated handoff, independent verification, persistent dashboard state, scheduling, budget caps, and human checkpoints.
version: 0.1.7
author: SkylarHu
license: Apache-2.0
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [agentic-pipeline, loop-engineering, project-standardization, multi-agent, dashboard]
    related_skills: [hermes-agent, agent-pipeline-orchestration, subagent-driven-development, hermes-agent-skill-authoring]
---

# Agentic Pipeline For Hermes Agent

## Overview

Use this skill as a Hermes-native command surface for project pipeline standardization. The leader session owns goal memory, decomposition, guidance binding, dashboard synchronization, and final verification. Substantive discovery, planning, implementation, review, and verification work should be delegated through Hermes primitives such as `delegate_task`, `hermes -w`, `cronjob`, `kanban`, project-local skills, and the terminal/file toolsets.

Agentic Pipeline is not a general "work harder" prompt. It turns a project workflow into an observable loop: named state, allowed transition, evidence, decision rule, retained artifact, stop condition, and a check that can say no.

## When To Use

- The user asks Hermes to standardize a repository's agent workflow, project rules, skills, or multi-agent process.
- Work needs repeatable discovery, planning, execution, review, and verifier gates rather than one-off implementation.
- A project needs a durable dashboard under `.pipeline/dashboard/` for future sessions.
- A task needs Hermes-specific orchestration with `delegate_task`, `hermes -w`, `cronjob`, `kanban`, or installed Hermes skills.

Do not use this skill for tiny one-shot edits where a normal direct fix plus tests is enough.

## Hermes Runtime Binding

Hermes surfaces to prefer:

- Load this skill with `hermes -s agentic-pipeline` or `/skill agentic-pipeline`.
- Use `delegate_task` for quick independent subagent work. Pass full context, exact guidance files, preflight evidence, and required result schema.
- Use `hermes -w` or isolated git worktrees for parallel code-writing agents.
- Use `cronjob` or `hermes cron` only after the loop has explicit discovery, verification, persistence, budget caps, and a human checkpoint.
- Use `kanban` when the work needs a durable multi-worker task board rather than a small set of delegated subtasks.
- Resolve bundled scripts relative to `${HERMES_SKILL_DIR}`. Do not hard-code a local development checkout path.

Default dashboard paths:

```text
.pipeline/dashboard/agentic-pipeline-dashboard.html
.pipeline/dashboard/agentic-pipeline-dashboard.json
.pipeline/dashboard/agentic-pipeline-dashboard.md
```

Bundled scripts:

```powershell
& "${HERMES_SKILL_DIR}/scripts/audit_project_surfaces.ps1" -ProjectRoot "<project-root>"
& "${HERMES_SKILL_DIR}/scripts/update_agent_dashboard.ps1" -ProjectRoot "<project-root>" -LogicalAgent leader -Role leader -Status ready -OwnsGoalSlices orchestration -Objective "<goal>" -CurrentState evidence_audit -Summary "<summary>"
& "${HERMES_SKILL_DIR}/scripts/validate_agentic_pipeline_contract.ps1" -SkillRoot "${HERMES_SKILL_DIR}"
```

## Loop Engineering Completeness Gate

Before calling a workflow a loop, prove that every field has evidence:

```text
loop_engineering_gate:
  discovery_source: <skill, query, queue, CI, issues, commits, inbox, monitor, cron script, or kanban board>
  handoff_isolation: <one worktree, branch, sandbox, kanban task, or serialized edit lane per independent task>
  verification_check: <independent evaluator, deterministic gate, test, screenshot, review, or kanban acceptance check that can reject>
  persistence_state: <dashboard, state file, kanban board, issue board, inbox, PR, or artifact that survives context reset>
  scheduling_trigger: <cronjob, webhook, Hermes cron, manual checkpoint, or explicit reason scheduling is intentionally absent>
  connector_scope: <local filesystem only or named external systems/connectors used for discovery/action>
  budget_caps: <per-run budget, daily budget, retry cap, max delegated tasks, or explicit bounded substitute>
  human_checkpoint: <where the loop stops for human judgment before merge/delete/deploy/external write>
```

Anti-pattern mapping:

- Missing `verification_check` is a nodding loop. The producer must not be the final judge.
- Missing `persistence_state` is an amnesiac loop. State must outlive a single context window.
- Missing or intentionally absent `scheduling_trigger` is a manual loop. Report it as manual until a real trigger exists.
- Missing `discovery_source` is a blind loop. Discovery belongs in a skill, script, queue, monitor, or board.
- Missing `handoff_isolation` under parallel writers is a tangled loop. Use worktrees, sandboxes, kanban task boundaries, or serialization.
- Missing `budget_caps` risks token blowout. Missing `human_checkpoint` risks cognitive surrender. Both must be explicit before unattended operation.

Evaluator rules:

- The evaluator is a skeptic: reject until evidence passes.
- Prefer acting verification over reading-only review. Run tests, inspect UI behavior, use screenshots, query the dashboard, or inspect kanban state.
- Use a fresh role, delegated task, or model for stop-condition judgment when available. If unavailable, require deterministic evidence plus a human checkpoint.

Growth rule:

- Grow loops in this order: one finding end to end, stronger discovery, stronger verification, scheduling, then parallelism. A loop earns more agents only after the evaluator catches real or fixture-backed failures.

## Mission Ledger

Before implementation, write these objects in the conversation and, when useful, into `.pipeline/context/` or the dashboard:

```text
mission:
  objective: <target result>
  constraints: <repo, runtime, safety, human preferences>
  acceptance_criteria: <what must be true>
  stop_condition: <complete|blocked|unsafe|needs-human>

loop_state:
  current_state: <intake|evidence_audit|plan_ready|implementation_ready|implementation_running|validation_running|review_ready|verified|retained>
  allowed_next_states: <states>
  transition_action: <command, delegate_task handoff, script, edit, or human action>
  evidence_required: <files, logs, tests, dashboard JSON, screenshots, kanban task ids>
  decision_rule: <how evidence maps to next state>
  retention_rule: <what becomes a skill, script, fixture, dashboard artifact, or project rule>
```

No mission ledger means the next transition is `evidence_audit`, not implementation.

## Guidance And Preflight Gate

Before implementation, build, test, run, deploy, destructive command, external write, or delegated handoff, establish:

```text
guidance_binding:
  project_root: <absolute path>
  authoritative_sources:
    - <AGENTS.md, CLAUDE.md, folder guidance, Hermes skill, project skill, script, rule, or plan path>
  applicable_rules:
    - <short actionable rule>
  required_preflight:
    - <tool, dependency, process, config, credential, branch, port, device, or artifact check>
  allowed_actions:
    - <commands or edit scopes allowed after preflight passes>
  forbidden_actions:
    - <actions disallowed until a state is reached>
  evidence_required:
    - <JSON, log, command output, file reference, screenshot, or exact string check>
  decision_rule:
    pass: <state transition>
    fail: <blocked|unsafe|needs-human transition>
```

```text
environment_preflight:
  status: pass|blocked|unsafe|needs-human
  checked_at: <timestamp>
  project_root: <absolute path>
  command: <script or command used>
  checks:
    - name: <check>
      expected: <condition>
      observed: <actual>
      status: pass|fail|unknown
      evidence: <path/log/output>
  blocked_actions:
    - <build|run|deploy|test|external-write|destructive-edit>
```

Rules:

- No guidance binding means no delegated implementation handoff.
- No preflight means do not claim build/run/deploy/test success.
- If a recurring preflight is missing, create a project-local checker before repeating manual reasoning.
- If a subagent result omits `guidance_followed` or `preflight_used`, reject it and request a corrected result.

## Role Map

Use stable logical agents even when Hermes returns transient task ids:

- `explore`: inventory guidance, skills, scripts, tests, dashboards, kanban boards, and runtime surfaces.
- `planner`: design stages, dependencies, state transitions, evidence, and stop conditions.
- `architect`: define ownership between AGENTS/CLAUDE guidance, Hermes skills, scripts, dashboards, and task boards.
- `scriptification-engineer`: turn repeated diagnostics into scripts, JSON reports, fixtures, and replay checks.
- `executor`: make bounded project-local edits.
- `test-engineer`: add or run repeatable validation.
- `code-reviewer`: skeptical review for bugs, duplication, overreach, and missing gates.
- `verifier`: final acceptance against mission, guidance, preflight, loop gate, and evidence.
- `writer`: tighten guidance text without expanding scope.

Prefer existing project-specific skills or agents before inventing new roles.

## Delegation Protocol

Use `delegate_task` for independent work slices. Use background mode when the runtime supports it and continue non-overlapping leader work.

Every delegated prompt must include:

```text
logical_agent: <stable name>
role: <explore|planner|architect|executor|test-engineer|code-reviewer|verifier|writer>
owns_goal_slices:
  - <slice>
guidance_binding: <exact files and rules>
environment_preflight: <status and evidence>
allowed_actions:
  - <scope>
forbidden_actions:
  - <scope>
required_result_schema: subagent_result
human_cooperation_rule: If you need user cooperation, do not ask the user directly. Report it to the leader with exact action, reason, urgency, steps, success signal, and blocking status.
```

Required result:

```text
subagent_result:
  status: complete|blocked|failed
  role: <role>
  logical_agent: <stable project/user agent name>
  run_id: <Hermes task/session id if available>
  owns_goal_slices: <slices>
  guidance_followed: <authoritative files/rules used>
  preflight_used: <environment_preflight id/path/status>
  dashboard_update: <summary/open questions/next action>
  summary: <what was done or discovered>
  changed_files: <paths or none>
  evidence: <commands, checks, references, screenshots, task ids>
  blockers: <remaining blockers or none>
  human_action_required: <payload or none>
  next_recommendation: <next action>
```

If multiple writers could touch the same file, serialize through the leader or use isolated worktrees. Do not let parallel writers share one working directory.

## Workflow

1. Establish the mission ledger.
   - Completion: mission, `loop_state`, `loop_engineering_gate`, dashboard path, and irreversible boundaries are explicit.
2. Audit project surfaces.
   - Run `audit_project_surfaces.ps1`; include `AGENTS.md`, `CLAUDE.md`, `.hermes/skills`, `.agents/skills`, `.codex/agents`, `.codex/skills`, `.devin`, `.pipeline`, scripts, tests, command files, and known dashboards.
   - Completion: audit output was read and the authoritative guidance files are named.
3. Bind guidance and preflight.
   - Completion: guidance binding and environment preflight are either `pass` or explicitly `blocked|unsafe|needs-human`.
4. Initialize dashboard.
   - Use `update_agent_dashboard.ps1` before spawning implementation agents.
   - Completion: JSON, HTML, and Markdown dashboard files exist or the write failure is the blocker.
5. Delegate discovery and planning.
   - Spawn `explore`, `planner`, and `architect` as needed.
   - Completion: each result includes guidance, preflight, owned slices, evidence, and dashboard update.
6. Integrate a pipeline plan.
   - Define stages, owners, entry criteria, exit criteria, validation commands, and decision rules.
   - Completion: every build/run/deploy/test state names a preflight command and blocked behavior.
7. Delegate implementation.
   - Use `executor`, `test-engineer`, `scriptification-engineer`, and `writer` only within allowed scope.
   - Completion: changed files are bounded, dashboard updated, and no shared-file collision is unresolved.
8. Review and verify.
   - Use `code-reviewer` and `verifier`.
   - Completion: verifier says the pipeline passes guidance, preflight, loop gate, budget/human checkpoint, and evidence requirements.
9. Retain.
   - Promote successful repeated behavior into project skill, script, fixture, dashboard artifact, or guidance.
   - Completion: final answer names retained artifacts and remaining blockers.

## Dashboard Practice

Use the dashboard as shared state, not decoration:

- Update after every delegated result, human-action request, routed question answer, verifier decision, and blocker.
- Before answering a user question, consult the dashboard. If the answer belongs to an owned goal slice and the dashboard is stale, refresh the owner first.
- Use the HTML dashboard for human reading. Serve it only when useful and bind to `127.0.0.1` unless LAN viewing is intentional.

## Scheduling And Automation

Only schedule a loop after the completeness gate is explicit.

For Hermes:

- Prefer `cronjob` or `hermes cron` for recurring local runs.
- Cron scripts must live in the Hermes scripts directory when using Hermes cron script hooks; copy project scripts there and reference by filename if needed.
- Use `kanban` when scheduled workers need a durable queue, ownership, retries, and task comments.
- Keep a human checkpoint before merge/delete/deploy/external writes. PRs may be opened; auto-merge requires explicit user authorization.

## Common Pitfalls

1. Calling a manual checklist a loop. If no trigger exists, say "manual pipeline" until scheduling is real.
2. Letting the implementer self-review. Use a separate evaluator or deterministic gate.
3. Leaving state in chat. Write dashboard/state/kanban artifacts.
4. Spawning parallel writers in one worktree. Use `hermes -w`, git worktrees, kanban task isolation, or serialization.
5. Adding guidance prose without a checker. Repeated decisions belong in scripts or fixtures.
6. Forgetting budget caps. Set retry and task-count ceilings before unattended runs.
7. Closing every door. Keep at least one human checkpoint before irreversible or external actions.

## Verification Checklist

- [ ] `loop_engineering_gate` is filled.
- [ ] Guidance binding names exact files and rules.
- [ ] Environment preflight has evidence.
- [ ] Dashboard JSON/HTML/Markdown exists or write failure is the explicit blocker.
- [ ] Delegated results include `guidance_followed` and `preflight_used`.
- [ ] Independent verification acted on evidence where practical.
- [ ] Budget caps and human checkpoint are explicit before unattended execution.
- [ ] Final verifier result was read before claiming completion.
