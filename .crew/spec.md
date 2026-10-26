# crew v1.2 — verification + enforcement graft

## Problem

pstack research (2026-10-17) found three crew gaps: the review gate verifies by reading, not running (no live check, no pinned SHA, no gap rule); the retro lands in prose only (no enforcement ladder, no proof a new check catches the past mistake); crew's own skills change untested (one manual smoke; drift already observed in v1.1's lens pin).

## Acceptance criteria

1. Ticket line gains `live: <cmd | n/a: reason>`; crew-build runs it after green; inconclusive or wrong-surface is not a pass.
2. crew-review Standards axis executes `verify:` + `live:` at the reviewed commit SHA and reports verbatim output; verdict PASS/ISSUES/BLOCKED; a result missing its required evidence is a gap, not a pass.
3. Verification briefs pin exact SHA + method; missing evidence → respawn once → record gap; retries are fresh dispatches with consolidated briefs, never interrupt-chained resumes.
4. Retro fixes at the highest level that works: architecture → lint/CI check whose error names the fix → test → prose last; a class counts at 2 occurrences; each added check is proven to fail on the recorded past mistake; rule→enforcement table lives in the project's AGENTS.md; crew's own skills/agents are still never edited.
5. crew-brainstorm settles observable forks by experiment, not questions; crew-debug attacks a premise shared by 2+ failed fixes.
6. `tests/check.sh` (no model calls) asserts frontmatter/flags invariants and installed-copy drift; `tests/smoke.sh` (model calls) proves a scratch plan run produces spec+tickets with `live:`, and the catalog hides crew-brainstorm/crew-plan while exposing crew-orchestrate.
7. DESIGN.md gains a v1.2 section; crew/README.md verification section and repo AGENTS.md sync rule reference the harness.

## Interface delta

`.crew/tickets.md` line format becomes:

```text
- [ ] tN <what> → <paths> — status: pending — verify: <cmd> — live: <cmd | n/a: reason> — (role) [parallel-safe: yes/no, needs: ...]
```

Consumed by crew-orchestrate, crew-build, crew-review.

## Out of scope

Generated verify recipes/skills — `.crew/verify.md` only when a ticket's drive recipe is non-obvious. No arena/swarm panels, no playbook router, no new skills, no autonomy change, no PR/forge automation.

## v1.2.1 (patch batch)

Model strategy collapsed to one model for the three non-main roles (`opencode-go/deepseek-v4.1-flash`); thinking level now carries the role split (scout/lens low, sage/smith max). Docs must match shipped frontmatter. Two v1.2 gaps close: a recorded gap has no terminal ledger status, and the v1.2 review-gate line dropped the `live:` field the plan protocol says is never dropped.

### Acceptance criteria

1. Ledger vocabulary is `pending | running | done | blocked | gap` in both crew-plan and crew-orchestrate; the wave loop exits on complete, blocked, or gap; resume never re-dispatches a `gap` line automatically.
2. Every `.crew/tickets.md` line, including v1.2 history, carries `verify:` and `live:`.
3. crew/README.md and DESIGN.md model tables match `crew/agents/*.md` frontmatter; no `muse-spark-1.3-contributor` or `glm-5.3-flash` pin survives (a measurement baseline may still name the split-out model; what must not survive is a pin — frontmatter or a claim that a role runs on it); DESIGN records the measured deepseek-v4.1-flash sage-tier probe and marks the smith tier unmeasured.
4. `bash tests/check.sh` zero drift and `bash tests/smoke.sh` green after installed copies are synced.

### Interface delta

Ledger status vocabulary gains `gap`. `.crew/tickets.md` line shape is unchanged.

### Out of scope

Parallel-serialization graft (awaits separate "go"), the 3-builder worktree experiment, and any new skill, agent, prompt, or extension.
