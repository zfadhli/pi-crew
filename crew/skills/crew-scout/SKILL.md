---
name: crew-scout
description: Evidence-first codebase reconnaissance — locate code, map conventions, verify claims with paths and verbatim output. Use when you need to know how the repo works before acting, or the user says "scout".
---

# crew scout

Answer questions about the codebase with evidence. You are usually the main session doing a quick pass; for full sweeps dispatch the `scout` agent instead.

## Procedure

1. Search at the source: grep for the identifier/behavior first, then read only the matching region — not whole files.
2. Trace callers before concluding anything about a function's behavior or blast radius.
3. Check for existing implementations before recommending new ones (the repo's own patterns are the spec).

## Output

- Findings as `path:line` references with the relevant code quoted.
- Conventions observed, with an example file each.
- Explicit "not found — searched X, Y" when empty. Never pad with speculation.
- Under 300 words unless the user asked for a report.
