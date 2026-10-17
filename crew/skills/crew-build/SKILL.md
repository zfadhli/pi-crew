---
name: crew-build
description: Strict TDD implementation in small slices — failing test first, watch it fail, minimal code, watch it pass, commit. Use when implementing a well-scoped task or the user says "build".
---

# crew build

Implement to brief, test-first. No code exists before its test.

## Per slice (one task from the ledger)

0. Pre-slice gate: read the slice's ticket in `.crew/tickets.md` and restate its interface deltas — exported signatures, argument/return changes, module-boundary changes. If the slice changes an interface and the ticket does not state the delta, stop and report; never invent the interface. (Dispatched builders run without session context, so the ticket is the only source of truth.)
1. Restate the slice's acceptance criteria from the brief. Ambiguous → stop and report; don't infer.
2. **Red**: write the failing test. Run it. Confirm the failure message is the one you expect.
3. **Green**: minimal code to pass. Run the test. No extra structure, no speculative abstractions.
4. Delete any code written before its test.
5. **Commit** with the task id; rerun the surrounding test suite for regressions.
6. **Live**: run the ticket's `live:` check on the real surface and capture its evidence. An inconclusive or wrong-surface check is not a pass — report it as such instead of claiming green. `live: n/a` is an already-recorded gap; do not invent a live check to fill it.

## Rules

- Match the repo's conventions; reuse what exists (stdlib, already-installed deps, nearby helpers) before adding anything.
- Root causes, not symptoms — see `/skill:crew-debug` when a test resists.
- Non-trivial logic leaves ONE runnable check: the smallest thing that fails if the logic breaks.
- Deliberate simplifications get a `// chisle: <when to outgrow this>` style comment.

## Output

Files touched, test commands with verbatim pass/fail lines, live-check evidence (or the recorded `n/a`), any deviation from the brief (expected: none).
