# VM Deployment Runbook — Always-On Trading Agent

Companion to `HANDOFF.md`. This runs the four routines on your own always-on cloud VM
via headless Claude Code + cron, instead of Anthropic's cloud Routines.

---

## 0. What this changes vs. the Routines path

Pick ONE production path. This runbook is the **VM path**:

- **Anthropic Routines path:** Anthropic hosts the run; you attach the Robinhood connector,
  set routine env vars, toggle branch pushes. Risk: MCP OAuth may not survive the ephemeral
  container.
- **VM path (this doc):** your VM's cron runs `claude -p` headless. The Robinhood MCP is
  authenticated once on the VM and persists on disk. You use a **local `.env`** (guide's
  "local mode"). You do **not** create Anthropic Routines.

---

## 1. The two authentication problems (read before building)

**A. Claude → Anthropic (how the VM logs in to run Claude Code).**
- **API key (recommended for always-on):** set `ANTHROPIC_API_KEY`. Never expires, no browser.
  Metered (Console billing, pay per token). This is the reliable choice for a 24/7 money agent.
- **Subscription OAuth token (alternative):** `claude setup-token` on a machine with a browser
  makes a ~1-year token (`CLAUDE_CODE_OAUTH_TOKEN`). Cheaper if it fits your plan, BUT headless
  refresh is known to be flaky and can die silently overnight; print mode may draw API credits
  anyway. If you use it, add a token-expiry monitor (Section 13).
- Running the official `claude` binary on a server is permitted. Do NOT copy subscription
  OAuth tokens into any non-Claude-Code tool.

**B. Claude → Robinhood (the MCP connector).**
- The Robinhood MCP is a remote OAuth connector. You authenticate it **once on the VM**
  (Section 9) via an SSH port-forward for the browser step. Its token then persists on the
  VM's disk and refreshes across runs — which is the entire reason a persistent VM beats an
  ephemeral routine container.
- **You must verify it authenticates in a non-interactive run (Section 10) before trusting it.**

---

## 2. Provider & spec

- **Recommended:** DigitalOcean, Ubuntu 24.04 LTS, Basic droplet **2 GB RAM / 1 vCPU** (~$12/mo).
  (1 GB is tight once Node + Claude Code run.) Pick a region near you (e.g. NYC).
- Alternatives: Hetzner (cheaper, but datacenter IPs occasionally get blocked by services),
  AWS Lightsail (if you're AWS-inclined).

---

## 3. Provision + first login

1. Create an SSH keypair on your Mac if you don't have one: `ssh-keygen -t ed25519 -C "trading-vm"`.
2. In DigitalOcean, create the droplet; add your **public** key (`~/.ssh/id_ed25519.pub`) during setup.
3. SSH in as root: `ssh root@<droplet-ip>`.

## 4. Harden (do this before anything sensitive lands on the box)

```bash
# Create a non-root user (Claude Code should never run as root; bypassPermissions is blocked as root)
adduser trader
usermod -aG sudo trader
rsync --archive --chown=trader:trader ~/.ssh /home/trader   # copy your SSH key access

# Firewall: allow SSH only
ufw allow OpenSSH && ufw --force enable

# Disable root + password SSH login
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart ssh

# Automatic security updates
apt update && apt install -y unattended-upgrades && dpkg-reconfigure -plow unattended-upgrades

# Set timezone so cron times are Eastern
timedatectl set-timezone America/New_York
```

Reconnect as the new user: `ssh trader@<droplet-ip>`.

## 5. Install the runtime

```bash
sudo apt update && sudo apt install -y git curl python3 python3-pip jq
# Node.js (LTS) via NodeSource
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
# Claude Code CLI
npm install -g @anthropic-ai/claude-code
claude --version   # confirm it installed
```

## 6. Authenticate Claude → Anthropic (API-key path, recommended)

1. Create a key at console.anthropic.com.
2. Store it in a secrets file (not in the repo, not in crontab):
   ```bash
   umask 077
   printf 'export ANTHROPIC_API_KEY=%q\n' 'sk-ant-...' > ~/.trading-agent.secrets
   chmod 600 ~/.trading-agent.secrets
   ```
   The runner script (Section 11) sources this. Claude Code picks up `ANTHROPIC_API_KEY` automatically.

## 7. Clone the repo + git push auth

The routines commit memory back to `main`, so the VM needs push access. Use a **deploy key**:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/gh_deploy -C "trading-vm-deploy" -N ""
cat ~/.ssh/gh_deploy.pub
```
Add that public key in the GitHub repo → Settings → Deploy keys → **Allow write access**. Then:
```bash
cat >> ~/.ssh/config <<'EOF'
Host github.com
  IdentityFile ~/.ssh/gh_deploy
  IdentitiesOnly yes
EOF
git clone git@github.com:markustech85-gif/trading-agent.git ~/trading-agent
cd ~/trading-agent
git config user.email "vm@trading-agent"; git config user.name "trading-vm"
```

## 8. Local `.env` (Perplexity + Telegram)

On the VM you use local mode — the wrapper scripts read `.env`:
```bash
cp env.template .env && nano .env   # fill in Perplexity + Telegram values
chmod 600 .env
```
(`.env` is gitignored — never commit it.)

**Telegram setup (for notifications via `scripts/notify.sh`):**
1. In Telegram, message **@BotFather** → `/newbot` → follow prompts. It returns a
   **bot token** (`123456789:AA...`) → put in `TELEGRAM_BOT_TOKEN`.
2. Open a chat with your new bot and send it any message (e.g. "hi"). This is required
   before the bot can message you.
3. Get your **chat ID**: `curl -s "https://api.telegram.org/bot<TOKEN>/getUpdates"`
   and read `result[].message.chat.id` (a number) → put in `TELEGRAM_CHAT_ID`.
4. Smoke-test: `bash scripts/notify.sh "VM notify test $(date)"` — it should land in
   your Telegram. If it writes to `NOTIFICATIONS.md` instead, a var is missing.

## 9. Authenticate the Robinhood MCP on the VM

The OAuth step needs a browser, which the VM lacks. Forward the auth port from the VM to your Mac:

```bash
# On your MAC, open an SSH tunnel (leave it running):
ssh -L 8080:localhost:8080 trader@<droplet-ip>
```
Inside that session, on the VM, add the Robinhood MCP connector:
```bash
cd ~/trading-agent
claude mcp add ...   # follow Robinhood's connector instructions; it prints a localhost URL
```
When it prints a `http://localhost:8080/...` URL, paste it into your **Mac's** browser, complete
the Robinhood OAuth, and the token is stored on the VM. Confirm with `claude mcp list`.

## 10. VERIFY read-only (the gate — do not skip)

Prove the whole chain works unattended **before** any routine can trade:
```bash
source ~/.trading-agent.secrets
cd ~/trading-agent
claude -p "Call the Robinhood MCP get_portfolio for account 604803171. Send the equity and
buying power to Telegram via: bash scripts/notify.sh. Do NOT place, modify, or cancel any
order." --permission-mode bypassPermissions --max-turns 15
```
If you get real portfolio numbers on Telegram from a non-interactive run, the VM path works.
If the MCP fails to authenticate here, fix that before proceeding (re-run Section 9).

## 11. Runner script

`~/trading-agent/bin/run-routine.sh` (`mkdir -p ~/trading-agent/bin`, then `chmod +x`).
See `bin/run-routine.sh` in this repo. Notes: `bypassPermissions` is required for unattended
runs (no one to answer prompts) — but the `deny` list in `.claude/settings.json` still blocks
the order tools while you're in Phase 1. The VM itself is your isolation boundary.
`--max-turns 40` caps a runaway loop; raise/lower as needed.

## 12. Cron

`crontab -e` (times are Eastern because you set the VM timezone in Section 4):
```
0  8  * * 1-5  /home/trader/trading-agent/bin/run-routine.sh pre-market
30 9  * * 1-5  /home/trader/trading-agent/bin/run-routine.sh market-open
0  12 * * 1-5  /home/trader/trading-agent/bin/run-routine.sh midday
15 16 * * 1-5  /home/trader/trading-agent/bin/run-routine.sh daily-summary
```
Test one immediately by running the runner by hand:
`bin/run-routine.sh pre-market` — confirm it writes RESEARCH-LOG and pushes to `main`.

## 13. Monitoring

- **Logs:** everything appends to `~/logs/<routine>-<date>.log`. Skim these the first week.
- **Failure alerts:** the runner already messages Telegram on a non-zero exit.
- **Heartbeat:** the daily-summary always sends — if a weekday passes with no EOD Telegram
  message, something's wrong. Consider a separate 5pm "did daily-summary run today?" check.
- **Auth watch (only if you chose the OAuth-token path):** add a weekly job that runs a trivial
  `claude -p "say ok"` and pings Telegram if it fails, to catch token expiry before market hours.
- **Disk:** logs grow; add `find ~/logs -mtime +30 -delete` to a weekly cron.

## 14. Cost control

- API key is metered. Four short runs/day is modest, but agent loops can surprise you.
- Guards: `--max-turns`, concise prompts, and choosing a cheaper model for these routines
  (pass `--model` in the runner) — the research/summary work doesn't need the top model.
- Log `total_cost_usd` from the `--output-format json` result to watch spend; a weekly
  Telegram message of the running total keeps you ahead of the bill.

## 15. Safety recap

- Kill-switch (−20% / account ≤ $400) lives in STRATEGY.md and is checked before every buy.
- During your first live days, keep the order-placing MCP tools denied in
  `.claude/settings.json` and re-enable them only when you're ready (see HANDOFF §2),
  or run market-open by hand first and let only the read/summary routines run on cron.
- The VM holds real credentials (API key, Telegram bot token, Robinhood token, deploy key). Keep SSH
  key-only, firewall on, and the box patched.
