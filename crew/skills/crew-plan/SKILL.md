---
name: crew-plan
description: Cut an approved design into an execution ledger — 2–5 minute tasks with file paths, dependencies, and per-task verification. Use when planning implementation after brainstorming, or when the user says "plan".
disable-model-invocation: true
---

# crew plan

Turn an approved design (or the user's ask) into an execution plan the crew-orchestrate skill can run.

## Procedure

1. Confirm the design/requirements are settled. If open questions remain, run `/skill:crew-brainstorm` first — do not plan on sand.
2. Map the terrain: force-load `/skill:crew-scout` briefly if you don't already know the relevant files and conventions.
3. Cut tasks. Each task:
   - **2–5 minutes** of specialist work — if bigger, split it.
   - Exact file paths to create or touch.
   - Complete-enough instruction that a fresh specialist with no session context succeeds (they see only the brief).
   - One verification command or test that proves it done.
4. Order by dependency; mark parallel-safe tasks explicitly.
5. Every plan gets at least one review task (`sage` vs the diff and this plan) at the end.

## Output

Write two durable files (only the MAIN session writes `.crew/` files; dispatched subagents report, never write), ready for `/go`:

- `.crew/spec.md` — the destination: problem statement, acceptance criteria (user-visible behaviors), and explicitly what is out of scope. Written from the approved design or the user's ask.
- `.crew/tickets.md` — the journey AND the live ledger: one line per task, checkbox plus status (`pending | running | done | blocked`), with exact file paths, dependency edges (`needs: tN`), parallel-safe yes/no, one verification command, and the assignee role. Each per-ticket brief must be complete enough for a fresh specialist with no session context. Tasks stay 2–5 minutes each; order by dependency.

```
- [ ] t1 <what> → <paths> — status: pending — verify: <cmd> — (smith) [parallel-safe: yes/no, needs: ...]
- [ ] t2 ...
```

Any ticket that changes an interface (exported signature, function arguments, module boundary) must state the interface delta explicitly.

Ask the user to confirm the plan and deltas before dispatch. Plan quality bar: an enthusiastic junior with no context, no judgement, and an aversion to testing could not misread it.
