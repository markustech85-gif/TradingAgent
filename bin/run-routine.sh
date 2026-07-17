#!/usr/bin/env bash
# VM runner: invokes a routine prompt headless via Claude Code.
# Usage: bin/run-routine.sh <pre-market|market-open|midday|daily-summary|verify-readonly>
set -uo pipefail

routine="${1:-}"                                # pre-market|market-open|midday|daily-summary
if [[ -z "$routine" ]]; then
  echo "usage: bin/run-routine.sh <pre-market|market-open|midday|daily-summary|verify-readonly>" >&2
  exit 2
fi

# Secrets (ANTHROPIC_API_KEY). Missing file would only surface later as an opaque
# claude failure, so fail loud here and still alert if we can.
if [[ -f "$HOME/.trading-agent.secrets" ]]; then
  source "$HOME/.trading-agent.secrets"
else
  echo "FATAL: $HOME/.trading-agent.secrets not found" >&2
fi
cd "$HOME/trading-agent" || { echo "FATAL: cannot cd to $HOME/trading-agent" >&2; exit 1; }

mkdir -p "$HOME/logs"
log="$HOME/logs/${routine}-$(date +%F).log"

echo "=== $(date -Is) start $routine ===" >> "$log"
claude -p "$(cat "routines/${routine}.md")" \
      --permission-mode bypassPermissions \
      --max-turns 40 \
      --output-format json >> "$log" 2>&1
rc=$?
if [[ $rc -ne 0 ]]; then
  # Make the alert triageable from a phone: exit code + the tail of the log
  # (the error line / "max turns" / API message is almost always in the last lines).
  # notify.sh hard-caps the message at ~4000 chars, so an over-long tail is safe.
  ctx="$(tail -n 20 "$log" 2>/dev/null | tr -d '\r')"
  bash scripts/notify.sh "WARN: $routine run failed on VM (exit $rc) $(date -Is).
Note: whole-share resting stops still protect the book; software (fractional) stops are NOT checked on a failed scan.
--- last log lines ---
$ctx" || true
fi
echo "=== $(date -Is) end $routine (exit $rc) ===" >> "$log"
exit $rc
