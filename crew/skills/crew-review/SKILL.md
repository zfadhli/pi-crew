---
name: crew-review
description: Adversarial review of a diff against the plan — severity-ranked findings, critical findings block, evidence over claims. Use before declaring work done or when the user says "review".
---

# crew review

Review the branch/diff against the plan's acceptance criteria. Your job is to find what's wrong, not to approve.

## Procedure

1. Get the diff and the plan/ledger. Review only what changed plus its callers.
2. Check in this order: (a) meets acceptance criteria? (b) tests actually exercise the new logic (not just the happy path), (c) root-cause quality — any symptom patches?, (d) conventions match the repo, (e) no leaked secrets/debug debris.
3. Verify claims yourself: run the tests named in the task briefs; don't trust reported output.
4. Report severity-ranked:

```
CRITICAL (blocks): <what breaks / why> — file:line
MAJOR: ...
MINOR: ...
```

## Rules

- Every finding cites `file:line` and the concrete failure it causes. No style nitpicks the repo's own formatter wouldn't catch.
- No CRITICAL findings = pass. CRITICAL → back to the crew-orchestrate ledger as new tasks.
- Under 400 words.
