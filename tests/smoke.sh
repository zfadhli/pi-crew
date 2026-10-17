#!/usr/bin/env bash
# t15 smoke: model calls, opt-in. Runs against installed copies — sync ~/.pi/agent/ first.
set -euo pipefail
fail=0
here=$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)
repo=$(dirname "$here")
if ! bash "$repo/tests/check.sh"; then
  echo "FAIL: drift+invariant gate"; exit 1
fi
d=$(mktemp -d); trap 'rm -rf "$d"' EXIT
cd "$d"
run(){ timeout 300 pi -p --no-session "$1"; }
printf '#!/bin/sh\necho hello\n' > demo.sh
chmod +x demo.sh
if run "/skill:crew-plan add a --dry-run flag to demo.sh; acceptance: demo.sh --dry-run prints the actions it would take and exits 0 without side effects; out of scope: anything else; write the plan now." >/dev/null 2>&1 \
  && [ -f .crew/spec.md ] && [ -f .crew/tickets.md ] \
  && grep -q '^- \[ \] t' .crew/tickets.md; then
  bad=0
  while IFS= read -r line; do
    case "$line" in *verify:*live:*|*live:*verify:*) ;; *) echo "FAIL: ticket line missing verify:/live:: $line"; fail=1; bad=1;; esac
  done < <(grep '^- \[ \] t' .crew/tickets.md || true)
  if [ "$bad" -eq 0 ]; then echo "PASS: plan scratch run"; fi
else
  echo "FAIL: plan scratch run"; fail=1
fi
out=$(run "answer ONLY from your current skill catalog whether skills named crew-brainstorm, crew-plan and crew-orchestrate are available, in the exact form crew-brainstorm=<yes|no> crew-plan=<yes|no> crew-orchestrate=<yes|no>. A skill named plan may exist and must not be confused with crew-plan; answer only about the exact crew- names." 2>/dev/null || true)
if echo "$out" | grep -q 'crew-brainstorm=no crew-plan=no crew-orchestrate=yes'; then
  echo "PASS: catalog probe"
else
  echo "FAIL: catalog probe (got: $out)"; fail=1
fi
exit "$fail"
