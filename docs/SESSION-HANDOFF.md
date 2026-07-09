# Session Handoff — VM Live, Phase 2 Armed (Live Trading Enabled)

Point-in-time state so a fresh chat can pick up cleanly. Companion to the design blueprint
`docs/HANDOFF.md` and the runbook `docs/VM-DEPLOYMENT.md`. **Last updated: 2026-07-09.**

## TL;DR
The always-on VM is **fully deployed and live in Phase 2** (live trading armed). Cron fires the
four routines every weekday (Eastern); each pulls live Robinhood state, researches, writes memory,
pushes to `main`, and sends a Telegram summary. **Live trading is now enabled** — the equity
order tools are ungated (commit `6e41759`, VM pulled). All option order tools stay denied
permanently (stocks & ETFs only, forever). **First live buy decision runs at the Jul 10 market-open.**

## Current state (as of 2026-07-09)
- **Account 604803171** (cash, agentic): **$500.49 total — all cash. Book is flat**
  (0 positions, 0 stocks, no resting stops). Kill-switch OK.
  - **Settled cash / buying power = $475.** The $25.49 QQQ proceeds are **unsettled (T+1)**;
    the buy-gate deploys against **settled** cash until they clear (≈ Jul 10).
- **Jul 09 timeline:** HOLD all day (no sub-$90 name with a live 2:1 catalyst; day's momentum —
  semis $115+ — priced out of the ≤~$90 whole-share universe). PRE-MKT / MKT-OPEN / MIDDAY Telegram
  summaries delivered from headless cron. **~14:20 ET: Phase 2 armed (human sign-off).** **~14:34 ET:
  fractional QQQ lot liquidated manually** (first-run housekeeping, done early) — sold 0.035224 sh
  @ $723.5513, proceeds $25.49, ~+$0.49 realized. Book started clean for the first live session.
- **Phase:** 2 (live). `place_equity_order` + `cancel_equity_order` are **enabled** (removed from the
  `.claude/settings.json` `deny` list). `place_option_*` / `cancel_option_*` / `review_option_order`
  remain denied permanently. Market-open now runs the real buy-side gate and places orders + stops.

## Infrastructure (all verified working)
- **VM:** DigitalOcean droplet, Ubuntu 24.04, 2 GB. IP **146.190.68.23**, user **trader**,
  repo at **~/trading-agent** on branch **main**. Timezone America/New_York.
- **SSH:** key-only, from your **Mac** (`ssh trader@146.190.68.23`). The VM cannot SSH to itself.
- **Cron:** 4 Eastern jobs via `crontab -e`, with a `PATH=` line (so cron resolves
  `/usr/bin/claude`) and `MAILTO=""`. `cron` is `enabled` (survives reboot) and `active`.
  Verified firing + PATH resolution; survived a clean reboot on 2026-07-09.
  - `0 8 * * 1-5` pre-market · `30 9 * * 1-5` market-open · `0 12 * * 1-5` midday ·
    `15 16 * * 1-5` daily-summary
- **Runner:** `bin/run-routine.sh` (committed, executable). Sources `~/.trading-agent.secrets`
  (ANTHROPIC_API_KEY), `cd`s into the repo, runs `claude -p "$(cat routines/<name>.md)"
  --permission-mode bypassPermissions --max-turns 40 --output-format json`, logs to `~/logs/`,
  Telegrams on failure. **No tunnel / no laptop needed for runs.** (bypassPermissions means the
  `deny` list in `.claude/settings.json` is the ONLY thing gating order tools — hence option tools
  stay denied there.)
- **Claude→Anthropic auth:** API-key path (metered). Model: **claude-opus-4-8** (kept
  deliberately; ~$0.59/run — accepted to gauge real benefit). ~$45–50/mo at 4 runs/weekday.
- **Robinhood MCP:** remote OAuth server, registered on the VM user-scoped as name
  **`Robhinhood`** (typo intentional — matches `.claude/settings.json` + routines):
  `claude mcp add --transport http --callback-port 8080 --scope user Robhinhood
  https://agent.robinhood.com/mcp/trading`. Token persists on VM disk, self-refreshes,
  survived reboot. Confirm with `claude mcp list`.
- **Notifications:** Telegram via `scripts/notify.sh` (`.env` on the VM). All four routines
  **always send a concise ≤8-line summary** (changed 2026-07-09; previously intraday runs were
  mostly silent).
- **Research:** Perplexity via `scripts/perplexity.sh` (`.env`), native web-search fallback.

## Deployment checklist status (docs/VM-DEPLOYMENT.md)
§3–§8 ✅ · §9 MCP auth ✅ · §10 read-only gate ✅ · §11 runner ✅ · §12 cron ✅ · **Phase 2 armed ✅**.
Optional not done: §13 heartbeat/OAuth-expiry watch, weekly log-cleanup cron.

## Open items / next steps
1. **Watch the first LIVE day (Jul 10, market-open 09:30).** It's the first real buy decision.
   Verify: each fill carries a 20%-below stop (resting `stop_market` GTC for whole-share lots;
   recorded software stop for fractional lots — no naked positions), ≤ $250/position, composition
   floor honored (≤2 AI-complex + ≥1 Energy + 1 Outside), ≤ 4 opening trades in week 1,
   documented catalyst in RESEARCH-LOG. NOTE: the revised aggressive strategy (see below) is
   still pending build (Phase B) — until it lands, the routines run the interim rules.
   Jul 10 is Friday + nonfarm payrolls — a data-heavy first session; a HOLD is still valid.
2. **Keep monitoring.** Confirm a Telegram lands at each scheduled time (esp. the 16:15 EOD, which
   always sends — a silent weekday = something wrong). Skim `~/logs/<routine>-<date>.log` and read
   the daily `main` commits. Track account vs S&P 500 (the 30-day test).
3. **Optional hardening:** §13 heartbeat check; `0 3 * * 0 find /home/trader/logs -mtime +30 -delete`.
4. **Billing:** API key is metered — keep the Anthropic Console funded or ~08:00 runs fail silently.

## Phase 2 arming — DONE 2026-07-09 (record + how to disarm)
Armed by removing **`mcp__Robhinhood__place_equity_order`** and **`mcp__Robhinhood__cancel_equity_order`**
from the `.claude/settings.json` `deny` list (commit `6e41759`), pushed to `main`, then
`git pull origin main` on the VM. `place_option_*` / `cancel_option_*` / `review_option_order` were
left denied (stocks & ETFs only, forever). First-run QQQ liquidation was done manually the same afternoon
(commit `fd2e289`), so market-open STEP 0 auto-skips going forward.
- **To DISARM (revert to read-only):** add those two equity order tools back to the `deny` list,
  commit to `main`, push, and `git pull origin main` on the VM. Kill-switch (≤ $250) already halts
  new buys automatically.

## Gotchas for the next session (read before changing anything)
- **VM runs from `main`; the runner does not `git pull`.** Any change to routines/settings/scripts
  must land on **main** AND be pulled on the VM (`git pull origin main`) to take effect. Feature-branch
  commits alone do nothing on the VM.
- **`.claude/settings.json` `deny` is the live trading gate.** Under `--permission-mode
  bypassPermissions`, the deny list is the only thing stopping an order tool. Equity order tools are
  now OUT of it (armed); all option order tools must STAY in it, always.
- **Preserve the `Robhinhood` typo** everywhere — tool names are `mcp__Robhinhood__*`. Renaming
  silently breaks the deny gates and every routine.
- **In cloud/web chat sessions the Robinhood connector is host-managed** (works in-session for
  read-only AND, post-arming, order placement; `claude mcp list` is empty because it isn't a
  config-file server). The VM has its own registered server. Don't confuse the two.
- **SSH only from the Mac.** The VM has no key to log into itself.
- **Stocks & ETFs only, always.** No options, no crypto. Kill-switch at ≤ $250 (−50%).
- **Cash-account settlement:** buy only with **settled** cash (T+1). Sell proceeds are unsettled
  until the next session — the buy-gate must not deploy them early (good-faith violation).
- **Memory commits go to `main`** (authorized). Routines commit/push memory each run.

## Key files (read every session)
memory/STRATEGY.md · memory/TRADE-LOG.md · memory/RESEARCH-LOG.md · memory/PROJECT-CONTEXT.md
