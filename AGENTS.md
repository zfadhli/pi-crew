# pi-workflow / crew — repo notes for agents

- `crew/` is the source of truth; `~/.pi/agent/{agents,skills,prompts,extensions}` are installed copies. After editing `crew/`, copy to the install target and diff-verify every file (see DESIGN.md install block); `/reload` in a live session.
- Editing prose skill files (`SKILL.md`): apply ONE edit per call with unique context anchors. Multi-edit `oldText` collisions stall dispatched writers (observed: v1.1 t2).
- `.crew/` artifacts (`spec.md`, `tickets.md`, `GLOSSARY.md`, `adr/`, `research/`) are main-session-writes only; dispatched subagents report evidence and never write them.
- Verify workflow changes: after editing `crew/` copy to the install target and diff-verify every file, then run `bash tests/check.sh` (expect zero drift) and `bash tests/smoke.sh`; scratch smoke asserts `.crew/spec.md` + `.crew/tickets.md` exist and the skill catalog hides `crew-brainstorm`/`crew-plan`.

## Rule → enforcement

| Rule | Enforced by |
|---|---|
| Installed copies match `crew/` source | `tests/check.sh` drift gate |
| Ticket template keeps `verify: <cmd> — live: <cmd \| n/a: reason>` | `tests/check.sh` fixed-string check |
| No model slug in shipped protocol text (`crew/skills/`, `crew/prompts/`, `crew/extension/`) | `tests/check.sh` slug check |
| Done ledger lines are ticked — never `[ ]` with `status: done` | `tests/check.sh` ledger guard |
| Catalog hides `crew-brainstorm`/`crew-plan`, exposes `crew-orchestrate` | `tests/smoke.sh` catalog probe |
| Generated tickets carry `verify:` + `live:` | `tests/smoke.sh` per-ticket assertion |
