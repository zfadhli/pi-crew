---
name: crew-plan
description: Cut an approved design into an execution ledger — 2–5 minute tasks with file paths, dependencies, and per-task verification. Use when planning implementation after brainstorming, or when the user says "plan".
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

The ledger, ready for `/go`:

```
- [ ] t1 <what> → <paths> — verify: <cmd> — (smith) [parallel-safe: yes/no, needs: ...]
- [ ] t2 ...
```

Ask the user to confirm before dispatch. Plan quality bar: an enthusiastic junior with no context, no judgement, and an aversion to testing could not misread it.
