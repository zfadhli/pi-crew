# crew

Superpowers-lite skills + omo-slim-style background orchestration for [Pi](https://github.com/earendil-works/pi), tuned for the opencode-go model lineup. One orchestrator (your session) + 4 background specialists:

| role | default model | thinking | duty |
|---|---|---|---|
| main session | `opencode-go/gpt-6-luna` (`/model`, `/thinking high`) | high | plan, dispatch, reconcile, review |
| `@scout` | `opencode-go/gpt-6-luna` | low | recon, docs, verification sweeps |
| `@sage` | `opencode-go/glm-5.3-flash` | max | hard debugging, design review, escalation |
| `@smith` | `opencode-go/muse-spark-1.3-contributor` | xhigh | implementation (strict TDD) |
| `@lens` | `opencode-go/space-bunny-free` | low | vision: screenshots, UI, PDFs |

Workflow: `/brainstorm` → `/plan` → `/go`. Dispatch runs background/parallel via Pi's native Agent tool; state lives in a checkbox ledger; claims need evidence.

## Install

```bash
C=/path/to/crew
mkdir -p ~/.pi/agent/{agents,prompts,extensions}
cp $C/agents/*.md       ~/.pi/agent/agents/
mkdir -p ~/.pi/agent/skills && cp -r $C/skills/crew-* ~/.pi/agent/skills/
cp $C/prompts/*.md      ~/.pi/agent/prompts/
cp $C/extension/crew.ts ~/.pi/agent/extensions/
```

Restart Pi (or `/reload`). Verify: `/crew` lists 4 roles + models + skills.

## Models

Model IDs above were verified against the `opencode-go` provider catalog in this environment (endpoint `https://opencode.ai/zen/go/v1`, authenticated via `opencode auth`-style login → `~/.pi/agent/auth.json`). Note: the bare `muse-spark` ID does not exist — catalog uses `muse-spark-1.3-contributor`.

If installing elsewhere, verify with `/model`; if `opencode-go` is absent, add a compatible endpoint to `~/.pi/agent/models.json`:

```json
{
  "providers": {
    "opencode-go": {
      "baseUrl": "<opencode-go OpenAI-compatible endpoint>",
      "api": "openai-completions",
      "apiKey": "$OPENCODE_GO_KEY",
      "models": [
        { "id": "gpt-6-luna" },
        { "id": "glm-5.3-flash" },
        { "id": "muse-spark-1.3-contributor" },
        { "id": "space-bunny-free", "input": ["text", "image"] },
        { "id": "mimo-v2.6-flash", "input": ["text", "image"] }
      ]
    }
  }
}
```

Endpoint/key unknown at time of writing — if opencode-go isn't OpenAI-compatible, edit the `model:` line in each `agents/*.md` to any installed provider instead (that file is the single routing table).

## Customize

- **Change a role's model or thinking level**: edit the `model:` / `thinking:` lines in `~/.pi/agent/agents/<role>.md` (orchestrator: `/model` + `/thinking`), then `/reload`. Levels are pinned per agent; a dispatch-time `thinking` param overrides only when deliberate.
- **Orchestration policy**: `skills/crew-orchestrate/SKILL.md` (ledger rules, attempt cap 3, escalation) — plain markdown, no code.
- **Dispatch limits**: if the provider throttles, add a wave-size rule to crew-orchestrate.

## Verify (smoke)

1. `pi --extension ./extension/crew.ts -p "quote the crew system prompt section"` → `CREW-OK crew active …`
2. `/crew` → 4 roles with models, 8 skills.
3. `/go <small goal>` → ledger forms, ≥2 agents dispatched in one message (concurrent), results reconciled with evidence.

## Layout

```
crew/
├── extension/crew.ts   # bootstrap section + /crew status (only TS)
├── agents/*.md         # role → model pins (the routing table)
├── skills/crew-*/      # 8 skills: orchestrate, plan, brainstorm, scout, debug, build, review, observe
├── prompts/            # /brainstorm /plan /go — thin wrappers forcing the skill
└── DESIGN.md lives in the repo root
```
