---
name: agentic-pipeline
description: User-level command for delegated project pipeline standardization. Use when the user asks Codex to stop directly implementing and instead remember the goal, decompose it, define a research/development pipeline, spawn role agents, and manage those agents to improve project-local agent definitions, folder rules, AGENTS/CLAUDE guidance, and project skills until the pipeline is standardized and verified.
---

# Agentic Pipeline

## Overview

Use this skill as a command surface for agent-led project standardization. The leader owns goal memory, decomposition, delegation, integration, and verification; substantive implementation work is assigned to role agents with explicit `agent_type` whenever native subagents are available.

## Intelligence Loop Principle

Reliable agent performance comes from explicit state spaces, repeatable observe-plan-act-verify loops, and durable capture of lessons into software artifacts. Keep this operational: state, transition, evidence, decision rule, retained artifact, and stop condition. A first loop can be weak; it must be able to run, record outcomes, absorb failures, preserve successful patterns, and become stronger over repeated real tasks.

## State Space Ledger

Every pipeline should be modeled as a state machine before it becomes a team plan.

- Define named states for the project workflow, for example `intake`, `evidence_audit`, `plan_ready`, `implementation_ready`, `implementation_running`, `validation_running`, `review_ready`, `verified`, and `retained`.
- Define allowed transitions. Do not let the computer or project drift through unmanaged side effects; each transition needs an action, evidence, failure mode, and recovery path.
- Define the current state before spawning agents or editing files. When the state is unknown, first run an audit or diagnostic step that makes the state observable.
- Define stop conditions for success, blocked, unsafe, or needs-human states. Do not create unbounded loops; every iteration needs a bounded next checkpoint and eventual verifier signoff.
- Keep each loop iteration machine-checkable where possible: JSON reports, script output, exact paths, test logs, validation summaries, screenshots with provenance, or subagent result objects.
- Treat scripts and checkers as the durable nervous system of the loop. Reasoning can propose hypotheses, but repeatable software should decide recurring questions.

Required loop shape:

```text
loop_state:
  objective: <target result>
  current_state: <named state>
  allowed_next_states: <states>
  transition_action: <command, agent handoff, edit, or human action>
  evidence_required: <files, logs, test output, screenshots, JSON>
  decision_rule: <how evidence maps to next state>
  retention_rule: <what successful result becomes a skill, script, test, or artifact>
  stop_condition: <complete|blocked|unsafe|needs-human>
```

## Leader Contract

When this skill is active:

- Do not directly implement project changes in the leader lane. Leader-only bootstrapping means non-mutating setup: goal ledger, audit runs, plan integration, handoff prompts, and verification routing.
- Keep a visible goal statement with target result, constraints, acceptance criteria, evidence required, and stop condition.
- Keep a visible loop state. State the current named state, the next allowed transition, validation evidence, and stop condition before giving process detail.
- Use fixed logical agents for recurring pipeline roles. Prefer existing project/user agent definitions and stable role names over ad hoc temporary agents; native spawn IDs are only background run instances for those fixed logical agents.
- Use native subagents for independent work slices when the subagent surface is available. Always set `agent_type` to an installed role such as `explore`, `planner`, `architect`, `executor`, `test-engineer`, `code-reviewer`, `verifier`, or `writer`, and include the fixed logical agent name in the handoff.
- Run spawned agents in the background. Keep the leader lane non-blocking: do not wait on a subagent unless the next leader action strictly depends on that specific result; while subagents run, advance non-overlapping planning, integration, validation setup, or other ready work.
- Treat subagents as not user-visible. When a subagent needs human cooperation, it must report upward to the leader; the leader is responsible for telling the user what to do through the main conversation or an available desktop GUI notification.
- Treat subagent completion as an asynchronous event. When a background subagent completes, collect its final message, changed files, evidence, blockers, and human-action requests, then integrate that information into the leader's current state before deciding the next step.
- If native subagent spawning is not available in the current surface, stop before implementation and report the exact blocker. Do not silently convert the workflow into direct execution.
- In Codex App outside tmux, do not rely on OMX `team`, `hud`, or `question` runtime surfaces unless an attached tmux OMX CLI shell is available.
- Preserve unrelated files and local changes. Keep edits project-scoped unless the user explicitly asks for user-level changes.

## Workflow

1. Establish the mission ledger.
   - Write the current goal in one paragraph.
   - Define success criteria for a standardized project pipeline: stages, role ownership, local rules, local skills, validation commands, and review gates.
   - Define the initial loop state, allowed state transitions, evidence required per transition, and retention rule for successful iterations.
   - Identify irreversible or external-production boundaries.

2. Capture repeatable project evidence.
   - Run `scripts/audit_project_surfaces.ps1 -ProjectRoot <path>` from this skill before assigning implementation work.
   - Use the report to identify existing `AGENTS.md`, `CLAUDE.md`, `.codex/agents`, `.agents/skills`, `.codex/skills`, `rules`, scripts, tests, package/build commands, loop artifacts, and retained context.
   - Treat the active project root and folder-local guidance as authoritative over assumptions.
   - If the evidence surface is too weak for repeated use, create a script/checker first instead of continuing with one-off reasoning.

3. Define the loop before delegation.
   - State current state, target state, allowed transitions, validation signal, failure states, and durable learning target.
   - Decide what artifact should improve if this loop succeeds or fails: script, fixture, local guidance, project skill, fixed agent, or team definition.
   - If this cannot be stated concretely, route to `planner` or `architect` before implementation agents.

4. Spawn discovery and planning agents.
   - First map existing project agents and skills. Reuse matching fixed agents before creating any new role.
   - `explore`: map current project guidance, agents, skills, scripts, and test commands.
   - `planner`: propose a stage-by-stage research/development pipeline with artifacts and gates.
   - `architect`: define ownership boundaries between global guidance, project guidance, agent prompts, folder rules, skills, scripts, and tests.
   - `scriptification-engineer` or `test-engineer`: turn recurring diagnostic or decision logic into scripts, JSON outputs, and regression fixtures.
   - `critic` or `code-reviewer`: challenge overreach, duplicated guidance, missing gates, and unsafe edits.

5. Integrate a pipeline plan.
   - Produce a concise plan with stages such as intake, evidence audit, architecture/risk plan, implementation, targeted tests, review, verifier signoff, and final report.
   - For each stage, specify the owner agent, required artifacts, entry criteria, exit criteria, and validation command or evidence.
   - For each state transition, specify the decision rule. A stage without a decision rule is not yet a reliable loop.
   - Define fixed logical agents for the pipeline, for example `gaze-bisection-explorer`, `gaze-bisection-planner`, `gaze-bisection-architect`, `gaze-bisection-executor`, `gaze-bisection-test-engineer`, and `gaze-bisection-verifier`.
   - Prefer project-local `.agents/skills/<role-workflow>` for reusable role workflows and project-local guidance files for durable rules.
   - Prefer script-local or skill-local regression fixtures for successful visual/log/runtime classifications so the loop can learn from practice.

6. Spawn implementation agents.
   - `executor`: make bounded project-local edits to agent definitions, folder rules, skills, scripts, or guidance.
   - `test-engineer`: add or refine repeatable checks for the pipeline and guidance discovery where practical.
   - `writer`: tighten guidance text without expanding scope.
   - `scriptification-engineer`: build or harden decision software for recurring checks; do not leave repeated decisions as prose-only instructions.
   - If the needed fixed logical agent does not exist yet, create or update the project-level agent/skill definition as a pipeline artifact before relying on repeated temporary handoffs.
   - Assign non-overlapping files when possible. If two agents need the same file, serialize edits through the leader.

7. Supervise background agents without blocking.
   - Spawn agents as background workers and immediately continue with ready leader work instead of waiting by default.
   - Poll or wait only at synchronization points: plan integration, shared-file merge, review gate, verifier gate, or when no other meaningful non-overlapping work exists.
   - When the tool/runtime reports that a subagent completed, read the subagent completion payload before making claims about that work.
   - Use bounded waits with a clear timeout. If an agent is slow, record it as pending and continue any safe branch that does not require that result.
   - Do not ask the user to wait for child-agent internals. Surface only actionable human requests, blockers, or checkpoint summaries.

8. Verify and review.
   - Run the smallest validation that proves each claim: skill validators, syntax checks, project tests, lint/typecheck, script dry runs, or exact-string checks.
   - Spawn `code-reviewer` for changed guidance/skill files when the change is broad.
   - Spawn `verifier` to confirm that the final pipeline is complete, non-duplicative, project-scoped, and has evidence.
   - Run at least one loop dry run or replay against a known scenario when the pipeline includes a new script, state transition, or classifier.

9. Finalize.
   - Report changed files, the standardized pipeline, validation evidence, and remaining risks.
   - Report the final loop state and what was retained for future runs: skill, script, fixture, artifact, project rule, team role, or memory note.
   - Do not mark completion if the leader had to implement the substantive work directly because spawning was unavailable.

## Practice Retention

The pipeline should grow through use.

- Retain successful loops as project skills under `.agents/skills/<workflow>`.
- Retain deterministic checks as scripts under the owning skill's `scripts/` folder or the project's `scripts/` folder.
- Retain examples, fixtures, and known failure cases near the script or skill that uses them.
- Retain operator-facing state reports under `.omx/artifacts`, `.omx/context`, or project-local evidence folders when they help future runs.
- Use a durability ladder rather than creating global sprawl: one-off artifact -> script/check -> local guidance -> project skill -> fixed agent/team definition -> user-level/global skill only when explicitly requested.
- Do not retain noise. A retained artifact should answer a future decision, reproduce a failure, or validate a transition.
- When a loop fails, record the smallest useful correction: missing state, missing evidence, bad decision rule, wrong capture point, weak script, unsafe transition, or unclear ownership.
- After a loop succeeds repeatedly, promote it from prompt/process into a skill, script, test, or fixed team role.

## Background Agent Supervision

Default posture: spawn in background, continue in foreground, synchronize only when needed.

- Treat every spawned ID as a run instance, not the agent identity. Track both `logical_agent` and `run_id`.
- Reuse a still-open run instance with `send_input` when the follow-up belongs to the same logical agent and context; spawn a new run only for a new independent slice, a completed/closed run, or a different fixed logical agent.
- Track each subagent as `pending`, `ready`, `blocked`, `needs-human`, or `complete`.
- Maintain a leader-side ready queue of work that does not depend on pending subagent output.
- Prefer multiple short synchronization checkpoints over one long blocking wait.
- Harvest completed subagent results asynchronously: on completion notification, capture status, summary, changed paths, validation evidence, unresolved blockers, and any `human_action_required` payload.
- If a subagent reports partial results, integrate the usable part and keep the rest pending.
- If all useful branches are blocked on subagents, report the current blockers and the next synchronization condition instead of pretending progress is happening.
- Close completed agents after their result is integrated so finished children do not accumulate.

## Fixed Agent Strategy

Use stable logical agents as the project operating model.

- Before spawning, inspect existing project agents under `.codex/agents`, project skills under `.agents/skills`, and documented role ownership in `AGENTS.md` or folder-local guidance.
- Prefer fixed project-specific logical agents for recurring responsibilities. For the gaze bisection workflow, names should be stable and domain-specific rather than generic one-off descriptions.
- Do not create a new temporary logical role merely because a task wording changed. Route the work to the closest existing fixed agent and pass the specific task as that run's assignment.
- If a durable responsibility is missing, add or update the project-level agent/skill definition as part of standardizing the pipeline, then use that fixed role in future runs.
- Native subagent IDs such as `019f...` are acceptable as background execution instances, but final reports and ledgers should name the fixed logical agent first and the run ID second.

Required subagent completion shape:

```text
subagent_result:
  status: complete|blocked|failed
  role: <agent_type>
  logical_agent: <stable project/user agent name>
  run_id: <spawned background instance id>
  summary: <what was done or discovered>
  changed_files: <paths or none>
  evidence: <commands, checks, or references>
  blockers: <remaining blockers or none>
  human_action_required: <payload or none>
  next_recommendation: <next action for leader>
```

## Human Cooperation Protocol

Assume the user cannot see subagent threads, background panes, or worker logs in real time.

- Include this instruction in every subagent handoff: "If you need user cooperation, do not ask the user directly. Report the need to the leader with the required action, reason, urgency, exact steps, expected result, and whether work is blocked."
- Subagents must escalate human-dependent work for login, credential entry, hardware actions, GUI inspection, permission decisions, destructive choices, unclear product intent, or any action outside their assigned write scope.
- Subagents may continue non-blocked work after escalation, but must mark the human action as `blocking` when no meaningful progress remains without it.
- The leader consolidates requests from subagents, removes duplicates, and asks the user in the main conversation with exact steps and success evidence. Do not forward raw subagent uncertainty unless it materially affects the decision.
- Use desktop GUI notifications only when a reliable local notification path is available and the request is time-sensitive or the user explicitly asked for GUI prompting. Always also keep the main conversation as the source of record.
- Do not let subagents perform external-production, credential-gated, destructive, or materially scope-changing actions merely because they can operate a GUI. Escalate those decisions to the leader, then the leader asks the user.

Required escalation shape:

```text
human_action_required:
  blocking: true|false
  requested_by: <agent role/name>
  action: <exact user action>
  reason: <why this is needed>
  steps: <short ordered steps>
  success_signal: <what the user or leader should observe>
  fallback: <what the agent can do if unavailable>
```

## Default Agent Set

Use this staffing pattern unless the project shape clearly needs less:

- `explore`: current-state inventory and local convention mapping.
- `planner`: stage design, dependencies, and sequencing.
- `architect`: file ownership, guidance hierarchy, and extensibility boundaries.
- `scriptification-engineer`: repeated diagnostics, classifiers, decision trees, and loop automation.
- `executor`: scoped edits.
- `test-engineer`: repeatable validation and regression checks.
- `code-reviewer`: risk and duplication review.
- `verifier`: final evidence and acceptance check.

## Project Artifacts To Standardize

Review and improve only the artifacts relevant to the active project:

- `AGENTS.md` or `AGENTS.override.md` for top-level project guidance.
- `CLAUDE.md` when this user's Codex config includes it as a project fallback and the project already uses it for local reminders.
- Folder-local rule files under `rules`, `.cursor/rules`, `.windsurf/rules`, or equivalent directories when present.
- Native role prompts under `.codex/agents` or user-level `.codex/agents` only when the request is explicitly user-level.
- Project skills under `.agents/skills/<skill-name>`.
- Reusable scripts under project `scripts` or skill-local `scripts`.
- Loop/context/artifact surfaces under `.omx/context`, `.omx/artifacts`, `.omx/state`, or equivalent project-local state only when they are intentionally part of the workflow.
- Regression fixtures and known-good/known-bad examples that let scripts replay prior practice.
- Validation commands documented in package, build, test, or project guidance files.

## Rules For Guidance Edits

- Prefer short managed sections over sprawling global rules.
- Put broad project behavior in `AGENTS.md`; put repeatable task workflows in project skills; put deterministic checks in scripts.
- Keep role prompts focused on role behavior. Do not duplicate the entire pipeline in every agent prompt.
- Do not include generated, vendor, dependency-cache, build-output, or package-output directories in broad guidance generation.
- Preserve existing managed-block markers and non-owned content.
- Add dependencies only with explicit user request.

## Audit Script

Run:

```powershell
& 'C:\Program Files\PowerShell\7\pwsh.exe' -NoProfile -ExecutionPolicy Bypass -File 'C:\Users\61643\.codex\skills\agentic-pipeline\scripts\audit_project_surfaces.ps1' -ProjectRoot '<project-root>'
```

By default the script only reads and emits JSON to stdout. Use `-OutputPath <project-root-relative-or-contained-report.json>` when a durable artifact is useful; the script refuses output outside the project root and refuses overwrite unless `-Force` is supplied.

## Completion Criteria

The workflow is complete only when:

- The project has a named R&D pipeline with owners, artifacts, entry/exit criteria, and validation evidence.
- Project agents, local rules, and project skills are present or deliberately skipped with reasons.
- Any human-cooperation requests from subagents were resolved, explicitly deferred, or reported as remaining blockers.
- Validation ran and the output was read.
- A final verifier pass agrees that the standardized pipeline is usable by future Codex sessions.
