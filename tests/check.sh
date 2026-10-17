#!/usr/bin/env bash
# t6: deterministic repo invariant + installed-copy drift gate. No model calls.
set -euo pipefail
fail=0; nodrift=0
if [ "${1:-}" = "--no-drift" ]; then nodrift=1; fi
bad(){ echo "FAIL: $1"; fail=1; }
for f in crew/skills/crew-*/SKILL.md; do
  grep -q '^name:' "$f" || bad "$f: missing name:"
  grep -q '^description:' "$f" || bad "$f: missing description:"
done
grep -q '^disable-model-invocation: true' crew/skills/crew-brainstorm/SKILL.md || bad "crew-brainstorm: missing disable-model-invocation: true"
grep -q '^disable-model-invocation: true' crew/skills/crew-plan/SKILL.md || bad "crew-plan: missing disable-model-invocation: true"
grep -q '^disable-model-invocation:' crew/skills/crew-orchestrate/SKILL.md && bad "crew-orchestrate: must not carry disable-model-invocation"
for f in crew/agents/*.md; do
  grep -q '^model:' "$f" || bad "$f: missing model:"
  grep -q '^thinking:' "$f" || bad "$f: missing thinking:"
done
grep -q 'verify:' crew/skills/crew-plan/SKILL.md || bad "crew-plan: template missing verify:"
grep -q 'live:' crew/skills/crew-plan/SKILL.md || bad "crew-plan: template missing live:"
if [ "$nodrift" -eq 0 ]; then
  while IFS= read -r f; do
    i="${f#crew/}"; i="${i/extension\//extensions/}"
    if [ ! -f "$HOME/.pi/agent/$i" ]; then bad "drift: missing ~/.pi/agent/$i"
    elif ! cmp -s "$f" "$HOME/.pi/agent/$i"; then bad "drift: differs ~/.pi/agent/$i"; fi
  done < <(find crew/agents crew/skills/crew-* crew/prompts crew/extension/crew.ts -type f)
fi
if [ "$fail" -eq 0 ]; then echo "check: all pass"; fi
exit "$fail"
