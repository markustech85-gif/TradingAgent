# Phase B Build Handoff — Composition Engine, Bifurcated Stops, Watchlist Research

Self-contained so a fresh chat can build **Phase B** of the strategy overhaul cleanly. Phase A
(the spec + mechanical rule/scope swaps) is DONE and lives on branch
`claude/trading-agent-monitor-j5e80o` (PR open against `main`). This packet is what's left.

## 0. Read these first (on the branch, in order)
- `memory/STRATEGY.md` — the authoritative rewritten rulebook (Phase A). Everything below enforces it.
- `CLAUDE.md` — agent mission + quick-rules + Phase-2 toggle.
- `routines/*.md` — the four cron prompts (pre-market, market-open, midday, daily-summary).
- `memory/TRADE-LOG.md` — current book (flat, all cash) + EOD snapshot format.
- `docs/SESSION-HANDOFF.md` — infra/VM state and go-live procedure.

## 1. System in one paragraph
Live ~$500 Robinhood cash account (#604803171, agentic MCP, namespace `Robhinhood` — typo is
intentional, preserve it). Claude *is* the bot: four cron routines/weekday on an always-on VM
(146.190.68.23, user `trader`, runs from `main`, **does NOT auto-pull**). **Phase 2 is LIVE** —
equity order tools armed; all option tools denied permanently (stocks & ETFs only). Book is
currently **flat, all cash (~$500.49; $475 settled + unsettled QQQ proceeds)**. Memory = git on `main`.

## 2. What Phase A already did (do NOT redo)
- Rewrote `memory/STRATEGY.md` to the new concentrated design.
- Mechanically synced every dependent file: `CLAUDE.md`, all `routines/*`, all `.claude/commands/*`,
  `PROJECT-CONTEXT.md`, `README.md`, `docs/HANDOFF.md`, `docs/VM-DEPLOYMENT.md`, `docs/SESSION-HANDOFF.md`
  (kill-switch $400→$250, stop 10%→20%, cut −7%→−20%, ETF scope, hybrid-stop notes, ratchet math fix).
- Added high-level hybrid/composition *pointers* to routine STEPs so nothing instructs an impossible
  fractional resting stop. **The deterministic enforcement logic is intentionally NOT built yet — that's Phase B.**

## 3. Locked design decisions (settled — do NOT re-litigate)
- **Instruments:** US stocks + ETFs. No options/crypto, ever.
- **Sizing:** max **4 positions**, ≤**50%/$250** each, ~**100% deployed**.
- **Fractional ENABLED + HYBRID stops:** whole-share lot → **resting `stop_market` GTC** (20% below);
  fractional lot → **software stop** (20% below) checked/sold at each scan (Robinhood can't rest a stop
  on a fractional lot — confirmed from the tool schema: fractional = market-only, regular-hours-only).
- **Composition floor (by bucket):** ≤2 **AI-complex** + ≥1 **Energy** + exactly 1 **Outside**.
  Partial book: whenever ≥2 held, ≥1 must be non-AI-complex.
- **De-dup:** never hold an ETF and a same-bucket single together; broad AI ETFs (QQQ/SMH) are
  substitutes (no stacking heavy overlaps).
- **Bucket map (deterministic lookup — this is the key to making enforcement tractable):**
  - **AI-complex:** QQQ, SMH, QTUM (ETFs) + VRT (single). Absorbed (never buy as singles): all semis,
    WDC/STX, quantum pure-plays, ORCL/PLTR, GOOGL/AMZN.
  - **Energy:** XLE, URA (ETFs) + VST, CEG, OKLO, SMR (singles). Absorbed: XOM/CVX/OXY/COP/SLB/DVN (→XLE), CCJ (→URA).
  - **Outside:** UFO (space, primary) + rotating sector ETF (XLV/XLF/XLI/GLD/GDX/XLP). Off-watchlist
    Outside names allowed with a multi-day catalyst + ≥1 Tier-1 indicator.
- **Two entry lanes:** same-day hard catalyst OR multi-day swing thesis.
- **Cadence/ramp:** up to **4 opening trades in week 1**, then **≤3 new trades/week**.
- **Cut −20%; ratchet 7% trail at +15%, 5% at +20%; kill-switch $250 (−50%).**

## 4. Phase B scope — what to BUILD
1. **Composition/bucket engine (the core):**
   - Bake the §3 bucket map into the routines (or a shared reference) as a ticker→bucket lookup so
     the agent classifies any candidate deterministically (no ETF-holdings API exists — curation, not lookup).
   - Buy-gate additions in `routines/market-open.md`: reject a buy that would (a) exceed ≤2 AI-complex,
     (b) leave the book without ≥1 Energy on track, (c) fill the Outside slot with a non-Outside name,
     or (d) violate de-dup (already hold the overlapping ETF or a same-bucket single).
2. **Per-position tags in `memory/TRADE-LOG.md` schema:** add **bucket** (AI-complex/Energy/Outside)
   and **protection** (`resting <order_id>` vs `software <stop_level>`) to each position row, and to the
   EOD snapshot table. Every routine reads these to count composition and enforce stops across runs.
3. **Bifurcated stop handling (make the STEP logic real, not just pointers):**
   - market-open: whole-share → place resting stop; fractional → record software stop level.
   - midday/EOD: for fractional lots, if price ≤ recorded software stop, SELL (market) at the scan;
     for whole-share lots, re-peg the resting stop. Ratchet both (5%/7%). Never move a stop down / within 3%.
4. **Watchlist-driven research in `routines/pre-market.md`:** scan the §3 buckets, propose ≤3 candidates
   incl. the Outside diversifier, tag each idea's bucket + lane, verify whole-share-fit vs budget (fractional if pricier).
5. **Off-watchlist Tier-1 gate:** an Outside name not on the list needs a multi-day catalyst AND ≥1
   confirming Tier-1 indicator (trend vs moving average via `get_equity_historicals`, volume, or sector
   momentum) logged in RESEARCH-LOG. Tools are already allow-listed (`get_equity_historicals`, `get_equity_fundamentals`).
6. **Cadence tracking:** implement the week-1 (=4) vs steady-state (≤3) opening-trade count (calendar-week based).

## 5. Test before going live (required)
- Dry-run each routine locally via the `.claude/commands/*` test copies (or `claude -p` against the branch)
  with the current flat book — confirm: bucket classification, composition rejects, de-dup rejects, a
  simulated fractional software-stop trigger, and a whole-share resting-stop placement all behave.
- Do NOT let this touch `main`/VM until the dry-run passes and the user reviews.

## 6. Go-live sequence (after Phase B is approved)
1. Merge the PR (A+B) to `main`.
2. On the VM (SSH from the **Mac only**): `cd ~/trading-agent && git pull origin main` — confirm HEAD.
3. Next market-open runs the full new engine. (STEP 0 QQQ liquidation already done — auto-skips.)

## 7. Gotchas (read before changing anything)
- **VM runs `main` and does NOT auto-pull.** Nothing is live until merged to `main` AND pulled on the VM.
- **Timing risk:** if the VM's next 09:30 market-open fires before A+B is merged+pulled, it runs the
  OLD `main` rules. Either finish + pull before the next open, or pause cron / disarm until ready.
- **Preserve the `Robhinhood` namespace typo** — tool names are `mcp__Robhinhood__*`.
- **`.claude/settings.json` `deny` is the live trading gate** (bypassPermissions runner). Equity order
  tools are OUT (armed); all option tools must STAY denied.
- **SSH only from the Mac.** Stocks & ETFs only. Cash-account: settled cash only (T+1).
- **Memory/strategy commits go to `main`** (authorized), but Phase B should land via this PR after review.

## 8. Kickoff prompt for the fresh chat
> Continue the trading-agent strategy overhaul — build **Phase B**. Read `docs/PHASE-B-HANDOFF.md`
> (this file) and the files it lists on branch `claude/trading-agent-monitor-j5e80o`. Phase A (the spec
> in STRATEGY.md + mechanical swaps) is done and in an open PR. Build the composition/bucket engine,
> the TRADE-LOG bucket+protection tags, the bifurcated (resting vs software) stop logic in the routine
> STEPs, watchlist-driven pre-market research, and the off-watchlist Tier-1 gate — per §4. Dry-run
> locally against the current flat book before anything touches `main` or the VM, and show me the diff.
> Don't re-litigate the §3 locked decisions. Preserve the `Robhinhood` typo. Stocks & ETFs only.
