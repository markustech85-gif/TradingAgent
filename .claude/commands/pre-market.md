Local test version of the PRE-MARKET workflow (uses local .env; no cloud env-var block,
no commit/push). US STOCKS & ETFs ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

STEP 1 — Read memory: STRATEGY.md; BUCKETS.md (bucket watchlist + Tier-1 gate); tail of
         TRADE-LOG.md (open-position rows + `Cadence:` line); tail of RESEARCH-LOG.md.
STEP 2 — Live state: get_portfolio(604803171); get_equity_positions(604803171);
         get_equity_orders(604803171). Compute drawdown vs $500 (kill-switch check).
STEP 3 — Research via bash scripts/perplexity.sh "<query>" for: index futures; VIX;
         top catalysts today $DATE; pre-open earnings; econ calendar; sector momentum;
         news on each held ticker. Scan the BUCKETS.md buckets (AI-complex / Energy / Outside) for
         setups. If it exits 3, use native web search; note fallback.
STEP 4 — Append a dated entry to memory/RESEARCH-LOG.md: account snapshot; market context;
         up to 3 BUCKETS.md-watchlist ideas chosen to move the book TOWARD the floor (≤2 AI-complex,
         ≥1 Energy, exactly 1 Outside — include an Outside diversifier when the slot's open). Tag each:
         bucket + lane (same-day catalyst | multi-day swing) + catalyst + entry + stop 20% below +
         target + R:R; whole-share-fit vs per-position budget (fractional if pricier). Off-watchlist
         Outside idea → apply BUCKETS.md §5 Tier-1 gate (multi-day catalyst + ≥1 confirming indicator
         via get_equity_historicals) or drop it. Risk; decision (default HOLD).
STEP 5 — Notification only if urgent: bash scripts/notify.sh "<one line>".
(No commit — this is the local test command. Review the RESEARCH-LOG entry by hand.)
