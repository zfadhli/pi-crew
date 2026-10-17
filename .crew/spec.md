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
