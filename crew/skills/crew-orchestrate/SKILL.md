---
name: crew-orchestrate
description: Orchestrate background specialist dispatch — ledger, parallel waves, reconcile on terminal results, retry/escalate, review gate. Use when executing a plan or when the user says "go", "dispatch", "orchestrate".
---

# crew orchestrate

Complete the goal through background specialists. The main session is the orchestrator: it plans, dispatches, verifies, and reconciles — it does not do specialist work inline that a specialist can do.

Roles (custom agents, dispatched via the Agent tool): `scout` (recon/verify), `sage` (reason/debug), `smith` (build), `lens` (vision).

## Ledger

Keep a checkbox ledger as your working state (terse lines only — compaction-safe):

```
- [ ] t1 migrate config loader to zod (smith) — done — evidence: 14 tests pass, see commit abc
- [ ] t2 map all config call sites (scout) — running
- [ ] t3 review migration (sage) — pending, needs t1
```

Tasks come from `/skill:crew-plan` or are cut from the user's ask: 2–5 minutes each, dependency-ordered, with acceptance criteria.

## Wave loop

1. **Dispatch**: take every ready task (deps done) and launch its agent **in one message** so they run concurrently in the background. Brief = task + acceptance criteria + "report evidence: file paths and verbatim command output".
2. **Reconcile**: act only on terminal results. Verify before marking done — a claim without evidence is not done; spot-check load-bearing claims with `scout`. Update the ledger.
3. **Retry/escalate**: failure → retry once with the failure output appended to the brief. Second failure → escalate to `sage` to root-cause it and amend the brief, then one final attempt. Third failure → mark `blocked`, surface to the user with all evidence.
4. Continue waves until the ledger is complete or something is blocked.
5. **Review gate**: before declaring done, force-load `/skill:crew-review` and review the full diff against the plan. Critical findings become new ledger tasks; rerun the loop.

## Rules

- Thinking levels are pinned per agent in `agents/*.md` frontmatter (scout low, smith xhigh, sage max, lens low). Dispatch without a `thinking` override; deviate only deliberately, and never raise a level to fix a bad answer — fix the brief.
- Attempt cap per task: **3** (first + retry + post-escalation). Never more.
- Max 4 agents in flight; if dispatch is rejected for concurrency, launch in waves of 2.
- Never poll or re-launch a task that is still running; the ledger says what is in flight.
- Images → `lens`. Hard debugging/design → `sage`. Recon/docs/verification sweeps → `scout`. Implementation → `smith`.
- Ambiguous brief or blocked task → stop and ask the user. Do not invent requirements.
- Final report: ledger with evidence per task, review verdict, anything blocked.
