#!/usr/bin/env bash
# t6 smoke: model calls, opt-in. Runs against installed copies — sync ~/.pi/agent/ first.
set -euo pipefail
fail=0
d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
cd "$d"
run(){ timeout 300 pi -p --no-session "$1"; }
printf '#!/bin/sh\necho hello\n' > demo.sh
chmod +x demo.sh
if run "/skill:crew-plan add a --dry-run flag to demo.sh; acceptance: demo.sh --dry-run prints the actions it would take and exits 0 without side effects; out of scope: anything else; write the plan now." >/dev/null 2>&1 \
  && [ -f .crew/spec.md ] && [ -f .crew/tickets.md ] \
  && grep -q 'live:' .crew/tickets.md && grep -q 'verify:' .crew/tickets.md; then
  echo "PASS: plan scratch run"
else
  echo "FAIL: plan scratch run"; fail=1
fi
out=$(run "answer ONLY from your current skill catalog whether skills named crew-brainstorm and crew-orchestrate are available, in the exact form brainstorm=<yes|no> orchestrate=<yes|no>" 2>/dev/null || true)
if echo "$out" | grep -q 'brainstorm=no orchestrate=yes'; then
  echo "PASS: catalog probe"
else
  echo "FAIL: catalog probe (got: $out)"; fail=1
fi
exit "$fail"
