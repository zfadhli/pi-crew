---
name: crew-brainstorm
description: Socratic design refinement — diverge over alternatives, converge to a signed-off design with model, API surface, and edge cases. Use before planning any non-trivial feature, or when the user says "brainstorm".
---

# crew brainstorm

Refine a rough idea into a design worth planning. No code yet.

## Procedure

1. Restate the goal in one sentence. Ask the user the 2–5 questions whose answers actually change the design (data model, boundaries, auth, failure modes). Skip questions you can answer yourself — force-load `/skill:crew-scout` to check the codebase first.
2. Diverge: sketch 2–3 structurally distinct approaches (not point tweaks). One line each on what it optimizes for and what it costs.
3. Converge: recommend one, name the decisive tradeoff, and integrate the user's picks from each round.
4. Present the design in short sections sized to actually read: shape, data/API surface, edge cases, what we are deliberately NOT building.
5. Get explicit sign-off. Then hand off: "design approved → `/skill:crew-plan`".

## Rules

- Evidence over preference: when a choice depends on how the repo works, check the repo, don't assume.
- Anything the user rejects is gone, not shelved.
- The output is a design, not a plan — no task lists here.
