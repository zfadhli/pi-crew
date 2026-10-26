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
  grep -q '^skills:' "$f" || bad "$f: missing skills:"
done
grep -Fq 'verify: <cmd> — live: <cmd | n/a: reason>' crew/skills/crew-plan/SKILL.md || bad "crew-plan: template missing verify/live shape"
if grep -rq 'opencode-go/' crew/skills/ crew/prompts/ crew/extension/; then bad "model slug outside crew/agents frontmatter"; fi
if [ -f .crew/tickets.md ] && grep -Eq '^- \[ \].*— status: done' .crew/tickets.md; then bad "tickets: open checkbox with status: done"; fi
if [ -f .crew/tickets.md ]; then
  while IFS= read -r line; do
    id="${line#*\] }"; id="${id%% *}"
    case "$line" in *verify:*) ;; *) bad "tickets: $id missing verify:" ;; esac
    case "$line" in *live:*) ;; *) bad "tickets: $id missing live:" ;; esac
  done < <(grep -E '^- \[' .crew/tickets.md)
  vocab=' pending running done blocked gap '
  while IFS= read -r w; do
    case "$vocab" in *" $w "*) ;; *) bad "tickets: status '$w' not one of pending|running|done|blocked|gap (fix the token)" ;; esac
  done < <(grep -o '— status: [A-Za-z]*' .crew/tickets.md | cut -d' ' -f3)
fi
for f in crew/skills/crew-plan/SKILL.md crew/skills/crew-orchestrate/SKILL.md; do
  grep -Fq 'pending | running | done | blocked | gap' "$f" || bad "$f: status vocabulary must read 'pending | running | done | blocked | gap'"
done
for f in crew/agents/*.md; do
  n=$(sed -n 's/^name: *//p' "$f" | head -1); t=$(sed -n 's/^thinking: *//p' "$f" | head -1)
  if [ -z "$n" ] || [ -z "$t" ]; then bad "$f: missing name:/thinking: pair"; continue; fi
  for d in crew/skills/crew-orchestrate/SKILL.md crew/extension/crew.ts; do
    grep -Fq "$n $t" "$d" || bad "$d: missing '$n $t' from crew/agents/$n.md frontmatter (state it as '$n $t')"
  done
done
if [ "$nodrift" -eq 0 ]; then
  while IFS= read -r f; do
    i="${f#crew/}"; i="${i/extension\//extensions/}"
    if [ ! -f "$HOME/.pi/agent/$i" ]; then bad "drift: missing ~/.pi/agent/$i"
    elif ! cmp -s "$f" "$HOME/.pi/agent/$i"; then bad "drift: differs ~/.pi/agent/$i"; fi
  done < <(find crew/agents crew/skills/crew-* crew/prompts crew/extension/crew.ts -type f)
fi
if [ "$fail" -eq 0 ]; then echo "check: all pass"; fi
exit "$fail"
