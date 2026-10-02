---
name: crew-build
description: Strict TDD implementation in small slices — failing test first, watch it fail, minimal code, watch it pass, commit. Use when implementing a well-scoped task or the user says "build".
---

# crew build

Implement to brief, test-first. No code exists before its test.

## Per slice (one task from the ledger)

1. Restate the slice's acceptance criteria from the brief. Ambiguous → stop and report; don't infer.
2. **Red**: write the failing test. Run it. Confirm the failure message is the one you expect.
3. **Green**: minimal code to pass. Run the test. No extra structure, no speculative abstractions.
4. Delete any code written before its test.
5. **Commit** with the task id; rerun the surrounding test suite for regressions.

## Rules

- Match the repo's conventions; reuse what exists (stdlib, already-installed deps, nearby helpers) before adding anything.
- Root causes, not symptoms — see `/skill:crew-debug` when a test resists.
- Non-trivial logic leaves ONE runnable check: the smallest thing that fails if the logic breaks.
- Deliberate simplifications get a `// chisle: <when to outgrow this>` style comment.

## Output

Files touched, test commands with verbatim pass/fail lines, any deviation from the brief (expected: none).
