#!/usr/bin/env bash
# VM runner: invokes a routine prompt headless via Claude Code.
# Usage: bin/run-routine.sh <pre-market|market-open|midday|daily-summary|verify-readonly>
# Alerts (Telegram via notify.sh) carry the actual failure reason, not just "check logs".
set -uo pipefail
source "$HOME/.trading-agent.secrets"          # ANTHROPIC_API_KEY
cd "$HOME/trading-agent" || exit 1
routine="$1"                                    # pre-market|market-open|midday|daily-summary
mkdir -p "$HOME/logs"
log="$HOME/logs/${routine}-$(date +%F).log"
out="$(mktemp)"; trap 'rm -f "$out"' EXIT
warn() { bash scripts/notify.sh "WARN: $routine on VM $(date -Is): $*" || true; }

echo "=== $(date -Is) start $routine ($(claude --version 2>&1 | head -1)) ===" >> "$log"

# Pre-flight: a stuck rebase/merge or wrong branch silently blocks every commit+push.
gitdir="$(git rev-parse --git-dir)"
[[ -d "$gitdir/rebase-merge" || -d "$gitdir/rebase-apply" || -f "$gitdir/MERGE_HEAD" ]] &&
  warn "repo stuck mid-rebase/merge — commits will fail. Fix: cd ~/trading-agent && git status"
branch="$(git branch --show-current)"
[[ "$branch" != "main" ]] && warn "repo on branch '${branch:-detached HEAD}', not main"

claude -p "$(cat "routines/${routine}.md")" \
      --permission-mode bypassPermissions \
      --max-turns 40 \
      --output-format json > "$out" 2>&1
rc=$?
cat "$out" >> "$log"

# Non-zero exit OR a JSON result flagged is_error (API auth/credit, max-turns, etc).
if [[ $rc -ne 0 ]] || grep -q '"is_error":true' "$out"; then
  reason="$(jq -r '[(.subtype // "" | select(. != "success")), (.result // "")] | join(" ")' "$out" 2>/dev/null)"
  [[ -z "${reason// /}" ]] && reason="$(tail -c 400 "$out")"
  warn "run failed (exit $rc): ${reason:0:400}"
fi

# Ran but left commits unpushed (push auth / rejected push).
ahead="$(git rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)"
[[ "$ahead" -gt 0 ]] && warn "$ahead local commit(s) NOT pushed to origin/main. Fix: cd ~/trading-agent && git push origin main"

echo "=== $(date -Is) end $routine (exit $rc) ===" >> "$log"
