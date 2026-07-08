# TradingAgent

Autonomous, cloud-scheduled **stocks-only** trading agent built on Claude Code.
Broker: **Robinhood** (agentic MCP, account #604803171, cash, ~$500). Goal: beat the
S&P 500 over a 30-day test. Research via Perplexity, alerts via Telegram,
state + audit trail in git.

> ⚠️ **Real money.** Order-placing tools start **DENIED** in `.claude/settings.json`
> (Phase 1). Nothing can trade until you finish the read-only verification and flip to
> Phase 2. See [Go-live](#go-live-order-of-operations).

## How it works

Claude *is* the bot. Four scheduled routines fire each weekday; each run is a fresh,
stateless Claude Code session that clones the repo, reads `memory/`, pulls live Robinhood
state, acts under the hard rules in `memory/STRATEGY.md`, writes memory, and commits to `main`.

| Routine | Time (ET) | Cron | Does |
|---|---|---|---|
| pre-market | 8:00 AM | `0 8 * * 1-5` | Research catalysts → `RESEARCH-LOG.md` |
| market-open | 9:30 AM | `30 9 * * 1-5` | Buy-side gate → buys + protective stops |
| midday | 12:00 PM | `0 12 * * 1-5` | Cut losers −7%, re-peg winners' stops |
| daily-summary | 4:15 PM | `15 16 * * 1-5` | P&L, EOD snapshot, one Telegram recap |

## Layout

```
CLAUDE.md              Auto-loaded rulebook (every session)
env.template           Copy to .env locally; never commit .env
.claude/settings.json  Permission gates (order tools denied in Phase 1)
.claude/commands/      Local /slash test versions (portfolio, per-routine)
scripts/               perplexity.sh (research), notify.sh (Telegram notify; whatsapp.sh = shim)
routines/              Production prompts + verify-readonly.md
memory/                STRATEGY, TRADE-LOG, RESEARCH-LOG, PROJECT-CONTEXT (git = state)
bin/run-routine.sh     Headless runner for the VM path
docs/                  HANDOFF.md (design blueprint), VM-DEPLOYMENT.md (always-on VM)
```

## Two production paths

- **Cloud routines** (this environment): schedule the four `routines/*.md` as triggers with
  the Robinhood connector + Perplexity/Telegram env vars attached. Simplest to start.
- **Always-on VM**: run `bin/run-routine.sh` from cron on your own droplet. Robinhood OAuth is
  authenticated once and persists on disk. Full runbook in [`docs/VM-DEPLOYMENT.md`](docs/VM-DEPLOYMENT.md).

## Go-live order of operations

1. **Secrets** — `cp env.template .env`, fill in Perplexity + Telegram (local), or set them as
   routine/VM env vars. `.env` is gitignored. Robinhood is a connector, not an env var.
2. **Local smoke test** — attach the Robinhood connector, run `/portfolio`, then `/pre-market`.
3. **Read-only verification** — run `routines/verify-readonly.md` as a scheduled trigger and
   confirm it reaches Robinhood and sends a Telegram message — *in an unattended run*. This is the gate.
4. **Enable trading (Phase 2)** — only after step 3: remove `place_equity_order` and
   `cancel_equity_order` from the `deny` list in `.claude/settings.json`. Option tools stay
   denied permanently (stocks only).
5. **Arm the four routines** and monitor the first week closely — read every commit.

## Guardrails

- Stocks only — options/crypto order tools permanently denied.
- ≤ 6 positions, each ≤ 20% ($100); 75–85% deployed; whole shares only.
- Every position carries a resting GTC `stop_market` (10% below entry; ratchets on winners).
- Cut losers at −7%. Max 3 new trades/week.
- **Kill-switch:** account ≤ $400 (−20%) → halt new buys, alert, manage-only.

Full rules: [`memory/STRATEGY.md`](memory/STRATEGY.md). Design detail: [`docs/HANDOFF.md`](docs/HANDOFF.md).
