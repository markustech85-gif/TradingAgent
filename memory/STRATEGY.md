# Trading Strategy — 30-Day Test

## Mission
Beat the S&P 500 over the 30-day test window. Disciplined but aggressive.
Stocks only — no options, no crypto. Discipline is the hard part, not the logic.

## Account & Capital
- Broker: Robinhood (agentic MCP, `Robhinhood` namespace)
- Account: #604803171 (agentic-enabled, cash account)
- Starting capital: ~$500
- Instruments: US-listed equities ONLY

## Position Sizing (recalibrated from the guide's $10k to $500)
- Max **20% of equity per position** → ~$100 at the $500 start
- **5–6 concurrent positions** max
- Target **75–85% deployed** → ~$375–425
- Works out to roughly **$70–90 per position**
- **Whole shares only.** Restrict the universe to liquid names priced low enough
  that a 1-share (or small whole-share) position fits the 20% cap (≈ ≤ $90/share).
  Reason: this keeps a REAL resting broker stop usable (see Order Mechanics).

## Order Mechanics on Robinhood (this is where we diverge from the guide)
Robinhood's agentic tool supports order types: `market`, `limit`, `stop_market`, `stop_limit`.
There is **NO native trailing-stop type** (Alpaca had one; Robinhood does not).

- **Entry:** marketable limit at the current ask (price protection) — regular hours.
- **Protective stop (simulated trailing stop):**
  - On entry, place a `stop_market` **GTC** at **10% below the fill price**.
  - At every routine run, if the position has risen, **re-peg** the stop upward:
    cancel the old stop order, place a new `stop_market` GTC at the tightened
    distance below the *current* price.
  - This ratchets at each run (hours apart), not continuously. Fine for swing trading;
    the stop still rests at the broker overnight.
  - **Never move a stop down. Never set a stop within 3% of current price.**
- **Exit:** market (or marketable limit) sell, THEN cancel any resting stop for that symbol.

## Core Rules (non-negotiable)
1. No options. No crypto. US stocks only.
2. Max 5–6 open positions; each ≤ 20% ($100) of equity.
3. Keep 75–85% of capital deployed.
4. Every open position carries a resting GTC `stop_market` (starts 10% below entry).
5. Cut losers at **−7% from entry** — the agent closes at the scan. No hoping, no averaging down.
6. Ratchet the stop as winners run: at **+15%** unrealized, tighten to a 7% trail; at **+20%**, tighten to 5%.
7. Never move a stop down; never place it within 3% of current price.
8. **Max 3 new trades per week** (discipline cap — overtrading is the documented failure mode).
9. Follow sector momentum. Don't force a thesis if the whole sector is rolling over.
10. Exit an entire sector after 2 consecutive failed trades in it.
11. Patience beats activity. A zero-trade day (or week) can be the right answer.

## Buy-Side Gate (EVERY check must pass before any buy; log the reason on any skip)
- Total positions after this fill ≤ 6
- New trades this week (including this one) ≤ 3
- Position cost ≤ 20% of account equity ($100)
- Position cost ≤ available **settled** cash
  (cash account: do NOT buy with unsettled proceeds — avoids good-faith violations)
- A specific catalyst is documented in today's RESEARCH-LOG entry
- Instrument is a US-listed stock (not an option, not crypto, not anything else)
- A whole-share quantity ≥ 1 fits the sizing (else skip, or pick a lower-priced name)

> Note: The PDT rule was eliminated June 4, 2026 — no day-trade-count gate is needed.
> Cash-account settlement (good-faith) rules still apply, hence the "settled cash" check.

## Sell-Side Rules (evaluated at every scan + opportunistically)
- Unrealized P&L ≤ **−7%** → close immediately.
- Thesis broken (catalyst invalidated, sector rolling over, adverse news) → close even if not yet −7%.
- Up **+20%** or more → re-peg stop to a 5% trail.
- Up **+15%** or more → re-peg stop to a 7% trail.
- A sector logs 2 consecutive failed trades → exit all positions in that sector.

## Entry Checklist (agent documents ALL of these before placing)
- What is the specific catalyst today?
- Is the sector in momentum?
- What is the stop level (7–10% below entry)?
- What is the target (minimum 2:1 reward-to-risk)?

## Kill-Switch (30-day test safety)
- If total account drawdown from the $500 start reaches **−20%** (account value ≤ $400),
  halt all new buys, send a Telegram alert, and only manage/exit existing
  positions until a human reviews. New entries resume only on manual re-enable.

## Autonomy
- The agent runs autonomously. Before each buy it calls `review_equity_order`
  first (to surface buying-power / halt / alert data), applies the Buy-Side Gate,
  then places via `place_equity_order`. `review_` here is the validation gate,
  not a human-approval pause.
