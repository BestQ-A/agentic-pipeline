---
name: agentic-pipeline
description: User-level command for delegated project pipeline standardization. Use when the user asks Devin to stop directly implementing and instead remember the goal, decompose it, define a research/development pipeline, spawn role subagents, and manage those subagents to improve project-local agent definitions, folder rules, AGENTS/CLAUDE guidance, and project skills until the pipeline is standardized and verified.
argument-hint: "[project-root]"
triggers:
  - user
  - model
---

# Agentic Pipeline

## Overview

Use this skill as a command surface for agent-led project standardization. The leader owns goal memory, decomposition, delegation, integration, and verification; substantive implementation work is assigned to role subagents with explicit `agent` profile whenever `run_subagent` is available.

This skill is runtime-portable: it works in any agent runtime that supports background subagents, but the concrete instructions below target **Devin CLI** (`run_subagent` with `is_background`, `read_subagent`, and custom subagent profiles under `.devin/agents/`).

## Intelligence Loop Principle

Reliable agent performance comes from explicit state spaces, repeatable observe-plan-act-verify loops, and durable capture of lessons into software artifacts. Keep this operational: state, transition, evidence, decision rule, retained artifact, and stop condition. A first loop can be weak; it must be able to run, record outcomes, absorb failures, preserve successful patterns, and become stronger over repeated real tasks.

## State Space Ledger

Every pipeline should be modeled as a state machine before it becomes a team plan.

- Define named states for the project workflow, for example `intake`, `evidence_audit`, `plan_ready`, `implementation_ready`, `implementation_running`, `validation_running`, `review_ready`, `verified`, and `retained`.
- Define allowed transitions. Do not let the computer or project drift through unmanaged side effects; each transition needs an action, evidence, failure mode, and recovery path.
- Define the current state before spawning subagents or editing files. When the state is unknown, first run an audit or diagnostic step that makes the state observable.
- Define stop conditions for success, blocked, unsafe, or needs-human states. Do not create unbounded loops; every iteration needs a bounded next checkpoint and eventual verifier signoff.
- Keep each loop iteration machine-checkable where possible: JSON reports, script output, exact paths, test logs, validation summaries, screenshots with provenance, or subagent result objects.
- Treat scripts and checkers as the durable nervous system of the loop. Reasoning can propose hypotheses, but repeatable software should decide recurring questions.

Required loop shape:

```text
loop_state:
  objective: <target result>
  current_state: <named state>
  allowed_next_states: <states>
  transition_action: <command, subagent handoff, edit, or human action>
  evidence_required: <files, logs, test output, screenshots, JSON>
  decision_rule: <how evidence maps to next state>
  retention_rule: <what successful result becomes a skill, script, test, or artifact>
  stop_condition: <complete|blocked|unsafe|needs-human>
```

## Guidance Adherence Gate

This skill exists to override ad hoc model habits with project-local operating logic. Do not rely on a subagent "remembering" to behave correctly. Make the required behavior explicit, observable, and rejectable.

Before any implementation, build, test, run, deploy, destructive command, or external handoff, the leader must establish a guidance binding:

```text
guidance_binding:
  project_root: <absolute path>
  authoritative_sources:
    - <AGENTS.md, folder-local AGENTS.md, project skill, script, rule, or plan path>
  applicable_rules:
    - <short rule copied or paraphrased from the source>
  required_preflight:
    - <environment, artifact, dependency, process, device, config, credential, or permission check>
  allowed_actions:
    - <commands or edit scopes allowed after preflight passes>
  forbidden_actions:
    - <actions disallowed until a specific state is reached>
  evidence_required:
    - <JSON report, log, command output, file reference, screenshot, or exact string check>
  decision_rule:
    pass: <state transition if evidence is good>
    fail: <blocked/unsafe/needs-human transition if evidence is bad>
```

Required behavior:

- No guidance binding means no downstream action. The next transition is `evidence_audit`, not implementation.
- The binding must name exact files or scripts. Vague phrases like "follow project rules" are not enough.
- If `AGENTS.md` and a project skill disagree, the leader must state the conflict and choose the narrower, more local, or more recently explicit rule before acting.
- If the environment is part of correctness, the environment check is mandatory evidence, not a nice-to-have. Examples: running processes that lock DLLs, active config file selected by launch cwd, device connection state, service ports, credentials, branch cleanliness, build output directory, and deployment target writability.
- A subagent handoff without a guidance binding is invalid. The leader must revise the handoff before spawning or sending work.

## Environment Preflight Gate

Every project pipeline must define an environment preflight before any action whose result depends on local machine state.

Minimum preflight shape:

```text
environment_preflight:
  status: pass|blocked|unsafe|needs-human
  checked_at: <timestamp>
  project_root: <absolute path>
  command: <script or command used>
  checks:
    - name: <check name>
      expected: <required condition>
      observed: <actual condition>
      status: pass|fail|unknown>
      evidence: <path/log/output>
  allowed_next_states:
    - <state names>
  blocked_actions:
    - <build|run|deploy|test|external-write|destructive-edit>
  remediation:
    - <automatic safe action or exact human action request>
```

Decision rules:

- `pass` permits only the actions listed in `allowed_next_states`.
- `blocked` means the subagent may inspect, edit docs/scripts, or produce a remediation plan, but must not claim build/run/deploy/test success for the blocked branch.
- `unsafe` stops execution until the unsafe condition is resolved.
- `needs-human` must use the Human Cooperation Protocol with exact user action and success signal.
- If a preflight script does not exist for a recurring environment check, create the script/checker before repeating the manual check.

Typical checks to encode in project skills/scripts:

- Required tools and versions are available.
- The active config file is the one the executable or tool will actually read.
- Build output and deployment artifact paths are known.
- Target artifacts are not locked by running processes.
- Runtime services, devices, displays, ports, or credentials match the intended test.
- Working tree state is understood before edits, commits, or pushes.

## Leader Contract

When this skill is active:

- Do not directly implement project changes in the leader lane. Leader-only bootstrapping means non-mutating setup: team coverage, goal ownership, audit runs, plan integration, handoff prompts, dashboard synchronization, and verification routing.
- Do not treat the leader as the all-knowing project context holder. The leader owns orchestration completeness; fixed logical agents own their delegated goal slices, current facts, open questions, and answer authority for those slices.
- Keep a visible goal statement with target result, constraints, acceptance criteria, evidence required, and stop condition.
- Keep a visible loop state. State the current named state, the next allowed transition, validation evidence, and stop condition before giving process detail.
- Keep a visible guidance binding and environment preflight status before assigning implementation, build, run, deploy, or validation work.
- Reject any subagent result that does not report which guidance sources it followed and what preflight evidence it used.
- Use fixed logical agents for recurring pipeline roles. Prefer existing project/user agent definitions and stable role names over ad hoc temporary agents; a spawned `run_subagent` ID is only a background run instance for a fixed logical agent.
- Use `run_subagent` for independent work slices. Always set `profile` (or `agent`) to an installed role such as `explore`, `planner`, `architect`, `executor`, `test-engineer`, `code-reviewer`, `verifier`, or `writer`, and include the fixed logical agent name in the handoff prompt. Prefer `is_background: true` so the leader lane stays non-blocking.
- Keep the leader lane non-blocking: do not wait on a subagent unless the next leader action strictly depends on that specific result; while subagents run, advance non-overlapping planning, integration, validation setup, or other ready work.
- Treat subagents as not user-visible. When a subagent needs human cooperation, it must report upward to the leader; the leader is responsible for telling the user what to do through the main conversation.
- Treat subagent completion as an asynchronous event. When a background subagent completes, call `read_subagent` to collect its final message, changed files, evidence, blockers, and human-action requests, then integrate that information into the leader's current state before deciding the next step.
- If `run_subagent` is not available in the current surface, stop before implementation and report the exact blocker. Do not silently convert the workflow into direct execution.
- Preserve unrelated files and local changes. Keep edits project-scoped unless the user explicitly asks for user-level changes.

## Goal Ownership And Question Routing

Agentic Pipeline uses a distributed knowledge model. The leader is a conductor and verifier, not the sole memory of every project detail.

Required ownership map:

```text
goal_ownership_map:
  project_root: <absolute path>
  dashboard_path: <project-local dashboard path>
  logical_agents:
    - name: <stable logical agent name>
      role: <explore|planner|architect|executor|test-engineer|code-reviewer|verifier|writer|custom>
      owns_goal_slices:
        - <goal/context area this agent owns>
      answers_questions_about:
        - <question categories this agent should answer or validate>
      required_sources:
        - <files, logs, scripts, dashboard sections, or artifacts>
      stale_after: <duration or event that requires refresh>
      current_status: <pending|ready|blocked|needs-human|complete>
```

Question routing rules:

- If the user asks a question whose answer depends on a goal slice owned by a logical agent, route the question to that agent or use that agent's latest dashboard entry. The leader may summarize and integrate, but must not invent the answer from general context.
- If no owner exists for the question, the leader first creates or assigns one, updates the ownership map, and then routes the question.
- If the owner's dashboard entry is stale, missing evidence, or conflicts with newer user evidence, refresh the owner before answering.
- The leader may answer directly for macro/orchestration questions when the central dashboard already contains enough current evidence. Examples: team coverage, current loop state, blockers, missing roles, dashboard contents, routing decisions, next synchronization point, and verified cross-agent summaries already present in the dashboard.
- The leader must route or refresh before answering when the question requires unpublished implementation facts, local runtime state, unresolved owner judgment, fresh test results, or details inside a goal slice whose dashboard entry is stale or incomplete.
- Every routed answer must update the dashboard with `answered_question`, `answer_owner`, `evidence`, and any `new_open_questions`.

## Central Dashboard Contract

Every Agentic Pipeline run must maintain a project-local central dashboard. This is the shared state surface between the leader, subagents, and future sessions.

Default paths:

```text
central_dashboard:
  web: .pipeline/dashboard/agentic-pipeline-dashboard.html
  json: .pipeline/dashboard/agentic-pipeline-dashboard.json
  markdown: .pipeline/dashboard/agentic-pipeline-dashboard.md
```

Dashboard minimum schema:

```text
dashboard:
  project_root: <absolute path>
  updated_at: <timestamp>
  leader_state:
    objective: <current mission>
    current_state: <loop state>
    stop_condition: <complete|blocked|unsafe|needs-human>
  coverage:
    required_roles: <roles needed>
    active_logical_agents: <agents assigned>
    missing_roles: <roles not yet covered>
  goal_ownership_map: <owners and slices>
  guidance_binding: <latest guidance binding or path>
  environment_preflight: <latest preflight or path>
  agent_updates:
    - logical_agent: <name>
      role: <role>
      status: <pending|ready|blocked|needs-human|complete>
      owns_goal_slices: <slices>
      summary: <latest concise state>
      evidence: <files, commands, logs, reports>
      open_questions: <questions owned by this agent>
      next_action: <next agent or leader action>
      updated_at: <timestamp>
  question_routes:
    - question: <user or leader question>
      owner: <logical agent>
      status: <routed|answered|blocked>
      evidence: <dashboard entry or agent result>
  decisions:
    - decision: <decision made>
      owner: <leader or logical agent>
      evidence: <supporting artifacts>
```

Dashboard synchronization rules:

- Create or update the dashboard before spawning implementation agents.
- Update the dashboard after every subagent result, blocker, human-action request, routed question answer, and verifier decision.
- Prefer the web dashboard for human reading. The HTML dashboard must render from the latest embedded snapshot and, when served over HTTP, dynamically refresh from `agentic-pipeline-dashboard.json`.
- Before answering a user question, consult the dashboard and route to the owning agent when the dashboard is missing or stale.
- Before final response, ensure the dashboard lists coverage, owners, current statuses, blockers, evidence, and retained artifacts.
- If the dashboard cannot be written, the loop state is `blocked` for implementation/deploy/test claims; the leader may still explain the blocker and the exact write failure.
- Prefer using `scripts/update_agent_dashboard.ps1` for dashboard writes. If the project needs richer behavior, evolve that script or create a project-local dashboard updater rather than relying on prose.
- Use `scripts/serve_agent_dashboard.ps1` only when an HTTP view is useful. It defaults to `127.0.0.1`; use an explicit LAN host only when remote/mobile viewing is intended and acceptable for the project.

## Subagent Spawning In Devin

Devin exposes subagents through the `run_subagent` tool and the `read_subagent` tool. Map the pipeline roles as follows:

- Read-only roles (`explore`, `planner`, `architect`, `code-reviewer`, `verifier`): spawn with `profile: "subagent_explore"` or with the matching custom profile under `.devin/agents/<role>/AGENT.md` when present.
- Write roles (`executor`, `test-engineer`, `scriptification-engineer`, `writer`): spawn with `profile: "subagent_general"` (or `"swe-fast"` for fast edits) or with the matching custom profile under `.devin/agents/<role>/AGENT.md` when present.
- Always run independent slices with `is_background: true`. Use `run_subagent` with `is_background: false` (foreground) only when the next leader action strictly depends on that specific result and no other non-overlapping work exists.
- To continue a completed/cancelled subagent with follow-up instructions, use `run_subagent` with the `resume` field set to the prior `agent_id` instead of spawning a new run.
- To collect a finished background subagent, use `read_subagent` with `block: true` (when you need the result before continuing) or `block: false` (non-blocking poll). Do not poll in a loop; continue other work and let the completion notification arrive.

## Workflow

1. Establish the mission ledger.
   - Write the current goal in one paragraph.
   - Define success criteria for a standardized project pipeline: stages, role ownership, local rules, local skills, validation commands, and review gates.
   - Define the initial loop state, allowed state transitions, evidence required per transition, and retention rule for successful iterations.
   - Identify irreversible or external-production boundaries.
   - Define the initial `goal_ownership_map` and central dashboard path.

2. Capture repeatable project evidence.
   - Run the audit script bundled with this skill before assigning implementation work. Locate it relative to this `SKILL.md` (it lives at `scripts/audit_project_surfaces.ps1` inside this skill directory). On Windows PowerShell run:
     ```powershell
     & (Get-Item -Path $PSScriptRoot\..\scripts\audit_project_surfaces.ps1).FullName -ProjectRoot '<project-root>'
     ```
     On any OS with `pwsh` available run:
     ```bash
     pwsh -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>/scripts/audit_project_surfaces.ps1" -ProjectRoot '<project-root>'
     ```
     If the skill directory location is unknown, find it with a glob for `**/agentic-pipeline/SKILL.md` and derive the `scripts` sibling directory.
   - Use the report to identify existing `AGENTS.md`, `CLAUDE.md`, `.codex/agents`, `.agents/skills`, `.devin/skills`, `.devin/agents`, `.codex/skills`, `rules`, scripts, tests, package/build commands, loop artifacts, and retained context.
   - Treat the active project root and folder-local guidance as authoritative over assumptions.
   - If the evidence surface is too weak for repeated use, create a script/checker first instead of continuing with one-off reasoning.

3. Bind guidance and preflight before delegation.
   - Produce the `guidance_binding` object from exact project files and skill paths.
   - Produce or run the `environment_preflight` object for the current task branch.
   - If no project preflight exists but machine state can affect correctness, create a project-local preflight script/check first.
   - Mark unavailable or failed preflight checks as `blocked`, `unsafe`, or `needs-human`; do not downgrade them to warnings.
   - Initialize or update the central dashboard with the guidance binding, preflight status, and goal ownership map.

4. Define the loop before delegation.
   - State current state, target state, allowed transitions, validation signal, failure states, and durable learning target.
   - Decide what artifact should improve if this loop succeeds or fails: script, fixture, local guidance, project skill, fixed agent, or team definition.
   - If this cannot be stated concretely, route to `planner` or `architect` before implementation subagents.

5. Spawn discovery and planning subagents.
   - First map existing project agents and skills. Reuse matching fixed agents before creating any new role.
   - `explore`: map current project guidance, agents, skills, scripts, and test commands.
   - `planner`: propose a stage-by-stage research/development pipeline with artifacts and gates.
   - `architect`: define ownership boundaries between global guidance, project guidance, agent prompts, folder rules, skills, scripts, and tests.
   - `scriptification-engineer` or `test-engineer`: turn recurring diagnostic or decision logic into scripts, JSON outputs, and regression fixtures.
   - `critic` or `code-reviewer`: challenge overreach, duplicated guidance, missing gates, and unsafe edits.
   - For each spawned agent, declare its owned goal slices and required dashboard update fields.

6. Integrate a pipeline plan.
   - Produce a concise plan with stages such as intake, evidence audit, architecture/risk plan, implementation, targeted tests, review, verifier signoff, and final report.
   - For each stage, specify the owner agent, required artifacts, entry criteria, exit criteria, and validation command or evidence.
   - For each state transition, specify the decision rule. A stage without a decision rule is not yet a reliable loop.
   - For every build/run/deploy/test state, specify the preflight command and blocked-state behavior.
   - Define fixed logical agents for the pipeline, for example `<project>-explorer`, `<project>-planner`, `<project>-architect`, `<project>-executor`, `<project>-test-engineer`, and `<project>-verifier`.
   - Prefer project-local `.agents/skills/<role-workflow>` or `.devin/skills/<role-workflow>` for reusable role workflows and project-local guidance files for durable rules.
   - Prefer script-local or skill-local regression fixtures for successful visual/log/runtime classifications so the loop can learn from practice.

7. Spawn implementation subagents.
   - `executor`: make bounded project-local edits to agent definitions, folder rules, skills, scripts, or guidance.
   - `test-engineer`: add or refine repeatable checks for the pipeline and guidance discovery where practical.
   - `writer`: tighten guidance text without expanding scope.
   - `scriptification-engineer`: build or harden decision software for recurring checks; do not leave repeated decisions as prose-only instructions.
   - If the needed fixed logical agent does not exist yet, create or update the project-level agent/skill definition (under `.devin/agents/<role>/AGENT.md` or `.agents/skills/<role-workflow>/SKILL.md`) as a pipeline artifact before relying on repeated temporary handoffs.
   - Assign non-overlapping files when possible. If two agents need the same file, serialize edits through the leader.
   - Include the guidance binding, preflight status, allowed actions, forbidden actions, and required result schema in every handoff.
   - If the preflight status is not `pass`, implementation agents may only edit the retained pipeline artifacts that fix the missing check or document the blocked state.

8. Supervise background subagents without blocking.
   - Spawn subagents with `is_background: true` and immediately continue with ready leader work instead of waiting by default.
   - Call `read_subagent` only at synchronization points: plan integration, shared-file merge, review gate, verifier gate, or when no other meaningful non-overlapping work exists.
   - When a subagent completion notification arrives, call `read_subagent` to read the result payload before making claims about that work.
   - Update the central dashboard immediately after integrating any subagent payload.
   - Use bounded waits with a clear timeout. If a subagent is slow, record it as pending and continue any safe branch that does not require that result.
   - Do not ask the user to wait for child-agent internals. Surface only actionable human requests, blockers, or checkpoint summaries.

9. Verify and review.
   - Run the smallest validation that proves each claim: syntax checks, project tests, lint/typecheck, script dry runs, or exact-string checks.
   - Spawn `code-reviewer` for changed guidance/skill files when the change is broad.
   - Spawn `verifier` to confirm that the final pipeline is complete, non-duplicative, project-scoped, has evidence, and rejects action without guidance/preflight evidence.
   - Run at least one loop dry run or replay against a known scenario when the pipeline includes a new script, state transition, or classifier.

10. Finalize.
   - Report changed files, the standardized pipeline, validation evidence, and remaining risks.
   - Report the final loop state and what was retained for future runs: skill, script, fixture, artifact, project rule, team role, or memory note.
   - Do not mark completion if the leader had to implement the substantive work directly because spawning was unavailable.

## Practice Retention

The pipeline should grow through use.

- Retain successful loops as project skills under `.agents/skills/<workflow>` or `.devin/skills/<workflow>`.
- Retain deterministic checks as scripts under the owning skill's `scripts/` folder or the project's `scripts/` folder.
- Retain examples, fixtures, and known failure cases near the script or skill that uses them.
- Retain operator-facing state reports under project-local evidence folders (for example `.pipeline/artifacts`, `.pipeline/context`) when they help future runs.
- Use a durability ladder rather than creating global sprawl: one-off artifact -> script/check -> local guidance -> project skill -> fixed agent/team definition -> user-level/global skill only when explicitly requested.
- Do not retain noise. A retained artifact should answer a future decision, reproduce a failure, or validate a transition.
- When a loop fails, record the smallest useful correction: missing state, missing evidence, bad decision rule, wrong capture point, weak script, unsafe transition, or unclear ownership.
- When user correction reveals that an agent ignored environment reality or project guidance, update the owning project skill with a new preflight check, decision rule, or fixture. Do not merely add prose reminding agents to be careful.
- Successful and failed lessons must include enough replay data for a future agent to classify the condition without guessing: command, observed output, expected output, state transition, and retained artifact path.
- After a loop succeeds repeatedly, promote it from prompt/process into a skill, script, test, or fixed team role.

## Background Subagent Supervision

Default posture: spawn in background, continue in foreground, synchronize only when needed.

- Treat every spawned `agent_id` as a run instance, not the agent identity. Track both `logical_agent` and `agent_id`.
- Reuse a still-open run instance with `run_subagent` + `resume` when the follow-up belongs to the same logical agent and context; spawn a new run only for a new independent slice, a completed/closed run, or a different fixed logical agent.
- Track each subagent as `pending`, `ready`, `blocked`, `needs-human`, or `complete`.
- Maintain a leader-side ready queue of work that does not depend on pending subagent output.
- Prefer multiple short synchronization checkpoints over one long blocking wait.
- Harvest completed subagent results asynchronously: on completion notification, call `read_subagent` and capture status, summary, changed paths, validation evidence, unresolved blockers, and any `human_action_required` payload.
- If a subagent reports partial results, integrate the usable part and keep the rest pending.
- If all useful branches are blocked on subagents, report the current blockers and the next synchronization condition instead of pretending progress is happening.
- Close completed agents after their result is integrated so finished children do not accumulate.

## Fixed Agent Strategy

Use stable logical agents as the project operating model.

- Before spawning, inspect existing project agents under `.devin/agents`, `.agents/agents`, `.codex/agents`, project skills under `.agents/skills` / `.devin/skills`, and documented role ownership in `AGENTS.md` or folder-local guidance.
- Prefer fixed project-specific logical agents for recurring responsibilities. Names should be stable and domain-specific rather than generic one-off descriptions.
- Do not create a new temporary logical role merely because a task wording changed. Route the work to the closest existing fixed agent and pass the specific task as that run's assignment.
- If a durable responsibility is missing, add or update the project-level agent definition (`.devin/agents/<role>/AGENT.md`) as part of standardizing the pipeline, then use that fixed role in future runs.
- Spawned `agent_id` values are acceptable as background execution instances, but final reports and ledgers should name the fixed logical agent first and the run ID second.

Required subagent completion shape (the leader should require this from every spawned subagent):

```text
subagent_result:
  status: complete|blocked|failed
  role: <profile name>
  logical_agent: <stable project/user agent name>
  run_id: <spawned background agent_id>
  owns_goal_slices: <goal/context areas owned by this agent>
  guidance_followed: <authoritative files/rules used>
  preflight_used: <environment_preflight id/path/status>
  dashboard_update: <summary/open questions/next action to write to central dashboard>
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

Use this staffing pattern unless the project shape clearly needs less. Each role has a matching custom subagent profile under `.devin/agents/<role>/AGENT.md` when installed; otherwise fall back to the built-in `subagent_explore` (read-only) or `subagent_general` / `swe-fast` (write) profiles.

- `explore`: current-state inventory and local convention mapping. (read-only)
- `planner`: stage design, dependencies, and sequencing. (read-only)
- `architect`: file ownership, guidance hierarchy, and extensibility boundaries. (read-only)
- `scriptification-engineer`: repeated diagnostics, classifiers, decision trees, and loop automation. (write)
- `executor`: scoped edits. (write)
- `test-engineer`: repeatable validation and regression checks. (write)
- `code-reviewer`: risk and duplication review. (read-only)
- `verifier`: final evidence and acceptance check. (read-only)
- `writer`: tighten guidance text without expanding scope. (write)

## Project Artifacts To Standardize

Review and improve only the artifacts relevant to the active project:

- `AGENTS.md` or `AGENTS.override.md` for top-level project guidance.
- `CLAUDE.md` when the project already uses it for local reminders.
- Folder-local rule files under `rules`, `.cursor/rules`, `.windsurf/rules`, or equivalent directories when present.
- Native role prompts under `.devin/agents`, `.agents/agents`, or `.codex/agents`; user-level agents only when the request is explicitly user-level.
- Project skills under `.agents/skills/<skill-name>` or `.devin/skills/<skill-name>`.
- Reusable scripts under project `scripts` or skill-local `scripts`.
- Loop/context/artifact surfaces under `.pipeline/context`, `.pipeline/artifacts`, or equivalent project-local state only when they are intentionally part of the workflow.
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

The audit script is bundled at `scripts/audit_project_surfaces.ps1` inside this skill directory (next to this `SKILL.md`). Run it from the project root you want to standardize.

By default the script only reads and emits JSON to stdout. Use `-OutputPath <project-root-relative-or-contained-report.json>` when a durable artifact is useful; the script refuses output outside the project root and refuses overwrite unless `-Force` is supplied.

## Completion Criteria

The workflow is complete only when:

- The project has a named R&D pipeline with owners, artifacts, entry/exit criteria, and validation evidence.
- Project agents, local rules, and project skills are present or deliberately skipped with reasons.
- Any human-cooperation requests from subagents were resolved, explicitly deferred, or reported as remaining blockers.
- Validation ran and the output was read.
- A final verifier pass agrees that the standardized pipeline is usable by future Devin sessions.
