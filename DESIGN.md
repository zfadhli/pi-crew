# crew — superpowers-lite + background orchestration for Pi

Pi port of the arena-synthesized design (base: prompt-first "crew"; graft: deterministic image relay, now deferred — see Deviations). Shape unchanged from the OpenCode version; surfaces swapped to Pi-native ones, which made the design *smaller* (no TS dispatch engine, no config loader). Re-grounded against `docs/extensions.md`, `docs/skills.md`, `docs/prompt-templates.md`, `docs/models.md`, `examples/extensions/subagent/`.

## Usage (caller's view)

### Install — copy 4 resource dirs + 1 extension

```bash
C=~/path/to/crew
cp -r $C/agents/*.md    ~/.pi/agent/agents/      # role → model pins
mkdir -p ~/.pi/agent/skills && cp -r $C/skills/crew-* ~/.pi/agent/skills/
cp -r $C/prompts/*.md   ~/.pi/agent/prompts/     # /brainstorm /plan /go
mkdir -p ~/.pi/agent/extensions && cp $C/extension/crew.ts ~/.pi/agent/extensions/
/opencode-go provider: add to ~/.pi/agent/models.json (see README) — or edit `model:` lines in the agents to match installed providers
```

### First session

```
/model opencode-go/gpt-6-luna               # main session = orchestrator
/thinking high                             # orchestrator level
> /brainstorm rate-limiting middleware    # forces crew-brainstorm skill
> /plan                                   # forces crew-plan skill → spec.md + tickets.md (2–5 min task ledger)
> /go migrate the config loader to zod    # forces crew-orchestrate:
    ledger → dispatch @scout/@sage as ONE message (background, parallel)
    → reconcile each terminal result → @smith builds → review gate → report
```

Bootstrap (extension injects one tagged system-prompt section, hidden from the transcript):

```
crew active
roles: @scout research/verify · @sage debug/reason · @smith build · @lens vision
thinking: scout low · smith max · sage max · lens low (orchestrator: high)
protocol: force-load /skill:crew-orchestrate before dispatching; ledger -> dispatch background tasks in parallel -> reconcile each terminal result; claims need evidence; images -> @lens (you may not see them).
state: .crew/tickets.md — open checkboxes → resume before dispatching
artifacts: .crew/{spec.md,tickets.md,GLOSSARY.md} + adr/ + research/ — main session writes only
```

### Call sites

1. **Orchestrate**: `/go migrate the config loader to zod` — crew orchestrates via native Agent tool.
2. **Delegate**: `@scout find every fetch() call site handling 429` — background, result returns.
3. **Vision**: screenshot in → main session delegates describing to `@lens` (deepseek-v4.1-flash), never claims to see it.
4. **Change a role's model**: edit one `model:` line in `~/.pi/agent/agents/<role>.md`, `/reload`.

## Problem

Pack superpowers' skills+commands+bootstrap and omo-slim's background dispatch/reconcile into one package, simpler than both, tuned to opencode-go model tiers as designed (cheap recon, mid reasoning, cheapest-output build, vision) — since collapsed to one model for three roles, see v1.2.1. Non-obvious in Pi: most machinery the OpenCode shape needed already exists natively — Agent tool with custom `.md` agents (background, parallel, per-agent `model:` frontmatter), description-routed skills, prompt templates. So the plugin shrinks to *resources + a bootstrap extension*; TS is glue, not orchestration.

## Shape

### Role → model (sole location: agents/*.md frontmatter)

| agent file | model | thinking | rationale |
|---|---|---|---|
| main session (no file) | opencode-go/gpt-6-luna | high | full ladder → max, vision, 1M ctx; 4x cheaper output than deepseek-v4-pro |
| scout.md | opencode-go/deepseek-v4.1-flash | low | recon: short evidence reports, level dials *down* to keep thinking tokens negligible; one model for three roles → the level separates, not the model |
| sage.md | opencode-go/deepseek-v4.1-flash | max | reasoning: measured equal-or-better than glm-5.3-flash on the review replay and 4–5× slower — fine for a background gate (A1) |
| smith.md | opencode-go/deepseek-v4.1-flash | max | build: output-heavy TDD work, `max` because the review result is the only measurement we have; this tier is the unmeasured one (A1) |
| lens.md | opencode-go/deepseek-v4.1-flash | low | vision-capable at scout-tier price; rarely-used role |

Assumptions: A1 **sage tier measured, smith tier not** — the v1.2 Spec-review brief was replayed at pinned commit `d993f2e`, 3 runs of deepseek-v4.1-flash at `max` vs 1 recorded glm-5.3-flash run: deepseek matched 6–7 of glm's 7 findings per run (7/7, 7/7, 6/7) and added 4 distinct true findings, at 220–279s and 61–88k tokens vs 56s and 37k, accepted for a background review gate; **the smith (build) tier remains unmeasured**. A2 **verified**: opencode-go provider authenticated in-env (`https://opencode.ai/zen/go/v1`); catalog has all lineup IDs. A3 **verified empirically**: two `scout` dispatches ran concurrently, both resolving the frontmatter model pin. Thinking-ladder constraint: mimo/qwen/minimax/kimi expose **no** levels — excluded from every role. Levels are pinned per agent via `thinking:` frontmatter (pi-subagents reads it; dispatch-time `thinking` param overrides only when deliberate).

### Module map

```
crew/
├── README.md              # install, models.json template, verification
├── extension/crew.ts      # ~50 LOC: before_agent_start section + /crew status command
├── agents/                # → ~/.pi/agent/agents/
│   ├── scout.md  sage.md  smith.md  lens.md    # frontmatter: name, description, tools, model
├── skills/                # → ~/.pi/agent/skills/  (crew- prefix avoids collisions)
│   ├── crew-orchestrate/SKILL.md   # ledger, background dispatch, reconcile, ≤1 retry → escalate, attempt cap 3
│   ├── crew-brainstorm/ crew-plan/ crew-scout/ crew-debug/ crew-build/ crew-review/ crew-observe/
└── prompts/               # → ~/.pi/agent/prompts/
    ├── brainstorm.md  plan.md  go.md           # thin: "/skill:crew-x $ARGUMENTS"
```

### Data flow

```
startup   extension loads (no side effects — lifecycle rule)
run start before_agent_start → systemPromptOptions.sections["crew"] = bootstrap (once per run, structured section)
user      /go → prompt template expands → /skill:crew-orchestrate forced load
session   all orchestration in crew-orchestrate.md, zero TS:
            ledger → Agent tool: launch [scout, sage] in ONE message (background)
            → terminal results return → verify (evidence or spot-check)
            → ledger update → next wave → ≤1 retry then escalate (sage) → attempt cap 3 → review gate
images    prompt rule: delegate to @lens (code relay deferred — see Deviations; unchanged in v1.1)
```

### Invariants

- Exactly 8 skills, 4 subagent roles, 1 orchestrator (main session), 1 delegation syntax (Agent tool / `@role`), 3 commands, 1 bootstrap section.
- No model name in shipped protocol text (crew/skills/, crew/prompts/, crew/extension/, bootstrap string) except crew/agents/*.md frontmatter (+ models.json catalog); docs and .crew/ artifacts may discuss models.
- No protocol text anywhere except crew-orchestrate.md + bootstrap string.
- Extension stateless: factory registers handlers only; no timers/processes.

### Deliberately NOT doing

No TS scheduler/task state (native Agent tool owns dispatch). No preset/extends machinery (frontmatter is the config; `/reload` picks edits up). No council/consensus, no MCP, no git-worktree automation, no image sniffing in code (v1). No runtime model switcher.

### Interface depth

Public surface: run 3 commands, or say `@role task`; edit one frontmatter line to re-team. Behind it: role routing, model pins, forced skill loading, structured bootstrap. One operation per intent.

## Deviations from the OpenCode sketch (surfaced, not absorbed silently)

1. **crew.json + preset.ts dropped** — Pi pins models in agent frontmatter; loader code deleted. Smaller surface, same one-routing-table invariant (4 files, 1 line each vs 1 file).
2. **Deterministic per-role prompt injection → description-routed skills + forced `/skill:` load from commands** — Pi has no per-agent prompt assembly; determinism preserved where it matters (workflow entry points force the skill).
3. **Image relay graft deferred** — Pi exposes `images` on `before_agent_start` but context images live elsewhere; a full strip→relay→caption path is real code for a failure mode we haven't observed. v1 = prompt rule + `@lens`; add relay when a text-only orchestrator actually wastes turns.
4. **Dispatch = native Agent tool**, not a bundled subagent extension — A3 confirmed natively; the 1038-LOC example extension would duplicate it.

## Synthesis decision (carried over)

Base: crew (arena 28/27 over code-first Conductor). Grafts kept: attempt cap (prose line). Graft re-evaluated on port: image relay → deferred (deviation 3). Rejected: TS engine (premise disproven — and Pi's native Agent tool makes it doubly redundant). Platform port triggered re-ground per Phase A; shape survived with a strictly smaller surface, so arena re-run skipped (convergence clause — both candidates would map to the same Pi-native surfaces; documented here as the synthesis note).

## Tradeoffs accepted

- Skills auto-route by description (may load late/miss) → commands force-load at workflow entry; `/skill:crew-*` always available.
- Model pins spread across 4 files → no single preset switch; edit + `/reload` instead.
- No code image relay → text-only orchestrator may waste one turn before delegating to @lens.
- One model for three roles (scout/sage/smith) → less tier diversity, one shared failure mode; defended by the measured sage-tier probe (A1: 7/7, 7/7, 6/7 baseline plus 4 new true findings), though smith-tier capability is still unmeasured → one-line frontmatter fallback per role if a build task disappoints.
- Durable `.crew/tickets.md` ledger → zero task-state infra; resume on open checkboxes, terse lines mitigate compaction loss.

## Alternatives considered

**TS orchestration engine (Conductor; omo-slim core)** — lost on interface depth (scheduler API surface, workflow changes = code + release) and now doubly redundant: Pi's Agent tool already provides background parallel dispatch with per-agent model pins.

**Superpowers-style ~20 auto-activating skills** — activation heuristics leak complexity; crew keeps 8 with forced loads at entry points.

## Open questions and risks

- Does opencode-go expose an OpenAI-compatible endpoint Pi can mount in `models.json` (A2)? Endpoint/key needed from you.
- Is deepseek-v4.1-flash at `max` good enough for implementation work (smith tier)? Unmeasured — the probe covered review, not build.
- 4 concurrent dispatches vs opencode-go rate limits — if throttled, crew-orchestrate.md gets a wave-size rule (prose, not code).
- Per-project crews (`.pi/agents/` project scope) later?

## Next implementation step

`extension/crew.ts` (bootstrap section + `/crew`) and the 4 agent files, verified by `pi --extension ... -p "/crew"` before authoring skill text.

## Implementation plan

| # | Step | Verify (one check) |
|---|---|---|
| 1 | agents/*.md + extension/crew.ts | `pi --extension crew/extension/crew.ts` → `/crew` lists 4 roles + models |
| 2 | bootstrap section in before_agent_start | print-mode ask echoes "crew active" line |
| 3 | crew-orchestrate skill (ledger, dispatch, reconcile, retry/escalate, cap 3) | `/go` on a 2-task sample: both children run, ledger reconciles |
| 4 | remaining 7 skills + 3 prompt templates | `/brainstorm`, `/plan` produce expected artifacts |
| 5 | README + models.json template; catalog check | model IDs resolve — **done: A2 verified, catalog IDs corrected** |
| 6 | A3 probe: dispatch 2 scouts in one message | concurrent execution observed (expected native) |

## v1.1 — artifact graft

Additive graft of Matt Pocock's artifact discipline onto the 8 skills; no install mechanics changed, skill count stays 8.

**Artifacts.** Durable per-project state in `.crew/` at the target repo root: `spec.md` (destination — problem, acceptance criteria, out of scope), `tickets.md` (journey + live ledger: checkboxes, status, dependency edges, parallel-safe, assignee, per-ticket brief/verify, interface deltas), `GLOSSARY.md` (pure vocabulary), `.crew/adr/NNN-<slug>.md` (only when hard-to-reverse + surprising + real tradeoff — most sessions produce zero), `research/*.md` (cited notes for load-bearing recon).

**Invariant.** Only the MAIN session (orchestrator) writes `.crew/`; dispatched subagents report, never write. Rationale: Pocock's documented bug where skills that write files silently no-op inside orchestration layers — so children return evidence in terminal results and the orchestrator persists.

**Skill deltas.** brainstorm writes glossary inline + gated ADRs; plan emits `spec.md` + `tickets.md` and requires user-confirmed interface deltas; orchestrate uses `tickets.md` as ledger (resume on open checkboxes), briefs via context pointers, review gate dispatches TWO children in one message (sage = Spec axis, scout = Standards axis), closes with a retro editing the PROJECT's `AGENTS.md` (most severe first, diff shown; never crew's own skills/agents); review runs the two-axis dispatch; build gates on ticket interface deltas before the first red test (interface change unstated in ticket → stop, never invent); scout marks keep-worthy findings `[persist]` and stays read-only (orchestrator writes `research/*.md`).

**Invocation.** brainstorm and plan carry `disable-model-invocation: true` (user gesture only); orchestrate intentionally stays model-invocable (bootstrap and `/go` rely on it).

**Model change.** lens pinned to `opencode-go/deepseek-v4.1-flash`. Image-relay deferral (deviation 3) unchanged in v1.1.

**Deliberately not building:** tracker/gh integration, worktrees/integration branch, wayfinder/handoff/prototype, new skills, self-editing crew skills, setup command.

**Probe result (v1.2 review gate).** sage-tier capability probe run: v1.2 Spec-review brief replayed at `d993f2e`, 3 runs deepseek-v4.1-flash @ max vs 1 recorded glm-5.3-flash run. deepseek matched 6–7 of glm's 7 findings per run (7/7, 7/7, 6/7), and added 4 true findings glm missed (gap-recording has no terminal ledger status — still open at `b7462be`; smoke's file-scoped `live:` grep; DESIGN model-name invariant unscoped; t10 ticket dropped `live:`), with 1 replay-artifact false positive (drift gate red because installed copies were post-fixup). Wall 220–279s vs 56s, tokens 61–88k vs 37k. deepseek ≥ glm → sage swapped to `opencode-go/deepseek-v4.1-flash`; the 4–5× latency is accepted for a background review gate.

## v1.2 — verification + enforcement graft

- Ticket line gains `live: <cmd | n/a: reason>`; crew-build runs it after green; inconclusive/wrong-surface is not a pass.
- crew-review executes `verify:` + `live:` at a pinned commit SHA, verdict PASS/ISSUES/BLOCKED; gap ≠ pass.
- Orchestrate: verification briefs pin SHA + method; gap → respawn once → record; retries are fresh consolidated dispatches, never resumed chains.
- Retro enforcement ladder (architecture → lint/CI naming the fix → test → prose last), class counts at 2, prove each check fails on the recorded mistake, rule→enforcement table in the project's AGENTS.md; crew's own skills still never edited.
- Harness: `tests/check.sh` (invariants + installed-copy drift) and `tests/smoke.sh` (scratch plan run + catalog probe).
- Deferred: generated verify recipes; `.crew/verify.md` only when the drive recipe is non-obvious. Invariants unchanged: 8 skills, 4 agents, 3 prompts, 1 extension.

## v1.2.1 — one model, thinking carries the role split

- **Swap.** scout, sage, and smith all pin `opencode-go/deepseek-v4.1-flash`; the thinking level carries the role split (`low` for scout, `max` for sage and smith). Main session stays `opencode-go/gpt-6-luna` at `high`; lens stays `deepseek-v4.1-flash` at `low`. The per-tier lineup is retired — one model for recon, reasoning, and build, one failure mode to track.
- **Why.** Measured, not assumed. Replaying the v1.2 Spec-review brief at `d993f2e` gave deepseek 7/7, 7/7, 6/7 of glm's findings plus 4 distinct true findings, for 220–279s and 61–88k tokens against 56s and 37k. Equal-or-better findings at 4–5× latency is a good trade for a background review gate (A1).
- **Still open.** The build (smith) tier has no probe behind it; `max` there is an inference from the review result, not a measurement. Tracked under Open questions.
- **Docs.** `crew/README.md`'s role table and this file's role table + assumptions now match `crew/agents/*.md` frontmatter. Model names stay confined to DESIGN.md and README.md; shipped protocol text (skills, prompts, extension, bootstrap) remains model-free.
- **Evidence.** `.crew/research/sage-model-probe.md` — scorecard, new true findings, false-positive adjudication.
