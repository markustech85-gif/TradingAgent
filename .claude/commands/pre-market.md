Local test version of the PRE-MARKET workflow (uses local .env; no cloud env-var block,
no commit/push). STOCKS ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

STEP 1 — Read memory: STRATEGY.md; tail of TRADE-LOG.md; tail of RESEARCH-LOG.md.
STEP 2 — Live state: get_portfolio(604803171); get_equity_positions(604803171);
         get_equity_orders(604803171). Compute drawdown vs $500 (kill-switch check).
STEP 3 — Research via bash scripts/perplexity.sh "<query>" for: index futures; VIX;
         top catalysts today $DATE; pre-open earnings; econ calendar; sector momentum;
         news on each held ticker. If it exits 3, use native web search; note fallback.
STEP 4 — Append a dated entry to memory/RESEARCH-LOG.md: account snapshot; market context;
         2-3 trade ideas (catalyst + entry + stop + target, names <= ~$90); risk; decision (default HOLD).
STEP 5 — Notification only if urgent: bash scripts/whatsapp.sh "<one line>".
(No commit — this is the local test command. Review the RESEARCH-LOG entry by hand.)
