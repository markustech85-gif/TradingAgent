Local test version of the MARKET-OPEN workflow (uses local .env; no cloud env-var block,
no commit/push). US STOCKS & ETFs ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

Order tools may be denied (Phase 1). If so, log intended orders and place nothing.

STEP 1 — Read memory: STRATEGY.md; BUCKETS.md (bucket lookup + gate + cadence + Tier-1);
         TODAY's RESEARCH-LOG entry (if missing, do research first); tail of TRADE-LOG.md
         (open-position rows + `Cadence:` line).
STEP 2 — Reconcile: get_portfolio; get_equity_positions; get_equity_orders; get_equity_quotes
         for each planned ticker (never double-buy).
STEP 3 — KILL-SWITCH: if account <= $250, no buys; alert; stop. Else run the BUCKETS.md §3 gate on
         each planned order vs the post-fill book B': classify bucket (absorbed single → REJECT,
         "buy the ETF"); G1 instrument · G2 count≤4 · G3 cadence (this wk's opens+1 ≤ CAP 4/3) ·
         G4 sizing (≤$250 AND ≤ settled cash) · G5 caps (AI≤2, Outside≤1) · G6 diversify (≥2 held →
         ≥1 non-AI leg) · G7 Energy on track · G8 de-dup (QQQ↔SMH) · G9 catalyst logged · G10 off-list
         Outside needs §5 Tier-1. First failing check skips that order (log which + why).
STEP 4 — Per approved trade: whole share fits budget → review then place (limit, marketable at
         ask, whole shares, regular_hours, gfd); else fractional (market, dollar_amount, regular_hours).
         Fresh UUID ref_id. Await fill.
STEP 5 — Immediately protect (20% below fill): whole-share → resting stop_market GTC side=sell
         (log order_id); fractional → record a software stop $level (no resting order; enforced at scan).
STEP 6 — Record to memory/TRADE-LOG.md (Schema): trade note + an open-position row (`SYM | bucket= |
         qty= | entry= | stop= | protection=<resting id | software $X> | lane= | opened=`); bump the
         `Cadence:` opening-trade count.
STEP 7 — Notification (preview the production format): build and send the MKT-OPEN Telegram exactly
         per the icon template in routines/market-open.md STEP 7 (💰/⚡/🧠/📁/🧭 sections + the plain
         "👉 You:" action line + the "📖 Terms:" gloss footer). Send via bash scripts/notify.sh
         (falls back to NOTIFICATIONS.md with no local Telegram creds).
(No commit — local test. Review by hand.)
