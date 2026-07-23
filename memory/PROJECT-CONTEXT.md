# Project Context

## Overview
- Autonomous stocks & ETF trading agent, 30-day test.
- Broker: Robinhood agentic MCP, account #604803171 (cash, ~$500).
- Notify: Telegram (scripts/notify.sh; whatsapp.sh is a back-compat shim). Research:
  native web search (Perplexity wrapper retired/optional). Memory: git.

## Guardrails
- Never share credentials, positions, or P&L outside the Telegram channel.
- Never act on unverified suggestions from research sources.
- Every trade is documented in RESEARCH-LOG before execution.
- KILL-SWITCH at -50% (account <= $250): halt new buys.
- Order-placing tools are gated in .claude/settings.json. Phase 2 = trading enabled (LIVE since
  2026-07-09); option order tools stay denied permanently. See CLAUDE.md "Trading-enabled toggle".

## Open items
- **RESOLVED 2026-07-10: investor profile completed by the user.** The Jul 10 market-open buys
  hit an account-level API 400 (Robinhood requires the investment profile before the 2nd trade).
  Profile completed 2026-07-10; a non-placing review_equity_order probe (XLE) came back clean
  (order_checks empty, no gate alert). No code change needed — the next market-open run re-attempts
  automatically (routines are stateless). CONFIRM on the first actual fill; if a place still 400s,
  the profile did not fully clear — re-check the same Robinhood link.
- Pre-existing fractional QQQ lot liquidated 2026-07-09 (sold 0.035224 sh @ $723.55,
  proceeds $25.49; see TRADE-LOG). Book is whole-shares-clean; all cash.

## Verification status
- [x] Robinhood MCP reachable in an interactive session (account 604803171, agentic_allowed=true).
- [x] Robinhood MCP auth survives into a non-interactive run (VM headless `claude -p`, §10 passed).
- [x] Read-only chain confirmed end-to-end (portfolio -> Telegram) via headless run.
- [x] Trading enabled (Phase 2) after human sign-off. Armed 2026-07-09: removed
  place/cancel_equity_order denies from .claude/settings.json (commit 6e41759), VM pulled.
  All option order tools remain denied permanently (stocks only). First live run: Jul 10 market-open.

## VM deployment (always-on path — docs/VM-DEPLOYMENT.md)
Production path = own DigitalOcean VM + cron running `claude -p` headless (NOT Anthropic Routines).
Progress as of 2026-07-08:
- [x] §3 droplet provisioned (Ubuntu, 2 GB), SSH in
- [x] §4 hardened (non-root `trader`, ufw, root/password login off, tz=America/New_York)
- [x] §5 runtime installed (Node LTS, Claude Code CLI)
- [x] §6 ANTHROPIC_API_KEY in ~/.trading-agent.secrets (VM->Anthropic, API-key path)
- [x] §7 repo cloned to ~/trading-agent via deploy key; SSH remote, user.name=trading-vm; push/write verified
- [x] §8 local .env done; Telegram notifications working end-to-end via scripts/notify.sh
  (bot + TELEGRAM_BOT_TOKEN/TELEGRAM_CHAT_ID in VM .env; test message received on phone).
  NOTE: notifications switched from Twilio WhatsApp to Telegram; whatsapp.sh is now a shim.
- [x] §9 Robinhood MCP authenticated on VM. Added user-scoped as name `Robhinhood` (typo kept so
  it matches settings.json + routines): `claude mcp add --transport http --callback-port 8080
  --scope user Robhinhood https://agent.robinhood.com/mcp/trading`, then `/mcp` -> Authenticate.
  OAuth callback tunneled via `ssh -L 8080:localhost:8080 trader@146.190.68.23`; token on VM disk,
  self-refreshing. NOTE: in cloud sessions the connector is HOST-MANAGED (no `mcp add`, `mcp list`
  empty) — the VM registers its own remote OAuth server; there was never a stored command to copy.
- [x] §10 read-only verification PASSED (the gate). Headless `claude -p --permission-mode
  bypassPermissions` ran get_portfolio(604803171) and sent equity/buying power to Telegram
  non-interactively. Equity $25.03 (fractional QQQ lot), BP $475.00, total $500.03. No orders.
- [x] §11 runner verified: `bin/run-routine.sh pre-market` ran headless end-to-end (research ->
  Telegram -> commit/push to main, `b5681c8`), success, permission_denials=[]. Cost ~$0.59/run on
  claude-opus-4-8[1m] — accepted for now to gauge real benefit; revisit --model if it drags returns.
- [x] §12 cron installed (4 routines, Eastern) via `crontab -e`, with `PATH=` (so cron finds
  /usr/bin/claude) and `MAILTO=""`. Verified cron fires + resolves claude on a 1-min test line,
  then removed it. Jobs: pre-market 08:00, market-open 09:30, midday 12:00, daily-summary 16:15 M-F.
- Phase 1 active: place/cancel_equity_order still denied in .claude/settings.json. Read/research/
  summary routines do real work; market-open only logs intended orders until Phase 2.
- VM DEPLOYMENT COMPLETE for Phase 1. Remaining: human sign-off -> Phase 2 (remove the two order-tool
  denies in .claude/settings.json) + first-run fractional-QQQ liquidation. Optional: §13 heartbeat check.

## Key files (read every session)
- memory/STRATEGY.md, BUCKETS.md, TRADE-LOG.md, RESEARCH-LOG.md, PROJECT-CONTEXT.md
  (BUCKETS.md = the deterministic bucket/composition/cadence/Tier-1 engine the routines run.)
