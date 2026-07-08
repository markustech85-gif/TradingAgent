# Project Context

## Overview
- Autonomous stocks-only trading agent, 30-day test.
- Broker: Robinhood agentic MCP, account #604803171 (cash, ~$500).
- Notify: Telegram (scripts/notify.sh; whatsapp.sh is a back-compat shim). Research:
  Perplexity (native web-search fallback). Memory: git.

## Guardrails
- Never share credentials, positions, or P&L outside the Telegram channel.
- Never act on unverified suggestions from research sources.
- Every trade is documented in RESEARCH-LOG before execution.
- KILL-SWITCH at -20% (account <= $400): halt new buys.
- Order-placing tools are gated in .claude/settings.json. Phase 1 = trading disabled
  (read-only verification). Phase 2 = trading enabled. See CLAUDE.md "Trading-enabled toggle".

## Open items
- **Pre-existing fractional QQQ lot (~0.035 shares, ~$25):** liquidate on the FIRST
  market-open run (Phase 2) to start clean with a whole-shares-only book. Until Phase 2,
  leave it and note it. Once sold, remove this item.

## Verification status
- [x] Robinhood MCP reachable in an interactive session (account 604803171, agentic_allowed=true).
- [x] Robinhood MCP auth survives into a non-interactive run (VM headless `claude -p`, §10 passed).
- [x] Read-only chain confirmed end-to-end (portfolio -> Telegram) via headless run.
- [ ] Trading enabled (Phase 2) after human sign-off.

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
- [ ] §12 cron installed (4 routines, Eastern)
- Phase 1 active: place/cancel_equity_order still denied in .claude/settings.json. Read/research/
  summary routines do real work; market-open only logs intended orders until Phase 2.
- bin/run-routine.sh already in repo (Section 11 needs no hand-authoring).

## Key files (read every session)
- memory/STRATEGY.md, TRADE-LOG.md, RESEARCH-LOG.md, PROJECT-CONTEXT.md
