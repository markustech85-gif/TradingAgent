# Trade Log

## Schema (Phase B — every routine reads/writes these)
Bucket engine + composition/de-dup/cadence/Tier-1 rules live in `memory/BUCKETS.md`.

**Open-position row** (keep one current line per open lot; this is the state the routines count):
`- SYM | bucket=<AI-complex|Energy|Outside> | qty=<N sh | $A frac> | entry=$X | stop=$X |`
`  protection=<resting ORDER_ID | software $X> | lane=<catalyst|swing> | opened=YYYY-MM-DD`
- `protection=resting <id>` → whole-share lot with a broker `stop_market` GTC resting (re-peg each run).
- `protection=software $X` → fractional lot, NO resting order; sell at the scan if price ≤ $X.

**EOD snapshot** carries a position table + two state lines:
| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
- `Book: n/4 | AI-complex a/2 · Energy e · Outside o/1 | dedup OK` — composition vs the floor.
- `Cadence: wk of YYYY-MM-DD (wk #k) | opening trades u/CAP` — CAP=4 in week 1, else 3 (BUY-to-open only).

## Jul 24 — MIDDAY scan (no actions)
Reconciled live vs book (2/4). Both lots above stops, no ratchet trigger, no thesis break. Risk-on-lean/stabilizing tape after Thursday's mega-cap AI-capex rout; both legs green on the day.
- XLE $59.725 (+8.65% vs entry; +0.58% day) — resting stop $43.98 (6a50fa5e, confirmed, 0 fills, last_txn Jul 24, ~26.4% below now). Hold. Book leader, energy extending on oil supply premium (WTI ~$91, +13% wk).
- XLV $162.895 (+0.84% vs entry; +0.90% day) — resting stop $129.22 (6a50fa42, confirmed, 0 fills, last_txn Jul 24, ~20.7% below now). Hold. Defensive ballast firming on rotation out of tech, green vs entry, far above stop.
No cuts (none ≤ −20%), no thesis breaks, no stop re-pegs (XLE +8.65% not yet at +15%; both already re-pegged at open today, last_txn Jul 24). No buy at midday (manage-only); AI-complex gap (0/2) stays open — re-entry only on a confirmed QQQ/SMH 20-DMA reclaim at a routine open (both ~3% below falling 20-DMAs per pre-mkt), not a midday chase. URA nuclear/AI-power add stays WATCH-only.
Portfolio $510.71 | equity $401.80 | cash $108.91. Drawdown +2.14% vs $500. Kill-switch OK.

## Jul 23 — MIDDAY scan (no actions)
Reconciled live vs book (2/4). Both lots above stops, no ratchet trigger, no thesis break. Risk-on-lean tape (both legs green on the day) despite pre-mkt risk-off worry.
- XLE $59.865 (+8.90% vs entry; +1.12% day) — resting stop $43.98 (6a50fa5e, confirmed, 0 fills, last_txn Jul 23, ~26.5% below now). Hold. Book leader, energy extending on Mideast supply premium / crude 6-wk high.
- XLV $161.19 (−0.21% vs entry; +1.10% day) — resting stop $129.22 (6a50fa42, confirmed, 0 fills, last_txn Jul 23, ~19.8% below now). Hold. Defensive ballast firming, rotation capital, far above stop.
No cuts (none ≤ −20%), no thesis breaks, no stop re-pegs (XLE +8.90% not yet at +15%; both already re-pegged at open today). No buy at midday (manage-only); AI-complex gap (0/2) stays open — re-entry only on a confirmed QQQ/SMH 20-DMA reclaim at a routine open (both still below falling 20-DMAs; INTC reports AMC tonight), not a midday chase.
Portfolio $509.56 | equity $400.65 | cash $108.91. Drawdown +1.91% vs $500. Kill-switch OK.

## Jul 22 — MIDDAY scan (no actions)
Reconciled live vs book (2/4). Both lots above stops, no ratchet trigger, no thesis break. Risk-off-lean tape into tonight's mega-cap AI earnings (GOOGL/TSLA/TXN AMC).
- XLE $59.08 (+7.48% vs entry; +0.99% day) — resting stop $43.98 (6a50fa5e, confirmed, 0 fills, last_txn Jul 22, ~25.6% below now). Hold. Book leader, oil firm, fresh highs vs entry.
- XLV $160.33 (−0.74% vs entry; +0.05% day) — resting stop $129.22 (6a50fa42, confirmed, 0 fills, last_txn Jul 22, ~19.4% below now). Hold. Defensive ballast, flat on the day, far above stop.
No cuts (none ≤ −20%), no thesis breaks, no stop re-pegs (XLE +7.48% not yet at +15%). No buy at midday (manage-only); AI-complex gap (0/2) stays open — re-entry only on a confirmed post-earnings 20-DMA reclaim at a routine open, not a midday chase into tonight's AI-earnings gauntlet.
Portfolio $505.58 | equity $396.67 | cash $108.91. Drawdown +1.12% vs $500. Kill-switch OK.

## Jul 21 — MIDDAY scan (no actions)
Reconciled live vs book (2/4). Both lots above stops, no ratchet trigger, no thesis break. Risk-on tape.
- XLE $58.31 (+6.08% vs entry; +0.64% day) — resting stop $43.98 (6a50fa5e, confirmed, 0 fills, last_txn Jul 21). Hold. Energy book leader, firm; new highs vs entry.
- XLV $159.28 (−1.39% vs entry; +0.02% day) — resting stop $129.22 (6a50fa42, confirmed, 0 fills, last_txn Jul 21). Hold. Defensive ballast, flat on the day, far above stop.
No cuts (none ≤ −20%), no thesis breaks, no stop re-pegs (none at +15%/+20%). No buy at midday (manage-only); AI-complex gap (0/2) stays open — re-entry on confirmation at a routine open (QQQ 20-DMA reclaim unmet at open), not a midday chase.
Portfolio $501.36 | equity $392.45 | cash $108.91. Drawdown +0.27% vs $500. Kill-switch OK.

## Jul 21 — MARKET-OPEN scan (no actions — AI re-entry deferred, ~09:30 ET)
Reconciled live vs book (2/4). Kill-switch OK ($499.15 » $250). Risk-on open (NDX-led), VIX cooling.
AI-complex gap (0/2) stayed open by design: research pre-conditioned any AI add on a 20-DMA reclaim
— NOT met. QQQ $706.78 vs 20-DMA $716.12 (−1.3%, MA falling); SMH $581.27 vs 20-DMA $605.87 (−4.1%,
MA falling). Day-4 bounce still under falling 20-DMAs into the earnings gauntlet (GOOGL Jul 22) =
textbook bull-trap; would also round-trip the SMH cut. No arm (Rule 10/12, patience). QQQ swing thesis
alive but entry trigger unconfirmed → re-check next routine open.
- XLE $58.12 (+5.72% vs entry; +0.30% day) — resting stop $43.98 (6a50fa5e, held_for_sells=4 ✓). Hold. Book leader.
- XLV $157.68 (−2.39% vs entry; −0.99% day) — resting stop $129.22 (6a50fa42, held_for_sells=1 ✓). Hold. Defensive ballast, soft on risk-on rotation, far above stop.
No cuts (none ≤ −20%), no thesis breaks, no ratchets (none at +15%/+20%), no re-pegs, no buy. Cadence unchanged (no opening trade).
Portfolio $499.15 | equity $390.24 | cash $108.91. Drawdown −0.17% vs $500. Kill-switch OK.
**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK · diversify floor met (2 non-AI legs)
**Cadence:** wk of Jul 20 (wk #3) | opening trades 0/3

## Jul 20 — MIDDAY scan (no actions)
Reconciled live vs book (2/4). Both lots above stops, no ratchet trigger, no thesis break. Risk-on/bounce tape.
- XLE $58.18 (+5.84% vs entry; +0.87% day) — resting stop $43.98 (6a50fa5e, confirmed, 0 fills). Hold. Energy book leader, firm.
- XLV $160.20 (−0.83% vs entry; −0.56% day) — resting stop $129.22 (6a50fa42, confirmed, 0 fills). Hold. Defensives soft on risk-on rotation; ballast thesis intact, far above stop.
No cuts (none ≤ −20%), no thesis breaks, no stop re-pegs (none at +15%/+20%). No buy at midday (manage-only); AI-complex gap (0/2) stays open — re-entry on confirmation at a routine open, not a midday chase.
Portfolio $501.82 | equity $392.91 | cash $108.91. Drawdown +0.36% vs $500. Kill-switch OK.

## Jul 17 — MARKET-OPEN: SMH cut — thesis-broken early exit (Rule 6, ~09:32 ET)
Global chip rout accelerated into a 4th straight down session (Nikkei −4.5%, Kospi −6%; SMH
opened −3.4% at $549.76 vs Jul 16 close $568.92). Research pre-authorized a market-open thesis
reassessment on SMH (elevated watch). Structural break CONFIRMED: price $549 decisively below
50-DMA $596.66 AND falling 20-DMA $614.30; lower lows on expanding down-volume (Jul 15 11.0M →
Jul 16 12.4M, distribution). Swing thesis (AI-complex momentum) dead + sector rolling over
(Rule 10). Exited before −20% ($483 software stop) per Rule 6.
- SMH | BUCKET=AI-complex | SELL (close) | 0.182021 sh @ $548.4301 | proceeds $99.83 vs $110 cost
  | realized −$10.17 (−9.24%) | sell ref_id 3f9c1a7e-6b24-4d58-9e0a-1c7d2f4b8a63 (order
  6a5a2ece-ef54-4073-81e0-bd19f9770dbd, filled @ $548.4301, $0 fees). Fractional lot → no resting
  stop to cancel.
- No new buy: sell proceeds unsettled today (cash account — G4 settled-cash fails) AND today's
  RESEARCH-LOG documents no catalyst for a new leg (G9). Manage-only. Cadence unchanged (SELL ≠ opening trade).
- No action on XLE (+5.5% @ $57.97) / XLV (+0.1% @ $161.76): both above stops, neither at −20% or a +15% ratchet.

**Open positions (live state — routines count these):**
- XLE | bucket=Energy | qty=4 sh | entry=$54.97 | stop=$43.98 | protection=resting 6a50fa5e-f071-4338-97a1-1a0ea355ba89 | lane=swing | opened=2026-07-10
- XLV | bucket=Outside | qty=1 sh | entry=$161.53 | stop=$129.22 | protection=resting 6a50fa42-d10b-4a94-8bd8-74beb5a96ad5 | lane=swing | opened=2026-07-10

**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK · diversify floor met (2 non-AI legs)
**Cadence:** wk of Jul 13 (wk #2) | opening trades 1/3
Portfolio $502.57 | equity $493.49 | cash $9.08 pre-sell → ~$108.91 post-sell (unsettled) | Kill-switch OK.

## Jul 14 — MARKET-OPEN: SMH AI-complex leg opened (post-CPI, ~09:31 ET)
CPI-day open: benign print → risk-on tape (SMH +3.4%, QQQ +1.0%, VRT +3.4%). Executed the
pre-market-planned AI-complex add to open the composition floor. Gate G1–G10 all PASS
(B′={XLE·en, XLV·out, SMH·ai}, |B′|=3; cadence 0→1/3). Fractional (whole share $606 > $119 cash).
- SMH | BUCKET=AI-complex | BUY | $110 fractional (0.182021 sh) | entry=$604.3248 | stop=$483.46
  (−20% SOFTWARE — no resting stop on fractional; sold at scan if price ≤ $483.46) | lane=swing
  | thesis: semis reversing up off prior rollover, AI-capex intact, CPI relief | target=$690 (+14.2%)
  | R:R structural <1:1 on 20% stop (catastrophe stop), swing thesis-driven | buy ref_id b8230870-c38c-4ba7-8fe7-7ddead90f683 (order 6a563a26, filled @ $604.3248, $0 fees)
- No action on XLE (+4.0%) / XLV (−1.3%): both above stops, neither at −20% or a +15% ratchet.

**Open positions (live state — routines count these):**
- XLE | bucket=Energy | qty=4 sh | entry=$54.97 | stop=$43.98 | protection=resting 6a50fa5e-f071-4338-97a1-1a0ea355ba89 | lane=swing | opened=2026-07-10
- XLV | bucket=Outside | qty=1 sh | entry=$161.53 | stop=$129.22 | protection=resting 6a50fa42-d10b-4a94-8bd8-74beb5a96ad5 | lane=swing | opened=2026-07-10
- SMH | bucket=AI-complex | qty=$110 frac (0.182021 sh) | entry=$604.3248 | stop=$483.46 | protection=software $483.46 | lane=swing | opened=2026-07-14

**Book:** 3/4 | AI-complex 1/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 13 (wk #2) | opening trades 1/3
Portfolio $501.99 | equity $492.92 | cash $9.08 (as of Jul 16 EOD). Kill-switch OK.

## Jul 16 — MIDDAY scan (no actions)
Reconciled live vs book (3/4). All lots above stops, no ratchet trigger, no thesis break.
- XLE $57.08 (+3.84% vs entry; +1.03% day) — resting stop $43.98 (6a50fa5e, confirmed, 0 fills). Hold. Energy back to book leader, firm.
- XLV $161.65 (+0.07% vs entry; +2.12% day) — resting stop $129.22 (6a50fa42, confirmed, 0 fills). Hold. Defensive rotation working — best day-performer, back green vs entry.
- SMH $571.69 (−5.40% vs entry; −3.23% day) — software stop $483.46. Hold, watch. Semis rolling over (below 50-DMA, AI profit-taking) as flagged pre-market; orderly correction, not structural break, AI-capex intact. Far above stop, not −20%, no thesis break.
No cuts (none ≤ −20%), no thesis breaks, no stop re-pegs (none at +15%/+20%). Cash $9.08 — no add fundable.
Portfolio $503.08 | equity $494.00 | cash $9.08. Drawdown +0.62% vs $500. Kill-switch OK.

## Jul 15 — MIDDAY scan (no actions)
Reconciled live vs book (3/4). All lots above stops, no ratchet trigger, no thesis break. PPI day.
- XLE $56.05 (+1.96% vs entry; −1.58% day) — resting stop $43.98 (6a50fa5e, confirmed, 0 fills). Hold. Energy consolidating after run, still book leader.
- XLV $159.15 (−1.47% vs entry; +0.54% day) — resting stop $129.22 (6a50fa42, confirmed, 0 fills). Hold. Defensive ballast, firm on the day.
- SMH $582.62 (−3.59% vs entry; −2.95% day) — software stop $483.46. Hold. Semis pulling back intraday but far above stop; AI-capex thesis intact, single-session move.
No cuts (none ≤ −20%), no thesis breaks, no stop re-pegs (none at +15%/+20%). Cash $9.08 — no add fundable.
Portfolio $498.47 | equity $489.40 | cash $9.08. Drawdown −0.31% vs $500. Kill-switch OK.

## Jul 14 — MIDDAY scan (no actions)
Reconciled live vs book (3/4). All lots above stops, no ratchet trigger, no thesis break.
- XLE $56.665 (+3.08% vs entry) — resting stop $43.98 (6a50fa5e, confirmed, 0 fills). Hold. Energy firm.
- XLV $158.39 (−1.94% vs entry; −1.87% on the day) — resting stop $129.22 (6a50fa42, confirmed, 0 fills). Hold. Defensives soft on CPI-day risk-on tape; thesis intact, far above stop.
- SMH $601.57 (−0.46% vs entry) — software stop $483.46. Hold. Semis flat post-open bounce.
No cuts (none ≤ −20%), no thesis breaks, no stop re-pegs (none at +15%/+20%).
Portfolio $503.62 | equity $494.55 | cash $9.08. Drawdown +0.72% vs $500. Kill-switch OK.

## Jul 13 — MIDDAY scan (no actions)
Reconciled live vs book. Both lots above stops, no ratchet trigger, theses intact.
- XLE $56.43 (+2.66% vs entry) — stop $43.98 resting (6a50fa5e, confirmed/no fills). Hold. Energy firm (+2.5% today).
- XLV $161.33 (−0.12% vs entry) — stop $129.22 resting (6a50fa42, confirmed/no fills). Hold. Defensive flat.
No cuts (neither ≤ −20%), no thesis breaks, no stop re-pegs (neither at +15%/+20%).
Portfolio $506.10 | equity $387.02 | cash $119.08. Drawdown +1.22% vs $500. Kill-switch OK.
Note: CPI tomorrow (Jul 14) = event risk; preserving $119 cash per pre-market decision.

## Jul 10 — FIRST LIVE POSITIONS OPENED (blocker cleared, ~09:57 ET)
Investor-profile gate resolved (user completed it mid-morning). Placed the two intended legs
in-session (human-approved), both filled, both protected with resting 20% stops. No API 400.

**Open positions (live state — routines count these):**
- XLE | bucket=Energy | qty=4 sh | entry=$54.97 | stop=$43.98 | protection=resting 6a50fa5e-f071-4338-97a1-1a0ea355ba89 | lane=swing | opened=2026-07-10
- XLV | bucket=Outside | qty=1 sh | entry=$161.53 | stop=$129.22 | protection=resting 6a50fa42-d10b-4a94-8bd8-74beb5a96ad5 | lane=swing | opened=2026-07-10

Fills: XLE 4 sh @ $54.97 (buy ref_id d9eb4ff9…, order 6a50fa0e…); XLV 1 sh @ $161.5299 (buy ref_id fa0f3cf0…, order 6a50fa10…). $0 fees.
Targets (≥2:1): XLE ~$62, XLV ~$178.
**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 06 (wk #1) | opening trades 2/4
Portfolio: $500.51 | equity $381.43 | cash $119.08. Kill-switch OK. Room for up to 2 more legs
(need ≤2 AI-complex to complete the floor; 2 opening trades left this week).

## Jul 10 — MIDDAY scan (no actions)
Reconciled live vs book. Both lots green-to-flat, far above stops, no ratchet trigger.
- XLE $54.63 (−0.63% vs entry) — stop $43.98 resting, intact. Hold.
- XLV $160.65 (−0.54% vs entry) — stop $129.22 resting, intact. Hold.
No cuts, no thesis breaks, no stop re-pegs (neither at +15%/+20%). Total $498.27, cash $119.08.
Kill-switch OK. Theses intact: energy relative-strength; defensive rotation as tech soft.

## Jul 10 — Market-open BLOCKED by Robinhood investor-profile gate (no fills)
First live discretionary run. Book flat, kill-switch OK ($500.49). Gate passed 2 legs
(XLE Energy, XLV Outside); QTUM/AI deferred per research. **place_equity_order returned
API 400** — Robinhood requires the account's investor profile completed before the SECOND
trade (the Jul 7 QQQ buy + Jul 9 sell = trade #1). This is an ACCOUNT-level block, not a
tool deny — ALL equity trades blocked until a human completes:
https://applink.robinhood.com/investment_profile?account_number=604803171&context=second_trade
No orders placed, no stops (no positions), no cadence used (still 0/4). Retry next run once
profile is done.
- INTENDED (not armed): XLE — Energy, BUY 4 sh @ ~$54.97 (limit $55.15 marketable), stop
  $43.98 (-20%), resting, swing lane, target $62. ref_id d3f8a1c2 (rejected).
- INTENDED (not armed): XLV — Outside, BUY 1 sh @ ~$162.56, stop $130.05 (-20%), resting,
  swing lane, target $178.

## Day 0 — EOD Snapshot (pre-launch baseline)
**Portfolio:** $500.00 | **Cash:** $475.00 | **Day P&L:** $0 | **Phase P&L:** $0
Pre-existing lot: QQQ ~0.035 shares (~$25, fractional) — to be liquidated on the
first market-open run to start clean (see PROJECT-CONTEXT.md). No agent positions yet.
Agent launches next trading day.

## Jul 09 — Fractional QQQ liquidated (first-run housekeeping, manual)
Phase 2 armed 2026-07-09 (human sign-off). Sold the pre-existing QQQ lot early, in-session,
ahead of the first live market-open run so tomorrow starts whole-shares-clean.
- SELL 0.035224 sh QQQ, market, regular hours — filled @ **$723.5513**, proceeds **$25.49**, $0 fees.
- Realized ≈ +$0.49 vs $709.74 avg cost. Order id `6a4fe9bf-204f-40fd-981a-2b7c326ad3d9`.
- Book now flat. Total **$500.49** | Cash **$500.49** ($475 settled + $25.49 unsettled, T+1).
- Note: tomorrow's buy-gate deploys against **settled** cash (~$475) until the proceeds settle.
Tonight's EOD snapshot (16:15) records the flat book live. STEP 0 will auto-skip tomorrow (lot gone).

### Jul 09 — EOD Snapshot (Day 1, Thursday)
**Portfolio:** $500.49 | **Cash:** $500.49 (100%) | **Day P&L:** +$0.49 (+0.10%) | **Phase P&L:** +$0.49 (+0.10%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| (none) | — | — | — | — | — | — | — | — |

**Book:** 0/4 | AI-complex 0/2 · Energy 0 · Outside 0/1 | dedup OK
**Cadence:** wk of Jul 06 (wk #1) | opening trades 0/4

**Notes:** Phase 2 armed today. First-run housekeeping done: liquidated the pre-existing
fractional QQQ lot (0.035 sh) at $723.55 vs $709.74 cost — cleared the book for a clean
start, netting +$0.49. No discretionary positions opened; 0 opening trades used (week-1 cap 4).
Fully in cash ($500.49; buying power $475 pending settlement). Kill-switch OK. Book is clean
and ready for first discretionary entries next session.

### Jul 10 — EOD Snapshot (Day 2, Friday)
**Portfolio:** $500.54 | **Cash:** $119.08 (23.8%) | **Day P&L:** +$0.05 (+0.01%) | **Phase P&L:** +$0.54 (+0.11%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $55.08 | +0.47% | +$0.42 (+0.19%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $160.89 | −0.79% | −$0.65 (−0.40%) | $129.22 | resting 6a50fa42 |

**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 06 (wk #1) | opening trades 2/4

**Notes:** First live positions day. Opened both intended legs at market-open (~09:57 ET) after the
investor-profile gate cleared: XLE 4 sh @ $54.97 (Energy) and XLV 1 sh @ $161.53 (Outside), each
protected with a resting 20% stop_market GTC. XLE closed slightly green (+0.19%), XLV slightly red
(−0.40%); both far above stops, neither near a ratchet trigger. Day flat (+$0.05) vs Jul 09 EOD.
Portfolio $500.54, cash $119.08. Kill-switch OK. Composition floor progressing: need ≤2 AI-complex
legs to complete it; 2 opening trades remain this week (cap 4).

### Jul 13 — EOD Snapshot (Day 3, Monday)
**Portfolio:** $508.42 | **Cash:** $119.08 (23.4%) | **Day P&L:** +$7.88 (+1.57%) | **Phase P&L:** +$8.42 (+1.68%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $56.75 | +3.03% | +$7.12 (+3.24%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $161.38 | +0.34% | −$0.15 (−0.09%) | $129.22 | resting 6a50fa42 |

**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 13 (wk #2) | opening trades 0/3

**Notes:** Strong day for Energy — XLE +3.03% on the session, lifting the position to +3.24% vs entry
and the account to a new high of $508.42 (+1.68% phase). XLV essentially flat (+0.34% day, −0.09% vs
entry), holding its defensive role. No trades today; new week (wk #2) opens 0/3 on the opening-trade
cadence. Both lots sit far above their 20% stops (resting GTC, confirmed, zero fills) and neither is
near a +15%/+20% ratchet trigger, so no stop moves. Cash held at $119.08 ahead of tomorrow's CPI
print (Jul 14) — event risk kept dry per pre-market plan. Kill-switch OK. Composition floor still
needs AI-complex legs; room for up to 2 more positions and 3 opening trades this week.

### Jul 14 — EOD Snapshot (Day 4, Tuesday)
**Portfolio:** $504.23 | **Cash:** $9.08 (1.8%) | **Day P&L:** −$4.19 (−0.82%) | **Phase P&L:** +$4.23 (+0.85%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $56.95 | +0.37% | +$7.92 (+3.60%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $158.28 | −1.94% | −$3.26 (−2.02%) | $129.22 | resting 6a50fa42 |
| SMH | AI-complex | 0.182021 | $604.32 | $600.04 | +2.46% | −$0.78 (−0.71%) | $483.46 | software (fractional) |

**Book:** 3/4 | AI-complex 1/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 13 (wk #2) | opening trades 1/3
**Notes:** Added the first AI-complex leg at market-open — SMH 0.182021 sh @ $604.32 ($110 fractional,
software stop $483.46) — advancing the composition floor to AI-complex 1/2 (book 3/4). Account slipped
−0.82% on the day to $504.23 despite a risk-on CPI-day tape: XLV rotated down −1.94% (defensives sold as
risk assets bid) and our SMH lot sits −0.71% vs entry after we bought near the intraday highs (semis +2.46%
on the session). XLE held firm (+0.37% day, +3.60% vs entry), the clear leader. No cuts (none ≤ −20%), no
thesis breaks, no ratchet triggers (none at +15%/+20%), stops unchanged. Cash drawn down to $9.08 (~98%
deployed) as planned. Kill-switch OK (+0.85% phase). Room for 1 more position and 2 opening trades this week;
one more AI-complex leg would complete the floor at ≤2.

### Jul 15 — EOD Snapshot (Day 5, Wednesday)
**Portfolio:** $501.07 | **Cash:** $9.08 (1.8%) | **Day P&L:** −$3.16 (−0.63%) | **Phase P&L:** +$1.07 (+0.21%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $56.49 | −0.81% | +$6.08 (+2.77%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $158.33 | +0.03% | −$3.20 (−1.98%) | $129.22 | resting 6a50fa42 |
| SMH | AI-complex | 0.182021 | $604.32 | $590.54 | −1.63% | −$2.51 (−2.28%) | $483.46 | software (fractional) |

**Book:** 3/4 | AI-complex 1/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 13 (wk #2) | opening trades 1/3
**Notes:** Quiet PPI-day session, account off −0.63% to $501.07 (+0.21% phase, still above the $500 start).
No trades today (wk #2 opening trades hold at 1/3). Semis extended their pullback — SMH −1.63% on the day to
$590.54, now −2.28% vs Tue's entry as the post-CPI semis pop fades. XLE gave back −0.81% but remains the book
leader at +2.77% vs entry; XLV essentially flat (+0.03%) holding its defensive ballast role at −1.98% vs entry.
No cuts (none ≤ −20%), no thesis breaks, no ratchet triggers (none at +15%/+20%), stops unchanged — XLE/XLV
resting GTC (confirmed, 0 fills), SMH software $483.46. Cash $9.08 (~98% deployed), no add fundable. Kill-switch
OK. Room for 1 more position + 2 opening trades this week; one more AI-complex leg would complete the floor at ≤2.

### Jul 16 — EOD Snapshot (Day 6, Thursday)
**Portfolio:** $501.99 | **Cash:** $9.08 (1.8%) | **Day P&L:** +$0.92 (+0.18%) | **Phase P&L:** +$1.99 (+0.40%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $57.01 | +0.90% | +$8.16 (+3.71%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $161.81 | +2.22% | +$0.28 (+0.17%) | $129.22 | resting 6a50fa42 |
| SMH | AI-complex | 0.182021 | $604.33 | $568.78 | −3.72% | −$6.47 (−5.88%) | $483.46 | software (fractional) |

**Book:** 3/4 | AI-complex 1/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 13 (wk #2) | opening trades 1/3
**Notes:** Account +0.18% to $501.99 (+0.40% phase, above the $500 start). No trades today (wk #2 opening
trades hold at 1/3). Risk-on rotation: XLV had its best day (+2.22%), flipping back green vs entry (+0.17%);
XLE +0.90% and remains the clear book leader at +3.71% vs entry. Semis kept sliding — SMH −3.72% to $568.78,
now −5.88% vs Tue's entry as the AI profit-taking pullback (below 50-DMA) extends; orderly correction, not a
structural break, AI-capex thesis intact. No cuts (none ≤ −20%; SMH worst at −5.88%), no thesis breaks, no
ratchet triggers (none at +15%/+20%). Stops unchanged — XLE/XLV resting GTC (both confirmed, re-peg last_txn
Jul 16, 0 fills), SMH software $483.46. Cash $9.08 (~98% deployed), no add fundable. Kill-switch OK. Room for
1 more position + 2 opening trades this week; one more AI-complex leg would complete the floor at ≤2.

### Jul 20 — EOD Snapshot (Day 8, Monday)
**Portfolio:** $500.34 | **Cash:** $108.91 (21.8%) | **Day P&L:** −$1.65 (−0.33%) | **Phase P&L:** +$0.34 (+0.07%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $57.95 | +0.47% | +$11.92 (+5.42%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $159.30 | −1.11% | −$2.23 (−1.38%) | $129.22 | resting 6a50fa42 |

**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 20 (wk #3) | opening trades 0/3
**Notes:** Quiet risk-on Monday, account −$1.65 to $500.34 (still +0.07% phase, essentially flat vs the
$500 start). Day P&L is measured vs the Jul 16 EOD snapshot ($501.99) — the Jul 17 (Fri) session was a
market-open-only run (SMH thesis-broken cut, realized −$10.17) with no EOD snapshot, so the −0.33% spans
Thu→Mon. Book now 2/4 after the SMH exit: XLE the clear leader at +5.42% vs entry (+0.47% day) as energy
firms; XLV soft on the risk-on rotation, −1.38% vs entry (−1.11% day) but holding its defensive ballast
role far above stop. No trades today (wk #3 opens 0/3 opening trades). No cuts (none ≤ −20%), no thesis
breaks, no ratchet triggers (neither at +15%/+20%). Stops unchanged and re-pegged today — XLE resting
$43.98 (6a50fa5e) / XLV resting $129.22 (6a50fa42), both confirmed GTC, 0 fills, last_txn Jul 20. Cash
$108.91 (~21.8%) sits idle from the unsettled SMH proceeds; AI-complex gap (0/2) stays open — re-entry
only on confirmation at a routine open, not a chase. Kill-switch OK. Room for 2 more positions + 3
opening trades this week.

### Jul 21 — EOD Snapshot (Day 9, Tuesday)
**Portfolio:** $503.62 | **Cash:** $108.91 (21.6%) | **Day P&L:** +$3.28 (+0.66%) | **Phase P&L:** +$3.62 (+0.72%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $58.52 | +0.99% | +$14.18 (+6.45%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $160.25 | +0.63% | −$1.28 (−0.79%) | $129.22 | resting 6a50fa42 |

**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 20 (wk #3) | opening trades 0/3
**Notes:** Risk-on Tuesday, account +$3.28 to $503.62 (+0.72% phase, back near session highs above the
$500 start). No trades today (wk #3 opens hold at 0/3). XLE broke out to fresh highs vs entry — +0.99%
day to $58.52, now +6.45% vs entry and firmly the book leader as energy extends. XLV firmed +0.63% on
the day but still −0.79% vs entry, holding its defensive-ballast role far above stop. We gained +0.66%
vs SPY's +0.83% — modestly behind the benchmark today, the drag being ~21.6% idle cash from the Jul 17
SMH exit. No cuts (none ≤ −20%), no thesis breaks, no ratchet triggers (XLE +6.45%, not yet at +15%).
Stops unchanged, both resting GTC confirmed (0 fills) — XLE $43.98 (6a50fa5e, ~25% below close) / XLV
$129.22 (6a50fa42, ~19% below close). AI-complex gap (0/2) stays open by design: the QQQ/SMH 20-DMA
reclaim that pre-conditions any AI re-entry was unmet at the open (bounce still under falling 20-DMAs
into the GOOGL Jul 22 earnings gauntlet) — re-check next routine open, no chase. Kill-switch OK. Room
for 2 more positions + 3 opening trades this week.

### Jul 22 — EOD Snapshot (Day 10, Wednesday)
**Portfolio:** $504.78 | **Cash:** $108.91 (21.6%) | **Day P&L:** +$1.16 (+0.23%) | **Phase P&L:** +$4.78 (+0.96%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $59.19 | +1.17% | +$16.86 (+7.67%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $159.38 | −0.54% | −$2.15 (−1.33%) | $129.22 | resting 6a50fa42 |

**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 20 (wk #3) | opening trades 0/3
**Notes:** Account +$1.16 to a fresh high of $504.78 (+0.96% phase, best close since the $500 start).
No trades today (wk #3 opens hold at 0/3). XLE kept leading — +1.17% day to $59.19, now +7.67% vs entry
and firmly the book leader as energy extends its breakout. XLV slipped −0.54% to $159.38, back to −1.33%
vs entry, still holding its defensive-ballast role far above stop. We gained +0.23% vs SPY's −0.13% —
ahead of the benchmark today, XLE's strength outrunning a flat-to-down broad tape. No cuts (none ≤ −20%),
no thesis breaks, no ratchet triggers (XLE +7.67%, not yet at +15%). Stops unchanged, both resting GTC
confirmed (0 fills, re-pegged today last_txn Jul 22) — XLE $43.98 (6a50fa5e, ~26% below close) / XLV
$129.22 (6a50fa42, ~19% below close). AI-complex gap (0/2) stays open by design: mega-cap AI earnings
land AMC tonight (GOOGL/TSLA/TXN) — the QQQ/SMH 20-DMA reclaim that pre-conditions any AI re-entry stays
the trigger, re-check next routine open post-earnings, no chase. Cash $108.91 (~21.6%) idle by design
into the event. Kill-switch OK. Room for 2 more positions + 3 opening trades this week.

### Jul 23 — EOD Snapshot (Day 11, Thursday)
**Portfolio:** $508.28 | **Cash:** $108.91 (21.4%) | **Day P&L:** +$3.50 (+0.69%) | **Phase P&L:** +$8.28 (+1.66%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $59.40 | +0.33% | +$17.70 (+8.05%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $161.41 | +1.24% | −$0.12 (−0.07%) | $129.22 | resting 6a50fa42 |

**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 20 (wk #3) | opening trades 0/3
**Notes:** Strong relative day — account +$3.50 to a fresh high of $508.28 (+1.66% phase, best close since
the $500 start) while the broad tape sold off hard. SPY fell −1.23% on the mega-cap AI earnings reaction /
risk-off unwind, yet our defensive-energy book rose: we gained +0.69% vs SPY −1.23%, ~1.9 pts AHEAD of the
benchmark today — exactly the ballast the composition floor is built for. XLV was the standout, +1.24% on the
day to $161.41 as defensive rotation capital bid up healthcare while risk assets sold; now essentially flat
vs entry (−0.07%). XLE ground +0.33% to a fresh high of $59.40, firmly the book leader at +8.05% vs entry as
energy extends on crude strength (Mideast supply premium, 6-wk highs). No trades today (wk #3 opens hold at
0/3). No cuts (none ≤ −20%), no thesis breaks, no ratchet triggers (XLE +8.05%, not yet at +15%). Stops
unchanged, both resting GTC confirmed (0 fills, re-pegged today last_txn Jul 23) — XLE $43.98 (6a50fa5e, ~26%
below close) / XLV $129.22 (6a50fa42, ~20% below close). AI-complex gap (0/2) stays open by design: the
QQQ/SMH 20-DMA reclaim that pre-conditions any AI re-entry remains unmet (both still under falling 20-DMAs;
INTC reported AMC tonight) — re-check next routine open, no chase. Cash $108.91 (~21.4%) idle by design.
Kill-switch OK. Room for 2 more positions + 3 opening trades this week.

### Jul 24 — EOD Snapshot (Day 12, Friday)
**Portfolio:** $510.31 | **Cash:** $108.91 (21.3%) | **Day P&L:** +$2.03 (+0.40%) | **Phase P&L:** +$10.31 (+2.06%)

| Ticker | Bucket | Shares | Entry | Close | Day Chg | Unrealized P&L | Stop | Protection |
| — | — | — | — | — | — | — | — | — |
| XLE | Energy | 4 | $54.97 | $59.61 | +0.38% | +$18.54 (+8.43%) | $43.98 | resting 6a50fa5e |
| XLV | Outside | 1 | $161.53 | $162.56 | +0.69% | +$1.03 (+0.63%) | $129.22 | resting 6a50fa42 |

**Book:** 2/4 | AI-complex 0/2 · Energy 1 · Outside 1/1 | dedup OK
**Cadence:** wk of Jul 20 (wk #3) | opening trades 0/3
**Notes:** Fresh high to close the week — account +$2.03 to $510.31 (+2.06% phase, best close since the
$500 start). Both legs green on a quiet, risk-on-lean Friday tape and we beat the benchmark: we gained
+0.40% vs SPY's +0.09%, ~0.3 pts AHEAD today. XLE stayed the book leader, +0.38% day to $59.61 and now
+8.43% vs entry as energy extends on the oil supply premium (WTI firm). XLV firmed +0.69% to $162.56,
flipping green vs entry (+0.63%) as defensive rotation capital keeps bidding healthcare. No trades today
(wk #3 opens hold at 0/3). No cuts (none ≤ −20%), no thesis breaks, no ratchet triggers (XLE +8.43%, not
yet at +15%). Stops unchanged, both resting GTC confirmed (0 fills, re-pegged today last_txn Jul 24) —
XLE $43.98 (6a50fa5e, ~26% below close) / XLV $129.22 (6a50fa42, ~21% below close). AI-complex gap (0/2)
stays open by design: the QQQ/SMH 20-DMA reclaim that pre-conditions any AI re-entry remains unmet (both
still under falling 20-DMAs, ~3% below per today's reads) — re-check next routine open, no chase. Cash
$108.91 (~21.3%) idle by design. Kill-switch OK. Room for 2 more positions + 3 opening trades this week.
