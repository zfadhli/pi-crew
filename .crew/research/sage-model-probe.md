# sage model probe — deepseek-v4.1-flash vs glm-5.3-flash

Date: 2026-10-17. Brief: v1.2 Spec-axis review replay of the recorded glm run (`0a55d71f`, reviewed commit `d993f2e`). deepseek runs used a sage clone (`sage-ds`: identical body/tools/thinking/max_turns/skills, only `model:` differ). Worktree pinned at `d993f2e`; the recorded glm run was taken at the same tree.

## Scorecard

| | glm (recorded, 1 run) | ds run 1 | ds run 2 | ds run 3 |
|---|---|---|---|---|
| baseline findings hit (of glm's 7) | — | 7/7 | 7/7 | 6/7 |
| new true findings | — | 2 | 3 | 2 |
| false positives | 0 | 0 | 0 | 1 artifact + 1 borderline |
| severity | 4 MAJOR, 3 MINOR | 5 MAJOR, 4 MINOR | 6 MAJOR, 4 MINOR | 1 CRIT, 3 MAJOR, 5 MINOR |
| wall | 55.9s | 250.2s | 278.9s | 220.3s |
| tool uses | 10 | 28 | 19 | 18 |
| tokens | 36.6k | 88.3k | 83.6k | 60.9k |

## New true findings (not in glm's 7)

- gap ledger path has no terminal status (`crew-orchestrate:31` vs `crew-plan:29` vocabulary; loop exits only on complete/blocked) — found 3/3; **still open at `b7462be`**.
- `tests/smoke.sh:12` greps `live:`/`verify:` file-scoped (one ticket carrying both passes all) + smoke never gated on `check.sh` — found 2/3; fixed by t15.
- DESIGN model-name invariant unscoped (`DESIGN.md:97` vs model slugs at `:170`) — run 2; fixed by t17.
- `.crew/tickets.md:14` t10 drops `live:` — run 3; **still open at `b7462be`** (t10 has no `live:` field).

Baseline 7 reproduced verbatim in all runs: smoke probe omits crew-plan (t15), check.sh drops `skills:[]` (t14), t9 open+done ledger (t14 guard), review SHA recorded post-dispatch (t16), reconcile never names verify:/live: (t16), check.sh bare substring `live:` (t14), verify.md unexecutable (t16) — each fixed by the named fixup, independently confirming the findings were real.

## FP adjudication

- run 3 CRITICAL "check.sh exits 1 at d993f2e": replay artifact — `~/.pi/agent` held b7462be copies, so drift gate red by construction; the commit's own gate passed at its SHA. Not counted.
- run 3 MINOR "orchestrate:35 'only the project's AGENTS.md' contradicts lint/CI fixes": weak prose misread; not counted.

## Decision

deepseek ≥ glm on findings (equal baseline coverage + 4 distinct new true, corroborated by later fixups) → sage swapped to `opencode-go/deepseek-v4.1-flash` in `crew/agents/sage.md` + installed copy. Latency 4–5× and tokens ~2× accepted for a background review gate. Watch: run 1 used 28 of `max_turns: 30` — raise the cap if truncation ever shows.
