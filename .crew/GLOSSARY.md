# GLOSSARY

- **live check** — running the changed behavior on its real surface (CLI, server, UI) and observing the result. A test suite alone is not a live check; inconclusive or wrong-surface is not a pass.
- **verify recipe** — per-project instructions for driving the app to a live check: launch, drive, evidence, cleanup. Optional `.crew/verify.md`, written only when the recipe is non-obvious.
- **gap** — a worker result missing the evidence its brief required. A gap is not a pass.
- **enforcement ladder** — retro ordering for a repeated mistake: architecture → lint/CI check whose error names the fix → test → prose last. Each added check must fail on the recorded past mistake.
- **attack the premise** — when two or more fixes sharing one premise fail the same gate, write the premise down and test it directly before attempting a third fix.
- **observable vs preference** — a fork answerable by running something is settled by experiment; only product or preference calls go to the human.
