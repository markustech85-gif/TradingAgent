Local test version of the DAILY SUMMARY (uses local .env; no cloud env-var block, no commit/push).
US STOCKS & ETFs ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

STEP 1 — Read memory: tail of TRADE-LOG.md (yesterday's equity, open-position rows, `Cadence:` line);
         count today's trades + this week's opening trades (cap 4 wk1 else 3).
STEP 2 — Final state: get_portfolio; get_equity_positions; get_equity_orders (604803171).
STEP 3 — Compute Day P&L, Phase P&L vs $500, trades today/week, drawdown (kill-switch status).
STEP 4 — Append an EOD snapshot to memory/TRADE-LOG.md (Schema): portfolio, cash, day/phase P&L,
         position table [Ticker|Bucket|Shares|Entry|Close|Day Chg|Unrealized P&L|Stop|Protection],
         the `Book:` composition line + the `Cadence:` line, notes. Refresh the open-position rows.
STEP 5 — Send ONE Telegram recap via bash scripts/notify.sh (<= 15 lines).
(No commit — local test. In production the daily-summary commit is mandatory.)
