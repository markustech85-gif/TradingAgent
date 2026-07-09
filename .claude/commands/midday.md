Local test version of the MIDDAY scan (uses local .env; no cloud env-var block, no commit/push).
US STOCKS & ETFs ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

Order tools may be denied (Phase 1). If so, log intended actions and execute none.

STEP 1 — Read memory: STRATEGY.md (exit rules); tail of TRADE-LOG.md; today's RESEARCH-LOG.
STEP 2 — Live state: get_equity_positions(604803171); get_equity_orders(604803171).
STEP 3 — Cut losers <= -20% (or fractional lot at/below its software stop): sell (review then place),
         cancel the resting stop if any (fractional lots have none), log it.
STEP 4 — Ratchet winners: +20% -> stop 5% below current; +15% -> stop 7% below current. Whole-share
         → cancel old stop, place new stop_market GTC; fractional → update recorded software stop.
         Never move a stop down; never within 3% of current price.
STEP 5 — Thesis check: exit broken theses even if not yet -20%. Document.
STEP 6 — Optional research via bash scripts/perplexity.sh for sharp unexplained moves.
(No commit — local test. Review by hand.)
