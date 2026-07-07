# Project Context

## Overview
- Autonomous stocks-only trading agent, 30-day test.
- Broker: Robinhood agentic MCP, account #604803171 (cash, ~$500).
- Notify: WhatsApp (Twilio). Research: Perplexity (native web-search fallback). Memory: git.

## Guardrails
- Never share credentials, positions, or P&L outside the WhatsApp channel.
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
- [ ] Read-only chain confirmed end-to-end (portfolio -> WhatsApp).
- [ ] Trading enabled (Phase 2) after human sign-off.

## Key files (read every session)
- memory/STRATEGY.md, TRADE-LOG.md, RESEARCH-LOG.md, PROJECT-CONTEXT.md
