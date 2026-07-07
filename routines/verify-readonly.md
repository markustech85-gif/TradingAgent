You are running a READ-ONLY verification for the trading agent. This proves the
unattended chain works BEFORE any routine is allowed to trade. Do NOT place, modify,
or cancel any order under any circumstances. Ultra-concise.

DATE=$(date +%Y-%m-%d).

ENV VARS: TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_WHATSAPP_FROM, WHATSAPP_TO
should be exported (Perplexity optional). Verify:
  for v in TWILIO_ACCOUNT_SID TWILIO_AUTH_TOKEN TWILIO_WHATSAPP_FROM WHATSAPP_TO; do
    [[ -n "${!v:-}" ]] && echo "$v: set" || echo "$v: MISSING"; done

STEP 1 — ROBINHOOD REACHABILITY: call get_accounts. Confirm account 604803171 exists
         and agentic_allowed=true. If not reachable -> report FAIL and stop.
STEP 2 — Call get_portfolio(604803171) and get_equity_positions(604803171).
STEP 3 — Send ONE WhatsApp message via: bash scripts/whatsapp.sh "VERIFY $DATE
         Acct 604803171 reachable. Equity \$X | Cash \$X | BP \$X | Positions: <n>"
         (If Twilio unset, the script falls back to NOTIFICATIONS.md — that still counts as a pass
         for MCP auth; note the fallback.)
STEP 4 — Report clearly: did Robinhood MCP authenticate in this unattended run? YES/NO.
         Did the WhatsApp/fallback send succeed? YES/NO.

Do NOT commit anything. Do NOT place/cancel orders. This is a read-only gate.
