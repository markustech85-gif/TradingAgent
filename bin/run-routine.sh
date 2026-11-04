#!/usr/bin/env bash
# VM runner: invokes a routine prompt headless via Claude Code.
# Usage: bin/run-routine.sh <pre-market|market-open|midday|daily-summary|verify-readonly>
set -uo pipefail
source "$HOME/.trading-agent.secrets"          # ANTHROPIC_API_KEY
cd "$HOME/trading-agent" || exit 1
routine="$1"                                    # pre-market|market-open|midday|daily-summary
mkdir -p "$HOME/logs"
log="$HOME/logs/${routine}-$(date +%F).log"

# PAUSE switch: a PAUSED file at the repo root skips the run entirely (no claude call, no spend).
if [[ -f PAUSED ]]; then
  echo "=== $(date -Is) SKIP $routine — PAUSED: $(head -1 PAUSED) ===" >> "$log"
  exit 0
fi

echo "=== $(date -Is) start $routine ===" >> "$log"
if ! claude -p "$(cat "routines/${routine}.md")" \
      --permission-mode bypassPermissions \
      --max-turns 40 \
      --output-format json >> "$log" 2>&1; then
  bash scripts/whatsapp.sh "WARN: $routine run failed on VM $(date -Is). Check logs." || true
fi
echo "=== $(date -Is) end $routine ===" >> "$log"
