Local test version of the MARKET-OPEN workflow (uses local .env; no cloud env-var block,
no commit/push). US STOCKS & ETFs ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

Order tools may be denied (Phase 1). If so, log intended orders and place nothing.

STEP 1 — Read memory: STRATEGY.md; TODAY's RESEARCH-LOG entry (if missing, do research first);
         tail of TRADE-LOG.md (weekly trade count).
STEP 2 — Reconcile: get_portfolio; get_equity_positions; get_equity_orders; get_equity_quotes
         for each planned ticker (never double-buy).
STEP 3 — KILL-SWITCH: if account <= $250, no buys; alert; stop. Else run the Buy-Side Gate
         (STRATEGY.md) per planned order — incl. composition floor (≤2 AI-complex + ≥1 Energy +
         1 Outside) and de-dup; skip failures with a logged reason.
STEP 4 — Per approved trade: whole share fits budget → review then place (limit, marketable at
         ask, whole shares, regular_hours, gfd); else fractional (market, dollar_amount, regular_hours).
         Fresh UUID ref_id. Await fill.
STEP 5 — Immediately protect (20% below fill): whole-share → resting stop_market GTC side=sell;
         fractional → record a software stop (no resting order; enforced at each scan).
STEP 6 — Append each trade to memory/TRADE-LOG.md (date, ticker, bucket, shares/$amount, entry,
         stop 20% below, protection [resting order_id | software], thesis, target, R:R, ref_id).
(No commit — local test. Review by hand.)
