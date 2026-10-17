# pi-workflow / crew — repo notes for agents

- `crew/` is the source of truth; `~/.pi/agent/{agents,skills,prompts,extensions}` are installed copies. After editing `crew/`, copy to the install target and diff-verify every file (see DESIGN.md install block); `/reload` in a live session.
- Editing prose skill files (`SKILL.md`): apply ONE edit per call with unique context anchors. Multi-edit `oldText` collisions stall dispatched writers (observed: v1.1 t2).
- `.crew/` artifacts (`spec.md`, `tickets.md`, `GLOSSARY.md`, `adr/`, `research/`) are main-session-writes only; dispatched subagents report evidence and never write them.
- Verify workflow changes: after editing `crew/` copy to the install target and diff-verify every file, then run `bash tests/check.sh` (expect zero drift) and `bash tests/smoke.sh`; scratch smoke asserts `.crew/spec.md` + `.crew/tickets.md` exist and the skill catalog hides `crew-brainstorm`/`crew-plan`.
