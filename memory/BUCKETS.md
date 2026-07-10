# Bucket Engine — deterministic classification, composition gate, cadence

Operational lookup + algorithm that turns the STRATEGY.md §"Composition Floor" and §"Watchlist"
into mechanical checks. **STRATEGY.md is the source of truth**; this file is its flattened,
machine-usable form. No ETF-holdings API exists — this is curation, not a live lookup. Every
routine reads this file to classify candidates and enforce the floor across stateless runs.

Stocks & ETFs only. No options, no crypto — ever.

---

## 1. Ticker → bucket lookup (flattened watchlist)

Legend: `kind` = ETF | single | absorbed. `absorbed` = do NOT buy individually — hold the named
ETF instead (de-dup). `dedup-group` = tickers that block each other (hold at most one).

### AI-complex  (cap ≤ 2 slots)
| Ticker | kind | dedup-group | note |
| — | — | — | — |
| QQQ | ETF | broad-AI | broad Nasdaq-100 |
| SMH | ETF | broad-AI | semis; substitute for QQQ (heavy overlap) |
| QTUM | ETF | quantum | quantum tilt — may accompany one broad-AI ETF |
| VRT | single | ai-power-single | data-center power; rides AI-capex |
| NVDA AMD INTC MU AVGO TSM QCOM TXN ON MRVL SMCI ARM | absorbed→SMH | broad-AI | semis → buy SMH |
| WDC STX | absorbed→SMH | broad-AI | storage → buy SMH |
| IONQ RGTI QBTS QUBT | absorbed→QTUM | quantum | quantum pure-plays → buy QTUM |
| ORCL PLTR GOOGL AMZN | absorbed→QQQ | broad-AI | mega-cap AI → buy QQQ |

### Energy  (≥ 1 required — the in-list diversifier)
| Ticker | kind | dedup-group | note |
| — | — | — | — |
| XLE | ETF | oil-gas | oil & gas |
| URA | ETF | uranium | uranium |
| VST CEG OKLO SMR | single | (none — independent of the ETFs) | AI-power / nuclear, NOT inside XLE/URA |
| XOM CVX OXY COP SLB DVN | absorbed→XLE | oil-gas | oil & gas single → buy XLE |
| CCJ | absorbed→URA | uranium | uranium single → buy URA |

### Outside  (exactly 1 slot — outside AI-complex & Energy)
| Ticker | kind | dedup-group | note |
| — | — | — | — |
| UFO | ETF | outside | space-economy — primary Outside pick |
| XLV XLF XLI GLD GDX XLP | ETF | outside | rotating alternates (agent picks by momentum) |
| *(off-list Outside name)* | single/ETF | outside | ALLOWED only via the Tier-1 gate (§5) |

Avoid leveraged / inverse ETFs (e.g. SOXL) — daily-leverage decay. Not on any list.

**Classify any candidate:**
1. On a list above → use that bucket. `absorbed` → REJECT the single, note "buy <ETF> instead".
2. Not listed & bucket is AI-complex or Energy → REJECT (watchlist is curated; don't invent names).
3. Not listed & plausibly Outside → allowed ONLY through the §5 Tier-1 gate (bucket = Outside).

---

## 2. De-dup adjacency (which holdings block a candidate)

Reject a candidate whose `dedup-group` is already represented in the book:
- **broad-AI:** QQQ and SMH are substitutes — hold **at most one**. Holding either blocks the other
  and blocks every absorbed→SMH / absorbed→QQQ single.
- **quantum:** QTUM blocks IONQ/RGTI/QBTS/QUBT.
- **oil-gas:** XLE blocks XOM/CVX/OXY/COP/SLB/DVN.
- **uranium:** URA blocks CCJ.
- Energy singles (VST/CEG/OKLO/SMR) carry no group — they are independent of the ETFs, so they do
  NOT collide with XLE/URA or each other.
- Never hold an ETF and a same-bucket single that the ETF contains (the `absorbed` rows encode this).

---

## 3. Composition gate — run on the *hypothetical post-fill book* B′

Let B′ = current open positions + this candidate. Counts by bucket: `ai`, `en`, `out`.
Evaluate in order; first failure REJECTS the buy (log the reason). All must PASS.

| # | Check | REJECT if |
| — | — | — |
| G1 | Instrument | not a US-listed stock/ETF (option/crypto) |
| G2 | Position count | \|B′\| > 4 |
| G3 | Cadence (§4) | opening trades this week + 1 > CAP (4 in week 1, else 3) |
| G4 | Sizing | cost > $250 (50% equity) OR cost > settled cash (buying_power) |
| G5 | Bucket cap | ai > 2  OR  out > 1 |
| G6 | Diversify floor | \|B′\| ≥ 2 and non-AI-complex (en+out) = 0  → REJECT (all-AI book) |
| G7 | Energy on track | \|B′\| = 4 and en = 0  → REJECT (can't meet ≥1 Energy floor) |
| G8 | De-dup (§2) | candidate's dedup-group already represented in the book |
| G9 | Catalyst | no catalyst for it in today's RESEARCH-LOG (same-day hard OR multi-day swing) |
| G10 | Off-list Outside | off-watchlist Outside without the §5 Tier-1 confirmation |

If PASS → **protection routing (not a reject):** one whole share ≤ per-position budget → whole-share
lot + **resting** stop; else fractional (dollar-sized) lot + **software** stop. (§ STRATEGY Order Mechanics.)

**Full-deployment floor (target end-state at 4 positions):** ai ≤ 2 · en ≥ 1 · out = 1. G5–G7 keep
the book able to reach it; don't fill the 4th slot in a way that breaks it.

---

## 4. Cadence tracking (opening trades only — sells don't count)

- **Week** = calendar week, Monday–Sunday (America/New_York).
- **Week 1** = the calendar week containing the agent's FIRST opening trade (build-out exception).
  CAP = **4** opening trades that week. Every week after: CAP = **3**.
- Count opening (BUY-to-open) trades logged in TRADE-LOG for the current week; compare to CAP in G3.
- TRADE-LOG carries a `Cadence:` line (see TRADE-LOG schema) — read it, don't recompute from scratch
  unless it's stale. A re-entry after a full exit is a new opening trade (counts).

---

## 5. Off-watchlist Outside — Tier-1 gate

An Outside name NOT in §1 may be entered only if BOTH hold and are logged in RESEARCH-LOG:
1. A documented **multi-day catalyst** (sector rotation, sustained theme, post-earnings drift — not
   a single intraday headline).
2. **≥1 confirming Tier-1 indicator**, computed from Robinhood read tools:
   - **Trend:** price > its rising moving average (e.g. 20/50-day) via `get_equity_historicals`.
   - **Volume:** recent volume ≥ its average (accumulation) via `get_equity_historicals`.
   - **Sector momentum:** the name's sector ETF trending up (relative strength).
   - (`get_equity_fundamentals` may corroborate; it is not itself a Tier-1 trend signal.)
Log which indicator confirmed. No Tier-1 confirmation → the name is NOT eligible (G10 rejects it).
This gate is Outside-only: AI-complex and Energy stay strictly on the curated watchlist.

---

## 6. Worked checks (sanity — flat book, buying_power $475)

- **QQQ** (AI, ETF, ~$723): classify AI-complex. 1 whole share $723 > $250 budget → route to a
  FRACTIONAL dollar-sized lot (e.g. $200): G4 cost $200 ≤ $250 ≤ cash → PASS → fractional +
  **software** stop @ 20% below fill. (A whole-share QQQ lot is impossible at $500 — the ceiling caps it.)
- **XLE** (Energy, ETF, ~$56): AI/en/out = 0/1/0. G-checks pass; 1 share $56 ≤ $250 ≤ cash →
  whole-share + **resting** stop @ 20% below.
- **NVDA** (absorbed→SMH): §1 step 1 → REJECT single, "buy SMH instead" (de-dup).
- **2nd buy = QTUM while long QQQ, no diversifier:** post-fill ai=2, en+out=0, \|B′\|=2 →
  G6 REJECT (all-AI two-book; need an Energy/Outside leg first).
- **3rd buy = SMH while long {QQQ, XLE}:** ai=2·en=1 clears G5/G6/G7 → G8 de-dup REJECT
  (QQQ already holds the broad-AI slot; SMH is its substitute). Isolates the de-dup gate.
- **Off-list Outside (e.g. XLU) with only an intraday headline:** G10 REJECT (no multi-day catalyst
  + Tier-1 indicator logged).
