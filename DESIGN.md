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
> /plan                                   # forces crew-plan skill → 2–5 min task ledger
> /go migrate the config loader to zod    # forces crew-orchestrate:
    ledger → dispatch @scout/@sage as ONE message (background, parallel)
    → reconcile each terminal result → @smith builds → review gate → report
```

Bootstrap (extension injects one tagged system-prompt section, hidden from the transcript):

```
crew active
roles: @scout research/verify · @sage debug/reason · @smith build · @lens vision
protocol: /skill:crew-orchestrate before dispatching; ledger → dispatch →
reconcile on terminal results; claims need evidence; images → @lens (crew may not see them).
```

### Call sites

1. **Orchestrate**: `/go migrate the config loader to zod` — crew orchestrates via native Agent tool.
2. **Delegate**: `@scout find every fetch() call site handling 429` — background, result returns.
3. **Vision**: screenshot in → main session delegates describing to `@lens` (mimo-v2.5), never claims to see it.
4. **Change a role's model**: edit one `model:` line in `~/.pi/agent/agents/<role>.md`, `/reload`.

## Problem

Pack superpowers' skills+commands+bootstrap and omo-slim's background dispatch/reconcile into one package, simpler than both, tuned to opencode-go tiers (flash=cheap scout, v4-pro=reasoning, muse-spark=coding, mimo-v2.5=vision). Non-obvious in Pi: most machinery the OpenCode shape needed already exists natively — Agent tool with custom `.md` agents (background, parallel, per-agent `model:` frontmatter), description-routed skills, prompt templates. So the plugin shrinks to *resources + a bootstrap extension*; TS is glue, not orchestration.

## Shape

### Role → model (sole location: agents/*.md frontmatter)

| agent file | model | thinking | rationale |
|---|---|---|---|
| main session (no file) | opencode-go/gpt-6-luna | high | full ladder → max, vision, 1M ctx; 4x cheaper output than deepseek-v4-pro |
| scout.md | opencode-go/gpt-6-luna | low | dials *down* — short evidence reports, negligible thinking tokens |
| sage.md | opencode-go/glm-5.3-flash | max | `max`-capable at 0.5 out (deepseek-v4-pro: 1.98); deepseek-v4.1-flash is the same-price fallback |
| smith.md | opencode-go/muse-spark-1.3-contributor | xhigh | output-heavy build role on the cheapest output rate (0.2); xhigh is its ceiling |
| lens.md | opencode-go/space-bunny-free | low | free, vision-capable; rarely-used role |

Assumptions: A1 capability tiers are unmeasured — a same-task head-to-head probe (scout difficulty) tied gpt-6-luna and deepseek-v4.1-flash (3/3 correct each); harder sage-tier signal still open. A2 **verified**: opencode-go provider authenticated in-env (`https://opencode.ai/zen/go/v1`); catalog has all lineup IDs (bare `muse-spark` absent → `muse-spark-1.3-contributor`). A3 **verified empirically**: two `scout` dispatches ran concurrently, both resolving the frontmatter model pin. Thinking-ladder constraint: mimo/qwen/minimax/kimi expose **no** levels — excluded from every role. Levels are pinned per agent via `thinking:` frontmatter (pi-subagents reads it; dispatch-time `thinking` param overrides only when deliberate).

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
images    prompt rule: delegate to @lens (code relay deferred — see Deviations)
```

### Invariants

- Exactly 8 skills, 4 subagent roles, 1 orchestrator (main session), 1 delegation syntax (Agent tool / `@role`), 3 commands, 1 bootstrap section.
- No model name anywhere except agents/*.md frontmatter (+ models.json catalog).
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
- Unverified A1/A2 (muse-spark capability, opencode-go endpoint) → one-line frontmatter/endpoint fallbacks.
- In-context ledger → zero task-state infra; terse checkbox format mitigates compaction loss.

## Alternatives considered

**TS orchestration engine (Conductor; omo-slim core)** — lost on interface depth (scheduler API surface, workflow changes = code + release) and now doubly redundant: Pi's Agent tool already provides background parallel dispatch with per-agent model pins.

**Superpowers-style ~20 auto-activating skills** — activation heuristics leak complexity; crew keeps 8 with forced loads at entry points.

## Open questions and risks

- Does opencode-go expose an OpenAI-compatible endpoint Pi can mount in `models.json` (A2)? Endpoint/key needed from you.
- Orchestrator at scale: gpt-6-luna vs muse-spark for large multi-report reconciles?
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
| 5 | README + models.json template; catalog check | model IDs resolve — **done: A2 verified, muse-spark ID corrected** |
| 6 | A3 probe: dispatch 2 scouts in one message | concurrent execution observed (expected native) |
