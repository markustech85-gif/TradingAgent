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
