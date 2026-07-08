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
- [ ] Robinhood MCP auth survives into a scheduled/trigger fresh session (run verify-readonly).
- [ ] Read-only chain confirmed end-to-end (portfolio -> Telegram).
- [ ] Trading enabled (Phase 2) after human sign-off.

## VM deployment (always-on path — docs/VM-DEPLOYMENT.md)
Production path = own DigitalOcean VM + cron running `claude -p` headless (NOT Anthropic Routines).
Progress as of 2026-07-08:
- [x] §3 droplet provisioned (Ubuntu, 2 GB), SSH in
- [x] §4 hardened (non-root `trader`, ufw, root/password login off, tz=America/New_York)
- [x] §5 runtime installed (Node LTS, Claude Code CLI)
- [x] §6 ANTHROPIC_API_KEY in ~/.trading-agent.secrets (VM->Anthropic, API-key path)
- [x] §7 repo cloned to ~/trading-agent via deploy key; SSH remote, user.name=trading-vm; push/write verified
- [ ] §8 local .env (Perplexity + Telegram) — NEXT. Notifications now via Telegram
  (scripts/notify.sh); vars TELEGRAM_BOT_TOKEN + TELEGRAM_CHAT_ID.
- [ ] §9 Robinhood MCP authenticated on VM (SSH port-forward browser step)
- [ ] §10 read-only verification run (the gate — portfolio -> Telegram non-interactive)
- [ ] §12 cron installed (4 routines, Eastern)
- Phase 1 active: place/cancel_equity_order still denied in .claude/settings.json. Read/research/
  summary routines do real work; market-open only logs intended orders until Phase 2.
- bin/run-routine.sh already in repo (Section 11 needs no hand-authoring).

## Key files (read every session)
- memory/STRATEGY.md, TRADE-LOG.md, RESEARCH-LOG.md, PROJECT-CONTEXT.md
