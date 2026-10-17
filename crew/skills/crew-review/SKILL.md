---
name: crew-review
description: Two-axis adversarial review of a diff against spec and standards — severity-ranked findings, critical findings block, evidence over claims. Use before declaring work done or when the user says "review".
---

# crew review

Two-axis adversarial review of the branch/diff. Your job is to find what's wrong, not to approve.

## Procedure

1. In ONE message, dispatch TWO agents. Name the reviewed commit SHA explicitly in BOTH reviewer briefs before dispatching. Reviewers report findings only — they never write files (only the MAIN session writes `.crew/` files; skills that write files silently no-op inside orchestration layers):
   - `sage` — Spec axis: does the diff faithfully implement `.crew/spec.md` and the ticket acceptance criteria in `.crew/tickets.md`? What was missed or misinterpreted?
   - `scout` — Standards axis: repo conventions (including the project's AGENTS.md), whether the tests actually exercise the new logic (not just the happy path), root-cause quality (no symptom patches), and leaked secrets/debug debris. Execute the ticket's `verify:` and `live:` checks at the reviewed commit SHA and report the verbatim output; a claim without executed evidence is a gap, not a pass.
2. Reconcile both reports in the main session: record the reviewed commit SHA, merge, dedupe, severity-rank. Verify claims yourself — run the tests named in the task briefs, don't trust reported output. Return a verdict: `PASS`, `ISSUES`, or `BLOCKED` (CRITICAL findings → ISSUES/block and become new tickets in `.crew/tickets.md`, written by the main session only). Report severity-ranked:

```
CRITICAL (blocks): <what breaks / why> — file:line
MAJOR: ...
MINOR: ...
```

3. Fallback: if `.crew/spec.md` does not exist (standalone review), review against the plan or conversation the user names instead.

## Rules

- Every finding cites `file:line` and the concrete failure it causes. No style nitpicks the repo's own formatter wouldn't catch.
- No CRITICAL findings = pass. CRITICAL findings block and become new tickets in `.crew/tickets.md` (written by the main session only).
- A gap is not a pass. A verdict is pinned to its SHA — new commits need a fresh verdict.
- Under 400 words.
