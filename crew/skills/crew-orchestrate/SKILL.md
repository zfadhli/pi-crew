---
name: crew-orchestrate
description: Orchestrate background specialist dispatch — ledger, parallel waves, reconcile on terminal results, retry/escalate, review gate. Use when executing a plan or when the user says "go", "dispatch", "orchestrate".
---

# crew orchestrate

Complete the goal through background specialists. The main session is the orchestrator: it plans, dispatches, verifies, and reconciles — it does not do specialist work inline that a specialist can do.

Roles (custom agents, dispatched via the Agent tool): `scout` (recon/verify), `sage` (reason/debug), `smith` (build), `lens` (vision).

Main-session-writes invariant: only the main session writes `.crew/` files; dispatched subagents (scout/sage/smith/lens) never write them. Subagents report evidence in their terminal result; the orchestrator persists artifacts (`.crew/tickets.md`, `.crew/spec.md`, `.crew/research/`).

## Ledger

The ledger lives in `.crew/tickets.md` — checkbox lines with status + evidence (terse lines only — compaction-safe):

```
- [x] t1 migrate config loader to zod (smith) — done — evidence: 14 tests pass, see commit abc
- [ ] t2 map all config call sites (scout) — running
- [ ] t3 review migration (sage) — pending, needs t1
```

Tasks come from `/skill:crew-plan` or are cut from the user's ask: 2–5 minutes each, dependency-ordered, with acceptance criteria.

On run start, reconcile first: if `.crew/tickets.md` exists with open checkboxes, read it, verify current statuses, and resume from it before dispatching anything new. New tasks (e.g. review CRITICALs) are appended to `.crew/tickets.md`.

## Wave loop

1. **Dispatch**: take every ready task (deps done) and launch its agent **in one message** so they run concurrently in the background. Briefs use context pointers instead of restating the spec inline — e.g. "read `.crew/tickets.md` ticket tN and `.crew/spec.md`; acceptance criteria are there" — plus task-specific acceptance and the evidence requirement ("report evidence: file paths and verbatim command output"). Verification-task briefs pin the exact commit SHA under review and the method: the command, the sample count, and the order to run it in. The orchestrator persists what children report; e.g. when a scout sweep is worth keeping, the orchestrator writes `.crew/research/<topic>.md` from the report.
2. **Reconcile**: act only on terminal results. Verify before marking done — a claim without evidence is not done; a result missing its required evidence is a gap, not a pass: respawn the task once with the gap named in the brief, then record the gap in the ledger if still unfilled. A dropout (agent lost without a result) does not fail the wave — proceed with N-1 and note it in the ledger. Spot-check load-bearing claims with `scout`. Update the ledger.
3. **Retry/escalate**: retries are fresh dispatches, never resumes of an interrupt-chained agent — resumed chains silently drop directives. Each retry carries a consolidated brief: original scope + failure output + known state. Failure → fresh retry once with the failure output appended to the brief. Second failure → escalate to `sage` to root-cause it and amend the brief, then one final fresh attempt. Third failure → mark `blocked`, surface to the user with all evidence.
4. Continue waves until the ledger is complete or something is blocked.
5. **Review gate**: before declaring done, force-load `/skill:crew-review` and dispatch TWO children in ONE message — `sage` for the Spec axis (does the diff faithfully implement `.crew/spec.md` and the ticket's acceptance criteria? anything missed?) and `scout` for the Standards axis (repo conventions including the project's AGENTS.md, whether tests actually exercise the new logic, root-cause quality / symptom patches, leaked secrets or debug debris). Reconcile both reports, severity-rank (CRITICAL blocks), and turn criticals into new ledger tickets appended to `.crew/tickets.md`; rerun the loop.
6. **Retro** (main session only, after the review gate): review the run's evidence — retries, escalations, blocked tasks, review findings, user corrections. Fix at the highest level that works: architecture → lint/CI check whose error names the fix → test → prose last. A mistake class counts once it has happened twice. Prove each new check fails on the recorded past mistake before landing it. Record fixes in a rule→enforcement table in the project's `AGENTS.md` (create it if absent), pairing each rule with what enforces it, most severe first, and show the diff in the final report. Do NOT edit crew's own skills or agents — only the project's `AGENTS.md`.

## Rules

- Thinking levels are pinned per agent in `agents/*.md` frontmatter (scout low, smith xhigh, sage max, lens low). Dispatch without a `thinking` override; deviate only deliberately, and never raise a level to fix a bad answer — fix the brief.
- Attempt cap per task: **3** (first + retry + post-escalation). Never more.
- Max 4 agents in flight; if dispatch is rejected for concurrency, launch in waves of 2.
- Never poll or re-launch a task that is still running; the ledger says what is in flight.
- Images → `lens`. Hard debugging/design → `sage`. Recon/docs/verification sweeps → `scout`. Implementation → `smith`.
- Ambiguous brief or blocked task → stop and ask the user. Observable forks (answerable by running something) are settled by experiment, not by asking; product/preference calls and unstated interface deltas still stop. Do not invent requirements.
- Final report: ledger with evidence per task, review verdict, anything blocked.
