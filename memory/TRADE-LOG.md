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
