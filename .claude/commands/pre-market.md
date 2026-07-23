Local test version of the PRE-MARKET workflow (uses local .env; no cloud env-var block,
no commit/push). US STOCKS & ETFs ONLY. Ultra-concise. DATE=$(date +%Y-%m-%d).

STEP 1 — Read memory: STRATEGY.md; BUCKETS.md (bucket watchlist + Tier-1 gate); tail of
         TRADE-LOG.md (open-position rows + `Cadence:` line); tail of RESEARCH-LOG.md.
STEP 2 — Live state: get_portfolio(604803171); get_equity_positions(604803171);
         get_equity_orders(604803171). Compute drawdown vs $500 (kill-switch check).
STEP 3 — Research with your NATIVE web search (real, current searches now — never training memory
         for prices, levels, or news) for: index futures; VIX; top catalysts today $DATE; pre-open
         earnings; econ calendar; sector momentum; news on each held ticker. Scan the BUCKETS.md
         buckets (AI-complex / Energy / Outside) for setups.
STEP 4 — Append a dated entry to memory/RESEARCH-LOG.md: account snapshot; market context;
         up to 3 BUCKETS.md-watchlist ideas chosen to move the book TOWARD the floor (≤2 AI-complex,
         ≥1 Energy, exactly 1 Outside — include an Outside diversifier when the slot's open). Tag each:
         bucket + lane (same-day catalyst | multi-day swing) + catalyst + entry + stop 20% below +
         target + R:R; whole-share-fit vs per-position budget (fractional if pricier). Off-watchlist
         Outside idea → apply BUCKETS.md §5 Tier-1 gate (multi-day catalyst + ≥1 confirming indicator
         via get_equity_historicals) or drop it. Risk; decision (default HOLD).
STEP 5 — Notification (preview the production format): build and send the PRE-MKT Telegram exactly
         per the icon template in routines/pre-market.md STEP 5 (💰/📊/📁/🎯/🧭 sections + the plain
         "👉 You:" action line + the "📖 Terms:" gloss footer). Send via bash scripts/notify.sh; with
         no local Telegram creds it falls back to NOTIFICATIONS.md so you can eyeball the wording.
(No commit — this is the local test command. Review the RESEARCH-LOG entry by hand.)
