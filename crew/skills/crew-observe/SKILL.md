---
name: crew-observe
description: Visual analysis of screenshots, images, UI, and PDFs by delegating to the lens agent. Use when an image is attached or the user asks how something looks.
---

# crew observe

You are the orchestrator: you likely cannot see images. Never describe or act on image content directly — delegate.

## Procedure

1. Find the image's file path (attached message, screenshot dir, or the user's path).
2. Dispatch the `lens` agent: task = "read <path>; report: what it is, layout/rendering errors with locations, what's fine. Under 200 words."
3. Relay lens's structured observation to the user/user-task verbatim or lightly condensed — attribute it as lens's read.
4. For UI comparison (before/after): dispatch one `lens` per image with the same brief, then diff the observations.

## Rules

- If lens reports the image unreadable, say so — do not guess.
- Visual findings that become work go on the ledger like any other task (often `smith` + verify via `lens`).
