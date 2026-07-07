Local test version of the MARKET-OPEN workflow (uses local .env; no cloud env-var block,
no commit/push). STOCKS ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

Order tools may be denied (Phase 1). If so, log intended orders and place nothing.

STEP 1 — Read memory: STRATEGY.md; TODAY's RESEARCH-LOG entry (if missing, do research first);
         tail of TRADE-LOG.md (weekly trade count).
STEP 2 — Reconcile: get_portfolio; get_equity_positions; get_equity_orders; get_equity_quotes
         for each planned ticker (never double-buy).
STEP 3 — KILL-SWITCH: if account <= $400, no buys; alert; stop. Else run the Buy-Side Gate
         (STRATEGY.md) per planned order; skip failures with a logged reason.
STEP 4 — Per approved trade: review_equity_order (limit, marketable at ask, whole shares,
         regular_hours, gfd). If clean, place_equity_order + fresh UUID ref_id. Await fill.
STEP 5 — Immediately place the protective stop_market GTC, side=sell, 10% below fill.
STEP 6 — Append each trade to memory/TRADE-LOG.md (date, ticker, shares, entry, stop, thesis,
         target, R:R, ref_id, stop order_id).
(No commit — local test. Review by hand.)
