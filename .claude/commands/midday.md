Local test version of the MIDDAY scan (uses local .env; no cloud env-var block, no commit/push).
US STOCKS & ETFs ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

Order tools may be denied (Phase 1). If so, log intended actions and execute none.

STEP 1 — Read memory: STRATEGY.md (exit rules); BUCKETS.md; tail of TRADE-LOG.md — each
         open-position row's `protection=` tag (resting ORDER_ID | software $level), entry, stop,
         bucket; today's RESEARCH-LOG.
STEP 2 — Live state: get_equity_positions(604803171); get_equity_orders(604803171). Match each lot
         to its open-position row; the `protection=` tag drives the branch.
STEP 3 — Cut losers: unrealized <= -20% OR (software lot) price at/below its recorded software stop.
         Resting lot: check if its broker stop already filled; if open, sell (review then place) +
         cancel_equity_order the stop. Software lot: sell market at the scan (no resting order). Log
         exit + remove the open-position row; note the bucket result (2-consecutive-fails exit).
STEP 4 — Ratchet winners: +20% -> stop 5% below current; +15% -> stop 7% below current. Resting lot:
         cancel old stop, place new stop_market GTC, update `protection=resting <new_id>`+`stop=`.
         Software lot: update the recorded `protection=software $X` level. Never lower a stop; never
         within 3% of price.
STEP 5 — Thesis check: exit broken theses even if not yet -20%. Document.
STEP 6 — Optional research via your NATIVE web search (real, current searches) for sharp unexplained moves.
STEP 7 — Notification (preview the production format): build and send the MIDDAY Telegram exactly
         per the icon template in routines/midday.md STEP 7 (💰/⚡/📁/🧭 sections, each stop shown as
         $level + ~% below now, + the plain "👉 You:" action line + the "📖 Terms:" gloss footer).
         Send via bash scripts/notify.sh (falls back to NOTIFICATIONS.md with no local Telegram creds).
(No commit — local test. Review by hand.)
