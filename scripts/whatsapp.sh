#!/usr/bin/env bash
# Notification wrapper. Sends a WhatsApp message via Twilio.
# Usage: bash scripts/whatsapp.sh "<message>"
# If any Twilio var is unset, appends to a local fallback file and exits 0.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
FALLBACK="$ROOT/NOTIFICATIONS.md"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; }

if [[ $# -gt 0 ]]; then msg="$*"; else msg="$(cat)"; fi
[[ -z "${msg// /}" ]] && { echo 'usage: whatsapp.sh "<message>"' >&2; exit 1; }
stamp="$(date '+%Y-%m-%d %H:%M %Z')"

if [[ -z "${TWILIO_ACCOUNT_SID:-}" || -z "${TWILIO_AUTH_TOKEN:-}" \
   || -z "${TWILIO_WHATSAPP_FROM:-}" || -z "${WHATSAPP_TO:-}" ]]; then
  printf "\n---\n## %s (fallback — Twilio not configured)\n%s\n" "$stamp" "$msg" >> "$FALLBACK"
  echo "[whatsapp fallback] appended to NOTIFICATIONS.md"; echo "$msg"; exit 0
fi

curl -fsS -X POST "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" \
  --data-urlencode "From=$TWILIO_WHATSAPP_FROM" \
  --data-urlencode "To=$WHATSAPP_TO" \
  --data-urlencode "Body=$msg" \
  -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
echo
