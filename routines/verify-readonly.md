You are running a READ-ONLY verification for the trading agent. This proves the
unattended chain works BEFORE any routine is allowed to trade. Do NOT place, modify,
or cancel any order under any circumstances. Ultra-concise.

DATE=$(date +%Y-%m-%d).

ENV VARS: TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID should be set in .env (Perplexity optional).
notify.sh sources .env itself, so this echo may show MISSING even when sending works. Verify:
  for v in TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID; do
    [[ -n "${!v:-}" ]] && echo "$v: set" || echo "$v: MISSING"; done

STEP 1 — ROBINHOOD REACHABILITY: call get_accounts. Confirm account 604803171 exists
         and agentic_allowed=true. If not reachable -> report FAIL and stop.
STEP 2 — Call get_portfolio(604803171) and get_equity_positions(604803171).
STEP 3 — Send ONE Telegram message via: bash scripts/notify.sh "VERIFY $DATE
         Acct 604803171 reachable. Equity \$X | Cash \$X | BP \$X | Positions: <n>"
         (If Telegram unset, the script falls back to NOTIFICATIONS.md — that still counts as a pass
         for MCP auth; note the fallback.)
STEP 4 — Report clearly: did Robinhood MCP authenticate in this unattended run? YES/NO.
         Did the Telegram/fallback send succeed? YES/NO.

Do NOT commit anything. Do NOT place/cancel orders. This is a read-only gate.
