---
name: crew-debug
description: Systematic debugging — hypothesis, cheapest discriminating experiment, root cause with evidence before any fix. Use when something is broken, a test stays red, or the user says "debug".
---

# crew debug

Find the root cause before touching code. Symptom patches are failures.

## Procedure

1. **Reproduce** with the smallest command that fails. Capture the exact error output.
2. **Hypothesize**: 2–3 candidate causes ranked by likelihood. Pick the cheapest experiment that discriminates between them (a log line, a one-off assertion, reading one file).
3. **Experiment** until exactly one cause survives. The cause must explain ALL observed symptoms — if a symptom is unexplained, it's not root-caused yet.
4. **Fix** at the root: one guard in the shared function beats a guard in every caller. Grep every caller before editing.
5. **Verify**: rerun the original failing command, plus one check that the fix didn't break a sibling path.

## Output

Root cause (with the evidence that proved it), the fix, and the verbatim pass/fail output of the original repro. If stuck after 3 experiments, stop and report what's ruled out — do not start editing randomly.
