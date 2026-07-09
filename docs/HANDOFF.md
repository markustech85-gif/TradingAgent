# Trading Agent — Claude Code Build Handoff Packet

A self-contained blueprint for building an autonomous, cloud-scheduled **stocks & ETF**
trading agent on top of Claude Code, using **Robinhood (agentic MCP)**, **Perplexity**,
**Telegram**, **GitHub**, and **Claude Code Routines**.

Adapted from the "Opus 4.7 Trading Bot" blueprint (which used Alpaca + ClickUp) to this
stack, recalibrated for a **$500** account and a **30-day test**. Claude is the bot: every
scheduled run is a fresh Claude Code session that reads memory, acts, writes memory, and
commits to git.

> NOTE: This repo has already been built from this blueprint. This document is retained as
> the canonical design reference. For the implemented layout see the repo root and
> `docs/VM-DEPLOYMENT.md`. Order-placing tools start DENIED in `.claude/settings.json`
> (Phase 1); enable them only after the read-only verification passes.

---

## 0. How to use this packet

1. Open Claude Code in an empty directory that will become the repo.
2. Paste this entire document and say: *"Build this project per Section 12's checklist.
   Create the files exactly as specified. Ask me for credentials only when needed, and
   only to put them in my local `.env` or a routine's environment settings — never commit them."*
3. Claude Code creates the structure, scripts, prompts, and memory seeds, and walks you
   through the cloud setup.
4. Do the **read-only verification in Section 13 BEFORE enabling any routine that can trade.**

---

## 1. What you're building

Four scheduled routines run each weekday. Each spins up a fresh Claude Code cloud
container that clones the repo, reads memory, pulls live Robinhood state via the MCP,
decides + acts under hard rules, writes memory, notifies you on Telegram, and commits
back to `main`.

- **Pre-market** (~8:00 AM ET): research catalysts, write today's ideas to the research log.
- **Market-open** (~9:30 AM ET): run the buy-side gate, place approved buys, set a
  protective stop on each.
- **Midday** (~12:00 PM ET): cut losers at −20%, re-peg winners' stops, exit broken theses.
- **Daily-summary** (~4:15 PM ET): compute P&L, snapshot the book, send a Telegram recap.

Three properties drive the design: **stateless runs** (each fire is independent, so failures
self-heal next tick), **git-as-memory** (all state is append-only dated markdown on `main`,
giving free versioning + audit trail), and **hard-rules-as-gates** (discipline is checked in
the prompt before every order).

---

## 2. Your stack (and what it replaced)

| Function | This build uses | Replaces the guide's | Key difference |
|---|---|---|---|
| Trading | **Robinhood agentic MCP** (`Robhinhood` namespace) | Alpaca REST + `alpaca.sh` | Trading is an **MCP connector**; the agent calls MCP tools directly. **No trading wrapper script.** |
| Research | **Perplexity** via `scripts/perplexity.sh` | Perplexity (same) | Unchanged; curl wrapper reading `PERPLEXITY_API_KEY`. |
| Notifications | **Telegram** Bot API (`scripts/notify.sh`; `whatsapp.sh` = back-compat shim) | ClickUp + `clickup.sh` | New wrapper; same graceful-fallback pattern. |
| Memory / state | **Git** (markdown on `main`) | Git (same) | Unchanged. |
| Scheduling | **Claude Code Routines** | Claude Code cloud routines (same) | Unchanged. Min interval 1hr; runs may start a few min late; ~15 runs/day account cap. |
| Repo | **GitHub** | GitHub (same) | Unchanged. |

---

## 3. Prerequisites

- Robinhood **agentic** account — you have this: **#604803171**, agentic-enabled, cash type, ~$500.
- A **private GitHub repo** for this project.
- A **Perplexity API key** (research). Optional: the agent falls back to native web search if unset.
- A **Telegram bot** (fast to start): create one with **@BotFather** for a bot token, then get
  your numeric chat ID from `getUpdates` after messaging the bot once. See `docs/VM-DEPLOYMENT.md` §8.
- **Claude Code** on a paid plan with **Routines** (research preview) enabled, plus the
  **Claude GitHub App** installed on the repo.

---

## 4. Repository layout

```
trading-agent/
├── CLAUDE.md                 # Agent rulebook, auto-loaded every session
├── README.md                 # Human quickstart
├── env.template              # Copy to .env locally; NEVER commit real .env
├── .gitignore                # Must exclude .env
├── scripts/
│   ├── perplexity.sh         # Research wrapper (curl → Perplexity)
│   ├── notify.sh             # Notification wrapper (curl → Telegram Bot API)
│   └── whatsapp.sh           # Back-compat shim → notify.sh
│                             # (no trading script — Robinhood is an MCP connector)
├── routines/                 # Cloud routine prompts (production)
│   ├── pre-market.md
│   ├── market-open.md
│   ├── midday.md
│   └── daily-summary.md
├── .claude/commands/         # Local slash-command versions for testing
│   ├── portfolio.md
│   ├── pre-market.md
│   ├── market-open.md
│   ├── midday.md
│   └── daily-summary.md
└── memory/                   # Agent's persistent state (committed to main)
    ├── STRATEGY.md
    ├── TRADE-LOG.md
    ├── RESEARCH-LOG.md
    └── PROJECT-CONTEXT.md
```

Two modes share the repo: **local** (slash commands, credentials from `.env`, for testing)
and **cloud** (routines fire on a schedule, credentials from routine env settings, **no `.env`**).

---

## 5. Robinhood MCP — tool reference & gotchas (READ CAREFULLY)

**The trading interface is the MCP connector, not a bash script.** When the Robinhood
connector is attached to a session/routine, these tools are available for the agent to call
directly. `account_number` is always **"604803171"** (explicit — never defaulted from
`get_accounts`).

Tools used by this agent:

- `get_accounts` — confirm account **604803171** is present and `agentic_allowed=true`.
- `get_portfolio` (`account_number`) — market value, cash, buying power.
- `get_equity_positions` (`account_number`) — open positions + unrealized P&L.
- `get_equity_quotes` — real-time quote + last close for a symbol.
- `get_equity_orders` (`account_number`, filters) — order status/history; use to reconcile.
- `review_equity_order` — **simulate** an order; returns quote + pre-trade alerts
  (buying power, halt, etc.). Call this before every place.
- `place_equity_order` — **real order, real money.** Params mirror review + a `ref_id`.
- `cancel_equity_order` (`account_number`, `order_id`) — cancel a resting stop.
- `search` — resolve a natural-language name to a tradable instrument.

Order shape essentials:
- `type`: **`market`, `limit`, `stop_market`, `stop_limit`** — **there is NO trailing-stop type.**
- `time_in_force`: `gfd` or `gtc`.
- `quantity` (shares) **or** `dollar_amount` (notional, `market` only).
- `stop_price` required for `stop_market`/`stop_limit`; `limit_price` for `limit`/`stop_limit`.
- `ref_id`: a UUID idempotency key — generate one per logical order, re-send on retry.

**Gotchas baked into this design:**
1. **No native trailing stop.** We simulate one: place a fixed `stop_market` GTC at 20%
   below entry, then **re-peg it upward** (cancel + replace) at each routine run as the
   position rises. Never move a stop down; never within 3% of current price.
2. **HYBRID stops (fractional enabled).** Fractional/dollar orders can't carry a resting stop
   (regular-hours market orders only). So: buy **whole shares + a resting broker stop** whenever
   one share fits the per-position budget (≤50%/$250); for pricier names, buy **fractional +
   a software stop** the agent enforces at each scan (accepting between-scan gap risk). Every
   position still starts with a 20%-below stop — resting or software.
3. **Always `review_equity_order` before `place_equity_order`** — it surfaces buying-power
   and halt alerts and the live quote. In autonomous mode this is the validation gate, not a
   human-approval pause.
4. **Reconcile before buying.** A routine is stateless and may retry. Before placing buys,
   read `get_equity_positions` and today's `get_equity_orders` so you never double-buy.
5. **Crypto is not supported** via this MCP. Stocks & ETFs only anyway.
6. **PDT rule was eliminated June 4, 2026** — no day-trade-count gate. But this is a **cash
   account**, so good-faith settlement still applies: don't buy with unsettled proceeds.

---

## 6. memory/STRATEGY.md  (the rulebook — every routine reads it first)

See `memory/STRATEGY.md` in the repo (the full recalibrated-for-$500 rulebook). It encodes:
mission, account/capital, position sizing, order mechanics, the 11 core rules, the Buy-Side
Gate, Sell-Side rules, the entry checklist, the kill-switch, and the autonomy note.

---

## 7. Wrapper scripts

After creating both, run `chmod +x scripts/*.sh`. See `scripts/perplexity.sh` and
`scripts/notify.sh` in the repo (`whatsapp.sh` is a thin shim that forwards to `notify.sh`).
Both source a local `.env` if present, and both fail gracefully: perplexity exits 3 when
`PERPLEXITY_API_KEY` is unset (caller falls back to web search); notify appends to
`NOTIFICATIONS.md` when the Telegram vars are missing.

---

## 8. CLAUDE.md  (repo root — auto-loaded every session)

See `CLAUDE.md` in the repo root. It carries the mission, read-me-first order, the trading
interface notes, the hard-rules quick reference, the Phase 1/Phase 2 trading toggle, the
first-run QQQ housekeeping note, the persistence reminder, and the communication style.

---

## 9. env.template

See `env.template` in the repo. Copy to `.env` locally (gitignored). In cloud routines, set
these as the routine's environment variables instead — do NOT create a `.env` in the cloud.
Robinhood is NOT here — it's an MCP connector authenticated through Claude, not via env vars.

---

## 10. Memory seeds

See `memory/TRADE-LOG.md` (Day 0 baseline), `memory/RESEARCH-LOG.md` (template entry), and
`memory/PROJECT-CONTEXT.md` (overview, guardrails, open items, verification status) in the repo.

---

## 11. Routine prompts (paste verbatim into each routine)

See `routines/pre-market.md`, `routines/market-open.md`, `routines/midday.md`,
`routines/daily-summary.md`, and the read-only `routines/verify-readonly.md`. Every prompt
shares a header: an **environment-variable check** (Perplexity + Telegram only — Robinhood is a
connector), a **Robinhood-reachability check**, a **no-`.env`** guardrail, and a **mandatory
commit-and-push** at the end. All times America/New_York, weekdays.

- pre-market — cron `0 8 * * 1-5`
- market-open — cron `30 9 * * 1-5`
- midday — cron `0 12 * * 1-5`
- daily-summary — cron `15 16 * * 1-5`

The `.claude/commands/` local versions mirror these prompts **minus** the env-var block and the
commit/push step, and add a read-only `portfolio.md`.

---

## 12. Build & go-live checklist (in order)

1. Create a private GitHub repo; clone it; open in Claude Code.
2. Build the structure in Section 4. Create scripts, prompts, CLAUDE.md, env.template, memory seeds.
3. `chmod +x scripts/*.sh`. Add `.env` to `.gitignore`.
4. Sign up for Perplexity (key) and create a Telegram bot (bot token + your chat ID).
5. `cp env.template .env`, fill it in locally.
6. Attach the **Robinhood connector** to your Claude Code session.
7. **Local smoke test:** run `/portfolio` — you should see account 604803171, positions, orders
   print cleanly. Then run `/pre-market` and confirm it writes a RESEARCH-LOG entry.
8. Install the Claude GitHub App on the repo.
9. **Do Section 13 (read-only routine verification) before enabling any trading routine.**
10. Create the four routines (select the repo, attach the Robinhood connector, add the
    Perplexity + Telegram env vars, enable pushing to `main`, set the cron + America/New_York,
    paste the matching prompt verbatim).
11. "Run now" on pre-market first; watch the log; confirm the RESEARCH-LOG entry is committed + pushed.
12. Seed TRADE-LOG.md with the Day 0 snapshot so Day 1's summary has a baseline.
13. **Monitor the first week closely. Read every commit the agent makes.** Start with the smallest
    real sizing you're comfortable with.

Scheduling notes: routines' minimum interval is 1 hour (fine here); runs may start a few minutes
after the scheduled time; the account has ~15 routine-runs/day and shares quota with your
interactive Claude Code usage.

---

## 13. Verify FIRST: does Robinhood auth survive in a cloud routine?

This is the single biggest unknown, because the Robinhood MCP is an OAuth connector and a
routine runs in a fresh Anthropic-hosted container. **Before any routine can place a trade:**

1. Create a throwaway routine whose prompt is read-only (see `routines/verify-readonly.md`).
2. Attach the Robinhood connector + the Telegram env vars. "Run now."
3. If you get real portfolio numbers on Telegram, MCP auth works in routines — proceed.
4. If it can't authenticate, the connector doesn't carry into the cloud run. Fallback:
   run the routines **locally** on your Mac, or use the VM path (`docs/VM-DEPLOYMENT.md`).

---

## 14. First-run troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Routine can't reach Robinhood | Connector not attached, or OAuth didn't carry into the cloud | Re-attach; if still failing, use the VM path (`docs/VM-DEPLOYMENT.md`) |
| `git push` fails (proxy/permission) | Default `claude/`-only branch restriction still on | Enable pushing to `main` in the routine's settings |
| "Repository not accessible" | Claude GitHub App not installed on the repo | Install it, grant access to just this repo |
| Yesterday's trades missing today | Previous run didn't commit+push | Check `git log origin/main`; re-verify the commit step in the prompt |
| Telegram message never arrives | A Telegram var missing / never messaged the bot | Script fell back to NOTIFICATIONS.md; add the vars, and message the bot once so it can reply |
| Perplexity calls skipped | `PERPLEXITY_API_KEY` unset | Script exits 3; agent uses web search. Add the key or accept the fallback |
| Order rejected: position cap | Name's whole-share cost exceeds the ≤50% ($250) budget | Buy fractional (dollar-sized) + software stop, or size down (per STRATEGY) |
| Stop order rejected | Tried to rest a stop on a fractional lot | Expected — fractional lots use a software stop; whole-share lots get the resting `stop_market` (per STRATEGY) |
| Duplicate buys after a retry | Didn't reconcile before buying | Ensure the prompt reads positions/orders first; reuse the `ref_id` on true retries |

---

## 15. Notification philosophy

**Updated 2026-07-09:** all four routines now send **one concise ≤8-line Telegram summary every
run** (account, kill-switch, ideas/actions, decision/next), so you get a per-run heartbeat while
building trust in the agent. Urgent/kill-switch events are surfaced as the first line. Original
"quiet by design" behavior (pre-market silent-unless-urgent; market-open/midday only on action)
is preserved in git history if you want to revert to fewer messages later.
