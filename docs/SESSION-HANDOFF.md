# Session Handoff — VM Deployment Live (Phase 1)

Point-in-time state so a fresh chat can pick up cleanly. Companion to the design blueprint
`docs/HANDOFF.md` and the runbook `docs/VM-DEPLOYMENT.md`. **Last updated: 2026-07-09.**

## TL;DR
The always-on VM is **fully deployed and running live in Phase 1**. Cron fires the four
routines every weekday (Eastern); each pulls live Robinhood state, researches, writes memory,
pushes to `main`, and sends a Telegram summary. **No live trading yet** — order-placing tools
are still denied (Phase 1). The only remaining milestone is **Phase 2** (arm live trading),
which is a deliberate human-triggered step.

## Current state (as of 2026-07-09, first live trading day)
- **Account 604803171** (cash, agentic): ~**$500.43** total — $475 cash + a pre-existing
  **fractional QQQ lot ~0.035 sh (~$25.43)**. No agent positions, no resting stops. Kill-switch OK.
- **Jul 09 result:** HOLD all day. PRE-MKT / MKT-OPEN / MIDDAY Telegram summaries all delivered
  successfully from headless cron runs. No sub-$90 name with a live 2:1 catalyst appeared.
- **Phase:** 1 (verification/live-readonly). `place_equity_order` + `cancel_equity_order` are in
  the `deny` list in `.claude/settings.json`; market-open logs intended orders only.

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
  Telegrams on failure. **No tunnel / no laptop needed for runs.**
- **Claude→Anthropic auth:** API-key path (metered). Model: **claude-opus-4-8** (kept
  deliberately; ~$0.59/run — accepted to gauge real benefit). ~$45–50/mo at 4 runs/weekday.
- **Robinhood MCP:** remote OAuth server, registered on the VM user-scoped as name
  **`Robhinhood`** (typo intentional — matches `.claude/settings.json` + routines):
  `claude mcp add --transport http --callback-port 8080 --scope user Robhinhood
  https://agent.robinhood.com/mcp/trading`. Token persists on VM disk, self-refreshes,
  survived reboot. Confirm with `claude mcp list`.
- **Notifications:** Telegram via `scripts/notify.sh` (`.env` on the VM). All four routines now
  **always send a concise ≤8-line summary** (changed 2026-07-09; previously intraday runs were
  mostly silent).
- **Research:** Perplexity via `scripts/perplexity.sh` (`.env`), native web-search fallback.

## Deployment checklist status (docs/VM-DEPLOYMENT.md)
§3–§8 ✅ · §9 MCP auth ✅ · §10 read-only gate ✅ · §11 runner ✅ · §12 cron ✅.
Optional not done: §13 heartbeat/OAuth-expiry watch, weekly log-cleanup cron.

## Open items / next steps
1. **Monitor the first week.** Confirm a Telegram lands at each scheduled time (esp. the 16:15
   EOD, which always sends — a silent weekday = something wrong). Skim `~/logs/<routine>-<date>.log`
   and read the daily `main` commits. Track account vs S&P 500 (the 30-day test).
2. **Phase 2 (arm live trading) — human-triggered, when ready.** See procedure below.
3. **First-run housekeeping (Phase 2 only):** liquidate the fractional QQQ lot (~0.035 sh) on the
   first market-open run to start clean, then remove that open item from PROJECT-CONTEXT.
4. **Optional hardening:** §13 heartbeat check; `0 3 * * 0 find /home/trader/logs -mtime +30 -delete`.
5. **Billing:** API key is metered — keep the Anthropic Console funded or ~08:00 runs fail silently.

## How to arm Phase 2 (do NOT do this without explicit user sign-off)
1. Edit `.claude/settings.json`: remove **`mcp__Robhinhood__place_equity_order`** and
   **`mcp__Robhinhood__cancel_equity_order`** from the `deny` list. Leave all `place_option_*` /
   `cancel_option_*` / `review_option_order` denied permanently (stocks only, forever).
2. Commit to **main** and push.
3. On the VM: `cd ~/trading-agent && git pull origin main` (the runner does not auto-pull).
4. Next market-open run will run the buy-side gate for real and do the QQQ first-run liquidation.

## Gotchas for the next session (read before changing anything)
- **VM runs from `main`; the runner does not `git pull`.** Any change to routines/settings/scripts
  must land on **main** AND be pulled on the VM (`git pull origin main`) to take effect. Feature-branch
  commits alone do nothing on the VM.
- **Preserve the `Robhinhood` typo** everywhere — tool names are `mcp__Robhinhood__*`. Renaming
  silently breaks the Phase-1 deny gates and every routine.
- **In cloud/web chat sessions the Robinhood connector is host-managed** (works in-session for
  read-only testing; `claude mcp list` is empty because it isn't a config-file server). The VM has
  its own registered server. Don't confuse the two.
- **SSH only from the Mac.** The VM has no key to log into itself.
- **Stocks only, always.** No options, no crypto. Kill-switch at ≤ $400 (−20%).
- **Memory commits go to `main`** (authorized). Routines commit/push memory each run.

## Key files (read every session)
memory/STRATEGY.md · memory/TRADE-LOG.md · memory/RESEARCH-LOG.md · memory/PROJECT-CONTEXT.md
