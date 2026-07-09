# Building an Autonomous AI Trading Agent — A Plain-English Training Guide

*How we set up an AI that researches the market and manages a real brokerage account on its
own, running 24/7 on its own server. Written so a motivated friend could understand it — and
replicate it — without being a professional engineer.*

> **Scope note:** This guide is about *how the agent works and how it was built* — the plumbing,
> the safety design, and the setup steps. It deliberately does **not** cover the investment
> strategy itself (what to buy, when, position sizing). Think of this as "here's the robot and
> how we wired it up," not "here's how it picks stocks."

---

## 1. The one-paragraph version (for your friends)

We built an AI agent that wakes up on a schedule four times every weekday, logs into a real
Robinhood brokerage account, pulls the live portfolio, researches the market, decides what to do
under a strict set of rules, writes down its reasoning, and texts a short summary to a phone.
It runs entirely on its own small cloud server — no laptop needed, no human clicking buttons.
The AI *is* the trading bot: instead of writing thousands of lines of custom software, we gave a
capable AI (Claude) a rulebook and a set of tools and let it operate the account directly. Right
now it's in a **safe "read-only" mode** where it does everything *except* actually place orders,
so we can watch it behave before trusting it with live trades.

---

## 2. The core idea: "the AI is the bot"

Traditional trading bots are big custom programs: you write code for every decision, every API
call, every edge case. Ours is different. The insight is simple:

> Give a capable AI a **rulebook**, a set of **tools** (look up prices, read the account, place
> an order, send a message), and a **schedule** — and it can run the whole operation itself.

Each scheduled run is a **fresh, independent session**. The AI starts with no memory of last
time. So how does it remember open positions, yesterday's decisions, and its own rules? Three
design choices make that work:

1. **Memory lives in files, not in the AI's head.** Everything — the rulebook, the trade log,
   the research notes — is plain text saved in a version-controlled folder (via *Git*, explained
   later). Every run's first job is to *read* those files; its last job is to *write* updates back.
2. **Every run is self-contained.** If one run fails (network hiccup, server reboot), the next
   one just reads the saved state and picks up cleanly. Nothing is "half done" in memory.
3. **The rules are checked every single time, in the instructions themselves.** Discipline isn't
   assumed — the AI re-reads the guardrails before every action.

This is why it's reliable enough to trust with money: it's stateless, auditable, and rule-bound
by design.

---

## 3. The cast of characters (the "stack")

Here's every moving part, in plain terms, and why it's there.

| Piece | What it is | Its job here | Everyday analogy |
|---|---|---|---|
| **Claude / Claude Code** | A capable AI ("Claude") wrapped in a tool ("Claude Code") that can read files, run commands, and use tools. | The brain and hands of the agent. | The employee doing the work. |
| **Robinhood agentic account** | A special brokerage account type that *allows an AI agent to act on it*. | Holds the real money and executes trades. | The bank account. |
| **MCP connector** | "Model Context Protocol" — a standard way to plug tools into an AI. | How Claude talks to Robinhood (check prices, read portfolio, place orders). | The universal adapter between the employee and the bank. |
| **The VM (server)** | A small always-on computer in the cloud (we used DigitalOcean). | The agent's permanent home so it runs 24/7 without a laptop. | The office that's always open. |
| **Cron** | A built-in "alarm clock" on the server. | Fires the agent on a schedule (4× per weekday). | The alarm that says "time to work." |
| **Git + GitHub** | Version-control: tracks every change to files, with full history. | The agent's memory and audit trail. | The filing cabinet that keeps every draft. |
| **Telegram** | A messaging app with a free "bot" feature. | How the agent texts you summaries and alerts. | The employee's text messages to the boss. |
| **Perplexity** | An AI-powered research/search service. | Where the agent gets market news and catalysts. | The research assistant. |
| **API key / OAuth** | Two ways of proving "I'm allowed to use this." | Let the agent log into Anthropic, Robinhood, etc. | The keycard and the signed permission slip. |

You don't need to master each one — but understanding the roles makes the rest click.

### A closer look at MCP (because it's the clever bit)

**MCP** stands for *Model Context Protocol*. It's an open standard — think of it like a USB port
for AI. Any service that "speaks MCP" can be plugged into an AI, and the AI can then use that
service's tools. Robinhood publishes an MCP "connector" (a web address the AI connects to), and
once it's plugged in, Claude gets a menu of Robinhood actions it can call directly:

- *get_portfolio* — how much money and buying power is in the account
- *get_equity_positions* — what stocks are held right now
- *get_equity_quotes* — the live price of a stock
- *review_equity_order* — simulate an order (dry run) before placing it
- *place_equity_order* — actually buy or sell (real money)
- *cancel_equity_order* — cancel a resting order

The key point: **the AI calls these like an app calls a function.** There's no custom "trading
program" we had to write — Robinhood provides the tools, and Claude uses them.

---

## 4. What the agents actually do (the four daily routines)

The agent isn't one thing running constantly — it's the *same* agent woken up at four specific
times each weekday, each time with a slightly different job. Each job is described in a plain-text
"prompt" file (its instructions for that run).

| Time (Eastern) | Routine | What it does | What you receive |
|---|---|---|---|
| **8:00 AM** | **Pre-market** | Researches overnight news, market direction, and catalysts; writes down a few trade ideas and a decision (usually "hold"). | A short "PRE-MKT" text: account value, market tone, ideas, decision. |
| **9:30 AM** | **Market-open** | Checks the ideas against the rules and (when live) places approved buys, each with a protective stop-loss. | A "MKT-OPEN" text: trades placed, or "none." |
| **12:00 PM** | **Midday** | Cuts losing positions, tightens stops on winners, exits anything whose thesis broke. | A "MIDDAY" text: actions taken, or "none." |
| **4:15 PM** | **Daily-summary** | Tallies the day's profit/loss, snapshots the portfolio, and files the end-of-day record. | An "EOD" text: full daily recap. |

Every run also **saves its notes to the filing cabinet (Git)** and **texts you** a summary. So on
a normal quiet day you get four short texts and a full audit trail of the agent's thinking.

---

## 5. The life of a single run (step by step)

When the alarm clock (cron) fires at, say, 8:00 AM, here's what happens under the hood — this is
the heartbeat of the whole system:

1. **Wake up.** The server runs a small script that starts Claude with the pre-market instructions.
2. **Read memory.** Claude reads its rulebook and its logs (open positions, recent research,
   yesterday's decisions) from the files.
3. **Check the account.** It calls the Robinhood tools to get the *live* portfolio and positions —
   never trusting stale notes over reality.
4. **Research.** It queries Perplexity (or falls back to a web search) for news and catalysts.
5. **Decide under the rules.** It runs each idea through the guardrails (position size limits,
   the "kill-switch," stocks-only, etc.) before doing anything.
6. **Act.** In live mode it would place orders; in the current safe mode it just *logs what it
   would have done*.
7. **Write memory.** It appends its reasoning and any changes to the log files.
8. **Save + notify.** It commits the updated files to Git (permanent, timestamped record) and
   texts you a summary via Telegram.
9. **Done.** The session ends. Nothing lingers. The next run will start fresh and read what this
   one saved.

Because each run is independent and everything is written down, you can scroll back through weeks
of the agent's decisions like a diary.

---

## 6. Safety: how we keep a money-handling robot from doing something dumb

This was the most important part of the design. Several layers:

**Two phases — verify before you trust.**
- **Phase 1 (where we are now):** The two "dangerous" tools — *place order* and *cancel order* —
  are **blocked**. The agent does *everything else* for real (reads the account, researches,
  decides, logs, texts) but physically cannot place a trade. This lets us watch it run live for
  days and confirm it behaves before any real money moves.
- **Phase 2 (later, deliberate):** We remove that block to arm live trading. This is a conscious,
  human-triggered switch — never automatic.

The block is enforced by a **"deny list"** in a settings file — a hard, mechanical stop, not just
a polite instruction in the prompt. Even if the AI *tried* to place an order in Phase 1, the tool
would refuse.

**Other guardrails baked into the rulebook:**
- **Stocks only, forever.** No options, no crypto — those tools are permanently blocked.
- **A "kill-switch."** If the account drops to a set threshold, the agent halts new buys and alerts.
- **Position-size caps.** No single position can exceed a set fraction of the account.
- **A protective stop-loss on every position** — an automatic sell order that limits losses.
- **Whole shares only**, so every position can carry a real broker-side stop.
- **Reconcile before acting.** Because runs can retry, the agent always checks live positions and
  orders first so it never accidentally double-buys.

The philosophy: **the machine enforces the dangerous limits; the rulebook enforces the discipline;
and we verify in read-only mode before flipping the switch.**

---

## 7. How we built it (the journey, in order)

This is the replication path — the actual sequence we followed. Each step has a plain explanation
and the concept behind it.

### Step 1 — Get a server (a "VM")
We rented a small always-on computer in the cloud — a **VM** ("virtual machine") from
**DigitalOcean** (about $12/month, 2 GB of memory, running Ubuntu Linux). *Why:* the agent needs
to run on a schedule even when your laptop is closed. A cloud server is always on.

### Step 2 — Lock it down ("hardening")
Before putting anything sensitive on it, we secured the server: created a non-administrator user,
turned on a firewall, disabled password logins (keys only), and set its clock to Eastern time.
*Why:* it holds real credentials and money access — it needs to be locked. *Concept: **SSH keys**
— logging in with a cryptographic key file instead of a password, which is far harder to break.*

### Step 3 — Install the software
We installed the basic runtime (Node.js and the Claude Code program). *Why:* this is the engine
that runs the agent.

### Step 4 — Let the server log into the AI (the API key)
The agent needs to authenticate with Anthropic (the maker of Claude) to run. We used an **API key**
— a long secret string that says "this server is allowed to use Claude, bill me per use." We stored
it in a protected file on the server, never in the code. *Concept: **API key** — like a prepaid
keycard; simple, doesn't expire, and you pay per use. Ideal for something running 24/7.*

### Step 5 — Give the server its own copy of the project (and permission to save)
We copied the project files onto the server and gave it permission to save its memory back to
GitHub. *Concept: a **deploy key** — a special key that grants one specific server write access to
one specific repository, nothing more.*

### Step 6 — Set up notifications (Telegram)
We created a free Telegram **bot** (via a bot called "BotFather"), got its token and our chat ID,
and tested that the server could text us. *Why:* this is how the agent reports in. *Concept: a bot
**token** — the bot's password; and a **chat ID** — the address of the conversation to send to.*

### Step 7 — Connect the broker (the tricky one: Robinhood MCP + OAuth)
This was the hardest step and worth understanding. The Robinhood connector uses **OAuth** — the
"Sign in with…" flow you've used a hundred times, where you approve access on a website rather than
handing over your password. The catch: OAuth needs a *web browser*, and our server has no screen or
browser.

The solution is a clever trick called an **SSH tunnel** (port forwarding). In plain terms: we
temporarily built a private pipe from the server to the laptop, so that when Robinhood tried to
open a login page, it appeared **in the laptop's browser** instead. We logged into Robinhood there,
approved the agent's access, and the approval flowed back through the pipe to the server, which
saved a **token** (a renewable permission slip) to its disk. From then on the server can reconnect
to Robinhood on its own — the laptop was only needed for that one approval.

*Concepts:*
- ***OAuth*** *— approving access on the provider's site instead of sharing your password.*
- ***SSH tunnel / port forwarding*** *— a temporary private connection that lets a browser on one
  machine complete a login happening on another.*
- ***Token*** *— the saved, self-renewing "yes, this agent is allowed" pass.*

### Step 8 — Prove it works without a human ("the gate")
Before scheduling anything, we ran a **read-only test**: we told the server, with no human watching,
to fetch the live portfolio and text it to us. When the real account numbers arrived on the phone
from a hands-off run, we knew the entire chain worked end to end. *This was the go/no-go gate.*

### Step 9 — Put it on a schedule (cron)
Finally we set up **cron** — the server's built-in scheduler — with four entries, one per routine,
at the right Eastern times, Monday–Friday. *Concept: **cron** — a list of "run this command at this
time" rules the server follows automatically forever.* We tested that the scheduler actually fired
the agent, then let it run.

That's the whole build: **rent a server → secure it → install the engine → give it its keys →
connect the broker → prove it works untouched → schedule it.**

---

## 8. What it looks like day to day

On a normal weekday you get four short Telegram messages, e.g.:

```
[trading-agent] PRE-MKT Jul 09
Acct: $500.26 (+0.05% vs $500)  Kill-switch: OK
Tape: mild risk-off; semis bouncing; VIX low
Ideas: PFE ~$24.10 (defensive); XLE ~$55.50 (weak)
Decision: HOLD (no strong setup)
```

Behind the scenes, each run also files a dated entry in the logs and saves it to GitHub, so there's
a permanent, timestamped record of *why* it did what it did. Monitoring is mostly: read the texts,
and if a day goes silent when it shouldn't, check the server's log files.

**Cost:** the server is ~$12/month, and the AI usage is metered per run (a few tens of dollars a
month at four runs a day, depending on the model chosen). Research and messaging are cheap or free.

---

## 9. The real lessons (gotchas we hit)

These are the "wish we'd known" items — useful if you replicate it:

- **A silent terminal doesn't mean nothing happened.** Our runner saves all output to a log file,
  so the screen looks empty while it's actually working. Check the log, not the screen.
- **Names must match exactly.** The broker connector had a quirky spelling in our config, and every
  rule and permission referenced that exact spelling. Rename it and the safety blocks silently stop
  matching. Consistency matters more than correctness here.
- **The scheduler runs with a "bare" environment.** Cron doesn't know where your programs live the
  way your normal login does, so we had to explicitly tell it. This is the single most common reason
  a scheduled job "silently does nothing."
- **The server only updates when told.** The agent runs from its saved copy of the project; it
  doesn't automatically pull in changes. Any edit to its rules or schedule has to be *published and
  then pulled onto the server* to take effect.
- **The login trick is one-time.** The SSH-tunnel browser dance for Robinhood is only needed once;
  after that the server reconnects on its own, even across reboots.
- **Verify read-only before trusting it with money.** The two-phase approach caught nothing scary,
  but the *discipline* of proving each link works unattended is what makes it trustworthy.

---

## 10. Glossary (quick reference)

- **Agent** — an AI given tools and a goal, allowed to act on its own.
- **API key** — a secret string that authorizes a program to use a paid service, billed per use.
- **Cron** — a scheduler built into Linux that runs commands at set times.
- **Deploy key** — a key granting one server access to one code repository.
- **Git / GitHub** — version-control: tracks every change to files with full history; GitHub hosts it.
- **Guardrails** — hard rules the agent must follow (size caps, kill-switch, stocks-only).
- **Headless** — running without a screen or human present (as on a server).
- **Kill-switch** — an automatic "stop trading" trigger if losses hit a threshold.
- **MCP (Model Context Protocol)** — an open standard for plugging tools into an AI.
- **OAuth** — approving access on a provider's website instead of sharing your password.
- **Prompt** — the written instructions given to the AI for a task.
- **Stop-loss** — an automatic sell order that limits how much a position can lose.
- **SSH** — a secure way to log into and control a remote server from your computer.
- **SSH tunnel (port forwarding)** — a temporary private connection between two machines.
- **Token** — a saved, renewable "this is allowed" pass from an OAuth login.
- **VM (virtual machine)** — a rented computer in the cloud.

---

## 11. Resource page (links)

**AI agent platform**
- Claude Code — overview & docs: https://code.claude.com/docs
- Claude Code on the web: https://code.claude.com/docs/en/claude-code-on-the-web
- Connecting tools via MCP (Claude Code): https://code.claude.com/docs/en/mcp
- Anthropic Console (get an API key, billing): https://console.anthropic.com

**Model Context Protocol (the tool standard)**
- What MCP is: https://modelcontextprotocol.io

**Broker**
- Robinhood Agentic Trading overview: https://robinhood.com/us/en/support/articles/agentic-trading-overview/
- Robinhood MCP endpoint we connected to: https://agent.robinhood.com/mcp/trading

**Server / hosting**
- DigitalOcean (the VM host): https://www.digitalocean.com
- DigitalOcean droplet quickstart: https://docs.digitalocean.com/products/droplets/getting-started/
- Ubuntu (the server operating system): https://ubuntu.com

**Scheduling & the shell**
- Crontab quick reference (build/verify cron times): https://crontab.guru
- SSH explained: https://www.ssh.com/academy/ssh

**Notifications**
- Telegram Bot API (create a bot, send messages): https://core.telegram.org/bots/api
- BotFather (create your bot in Telegram): https://t.me/botfather

**Research**
- Perplexity API docs: https://docs.perplexity.ai

**Security concepts**
- OAuth 2.0 (the "sign in with" standard): https://oauth.net/2/
- GitHub deploy keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/managing-deploy-keys

---

## 12. The 30-second explainer to tell a friend

*"I set up an AI agent that runs a real (small) stock account by itself. It lives on a little cloud
server that wakes it up four times a day. Each time, it reads its own notes, checks the live
account, researches the market, decides what to do under a strict rulebook, and texts me a summary
— then saves everything so there's a full paper trail. Right now it's in a safe mode where it does
everything except actually place trades, so I can watch it behave first. The neat part is I barely
wrote any code: the AI itself is the bot — I just gave it tools, rules, and a schedule."*

---

*Companion documents in this project: `docs/HANDOFF.md` (the original build blueprint),
`docs/VM-DEPLOYMENT.md` (the exact server setup runbook), and `docs/SESSION-HANDOFF.md`
(current live status).*
