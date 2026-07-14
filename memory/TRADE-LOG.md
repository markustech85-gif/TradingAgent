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
Portfolio $507.22 | equity $388.14 → ~$498 deployed post-fill | cash ~$9. Kill-switch OK.

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
