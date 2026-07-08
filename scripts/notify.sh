#!/usr/bin/env bash
# Notification wrapper. Sends a message to Telegram via the Bot API.
# Usage: bash scripts/notify.sh "<message>"        (or pipe the message on stdin)
# Requires TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID (from .env or the environment).
# If either is unset, appends to NOTIFICATIONS.md and exits 0 — never blocks a routine.
#
# Multi-agent: set NOTIFY_SOURCE to label the sender (e.g. "trading-agent",
# "deploy-bot") so several agents sharing one chat stay distinguishable.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
FALLBACK="$ROOT/NOTIFICATIONS.md"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; }

if [[ $# -gt 0 ]]; then msg="$*"; else msg="$(cat)"; fi
[[ -z "${msg// /}" ]] && { echo 'usage: notify.sh "<message>"' >&2; exit 1; }
stamp="$(date '+%Y-%m-%d %H:%M %Z')"

src="${NOTIFY_SOURCE:-trading-agent}"
body="[$src] $msg"
# Telegram hard-caps a message at 4096 chars; truncate defensively.
[[ ${#body} -gt 4000 ]] && body="${body:0:3990}…(truncated)"

if [[ -z "${TELEGRAM_BOT_TOKEN:-}" || -z "${TELEGRAM_CHAT_ID:-}" ]]; then
  printf "\n---\n## %s (fallback — Telegram not configured)\n%s\n" "$stamp" "$msg" >> "$FALLBACK"
  echo "[notify fallback] appended to NOTIFICATIONS.md"; echo "$msg"; exit 0
fi

curl -fsS -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${body}" \
  --data-urlencode "disable_web_page_preview=true" >/dev/null
echo "[notify] sent to Telegram chat ${TELEGRAM_CHAT_ID}"
