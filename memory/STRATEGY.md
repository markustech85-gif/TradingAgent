# Trading Strategy — 30-Day Test

## Mission
Beat the S&P 500 over the 30-day test window. Disciplined but aggressive.
US-listed stocks and ETFs only — no options, no crypto. Discipline is the hard part.

## Account & Capital
- Broker: Robinhood (agentic MCP, `Robhinhood` namespace)
- Account: #604803171 (agentic-enabled, cash account)
- Starting capital: ~$500
- Instruments: US-listed equities and ETFs ONLY

## Position Sizing & Composition (aggressive / concentrated)
- **Max 4 concurrent positions.**
- **Fully deployed** — target ~100% invested; whole-share rounding remainder stays in cash.
  Deploy fully ONLY across positions that pass the gate — never force a trade to hit 4.
- **Per-position ceiling ≤ 50% of equity (~$250 at start).** At 4 positions ≈ 25% each;
  50% is a ceiling, not a target.
- **Fractional shares ENABLED — with a HYBRID stop model (see Order Mechanics):**
  - **Whole share + real resting broker stop** whenever one whole share fits the per-position
    budget. PREFERRED — the stop rests at the broker 24/7.
  - **Fractional (dollar-sized) + software stop** for higher-priced names where a whole share
    doesn't fit the budget. Robinhood does NOT allow a resting stop on a fractional lot, so the
    stop is enforced by the agent at each scan; between-scan gap risk is accepted for these lots.
  - Tag every position's protection type in TRADE-LOG (`resting` vs `software`).

## Composition Floor (diversification — enforced by bucket)
Every ticker maps to exactly one bucket (see Watchlist). The flattened ticker→bucket lookup, the
de-dup adjacency, the ordered buy-gate (G1–G10), cadence counting, and the off-list Tier-1 gate are
operationalized in **`memory/BUCKETS.md`** — the routines run that as the deterministic engine.
At full deployment:
- **≤2 AI-complex** + **≥1 Energy** + **exactly 1 Outside** → AI capped ~50%, two uncorrelated legs.
- Partial book (<4): whenever ≥2 positions are held, at least one must be a non-AI-complex leg
  (Energy or Outside).
- **De-dup rule:** never hold an ETF and a single name from the SAME bucket/theme at once
  (e.g., SMH + a semi single, XLE + an oil&gas single). Broad AI ETFs (QQQ, SMH) are substitutes —
  hold at most one broad + an optional tilt; never stack heavy overlaps.

## Watchlist (curated; de-dup already applied — do NOT re-add absorbed names)
Prices move — verify live quotes each run. "Fits whole-share" = 1 share ≤ per-position budget;
otherwise buy fractional (software stop).

**AI-complex bucket (cap ≤2 slots; ETFs are substitutes — no stacking overlaps):**
- ETFs: QQQ (broad Nasdaq-100) · SMH (semis) · QTUM (quantum)
- Single: VRT (data-center power; rides AI-capex → counts as AI-complex)
- Absorbed → do NOT buy individually: all semis (NVDA/AMD/INTC/MU/AVGO/TSM/QCOM/TXN/ON/MRVL/
  SMCI/ARM), storage (WDC/STX), quantum pure-plays (IONQ/RGTI/QBTS/QUBT), ORCL/PLTR, GOOGL/AMZN.

**Energy bucket (≥1 required — the in-list diversifier):**
- ETFs: XLE (oil & gas) · URA (uranium)
- Singles (AI-power / nuclear, not in the ETFs): VST · CEG · OKLO · SMR
- Absorbed → do NOT buy individually: XOM/CVX/OXY/COP/SLB/DVN (→XLE), CCJ (→URA).

**Outside bucket (exactly 1 slot — outside AI-complex & Energy):**
- Primary: UFO (space-economy ETF)
- Rotating alternates (agent picks by momentum): XLV (healthcare) · XLF (financials) ·
  XLI (industrials) · GLD/GDX (gold) · XLP (staples)
- Agent may propose an off-watchlist Outside name: requires a documented multi-day catalyst AND
  ≥1 confirming Tier-1 indicator (trend vs moving average, volume, sector momentum) in RESEARCH-LOG.
- Avoid leveraged/inverse ETFs (e.g., SOXL) — daily leverage decays.

## Two Entry Lanes
Both pass the full Buy-Side Gate and carry the same stop.
1. **Same-day catalyst lane:** a specific hard catalyst today (earnings, launch, contract, news).
2. **Swing lane:** a multi-day thesis (sector momentum building, post-earnings drift, trend
   pullback, breakout continuation). A multi-day catalyst is valid entry evidence — need not be same-day.

## Order Mechanics on Robinhood
Order types: `market`, `limit`, `stop_market`, `stop_limit`. NO native trailing stop.
Fractional orders are `market`-only, regular-hours-only, and CANNOT carry a resting stop.
- **Entry (whole-share lot):** marketable limit at the current ask — regular hours.
- **Entry (fractional lot):** market order, dollar-sized — regular hours.
- **Protective stop — HYBRID:**
  - *Whole-share lot:* place `stop_market` GTC at **20% below fill**. Each run, if the position
    rose, re-peg up (cancel old, place new) at the current trail distance. Rests at the broker 24/7.
  - *Fractional lot:* no resting stop possible. Record a **software stop** level (20% below fill)
    in TRADE-LOG; at EVERY scan, if price ≤ the software stop, sell (market) immediately.
  - Never move a stop down. Never set a stop within 3% of current price.
- **Exit:** market (or marketable limit) sell, THEN cancel any resting stop for that symbol.

## Core Rules (non-negotiable)
1. No options. No crypto. US-listed stocks & ETFs only.
2. Max 4 open positions; each ≤ 50% ($250) of equity.
3. Fully deployed (~100%; whole-share remainder in cash). Composition floor + de-dup per above.
4. Every open position carries a stop starting **20% below entry** — resting (whole-share) or
   software-enforced at each scan (fractional).
5. Cut losers at **−20% from entry** — the agent closes at the scan. No hoping, no averaging down.
6. **Thesis-broken early exit:** if the trade reason dies (catalyst invalidated, sector rolling
   over, adverse news), close even if not yet −20%.
7. Ratchet winners: at **+15%** unrealized → 7% trail; at **+20%** → 5% trail.
8. Never move a stop down; never place it within 3% of current price.
9. **Trade cadence:** up to **4 opening trades in the first calendar week** (initial build-out
   exception); **≤3 new trades/week** steady-state thereafter. Overtrading is the documented failure mode.
10. Follow sector momentum. Don't force a thesis if the whole sector is rolling over.
11. Exit an entire bucket/sector after 2 consecutive failed trades in it.
12. Patience beats activity. A zero-trade day (or week) can be the right answer.

## Buy-Side Gate (EVERY check must pass; log the reason on any skip)
- Total positions after this fill ≤ 4
- New trades this week ≤ the cadence cap (4 in week 1, else 3)
- Position cost ≤ 50% of account equity ($250)
- Position cost ≤ available **settled** cash (cash account: no unsettled proceeds)
- Composition preserved: won't push AI-complex beyond 2; Energy ≥1 kept (or on track); the
  Outside slot stays outside AI-complex + Energy
- De-dup preserved: not already holding the overlapping ETF (or a same-bucket single) for this name
- A catalyst is documented in today's RESEARCH-LOG (same-day hard catalyst OR multi-day swing thesis)
- Off-watchlist Outside name: also has ≥1 confirming Tier-1 indicator logged
- Instrument is a US-listed stock or ETF (not an option, not crypto)
- Whole-share qty ≥1 fits the budget → whole-share + resting stop; else fractional + software stop

> PDT rule eliminated June 4 2026 — no day-trade-count gate. Cash-account settlement (good-faith)
> rules still apply, hence the "settled cash" check.

## Sell-Side Rules (evaluated every scan + opportunistically)
- Unrealized P&L ≤ **−20%** → close immediately (resting stop covers whole-share lots between
  scans; fractional lots are closed at the scan).
- Thesis broken (catalyst invalidated, sector rolling over, adverse news) → close even if not yet −20%.
- Up **+20%** or more → re-peg (whole-share) / record (fractional) stop to a 5% trail.
- Up **+15%** or more → re-peg / record stop to a 7% trail.
- A bucket/sector logs 2 consecutive failed trades → exit all positions in it.

## Entry Checklist (agent documents ALL before placing)
- Catalyst: what is it, and is it same-day or a multi-day thesis?
- Is the sector/bucket in momentum?
- Which bucket does this fill, and does the resulting book meet the composition floor + de-dup?
- Off-watchlist? Which confirming Tier-1 indicator supports it?
- Whole-share (resting stop) or fractional (software stop)? Stop level (20% below entry) and
  target (minimum 2:1 reward-to-risk)?

## Kill-Switch (30-day test safety)
- If total account drawdown from the $500 start reaches **−50% (account value ≤ $250)**, halt all
  new buys, send a Telegram alert, and only manage/exit existing positions until a human reviews.
  New entries resume only on manual re-enable.

## Autonomy
- The agent runs autonomously. Before each buy it calls `review_equity_order` first (to surface
  buying-power / halt / alert data), applies the Buy-Side Gate, then places via `place_equity_order`.
  `review_` here is the validation gate, not a human-approval pause.
