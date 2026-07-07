Read-only portfolio snapshot for the trading agent. STOCKS ONLY context. Ultra-concise.
Do NOT place, modify, or cancel any order.

1. get_accounts — confirm 604803171 present, agentic_allowed=true.
2. get_portfolio(604803171) — total value, cash, buying power.
3. get_equity_positions(604803171) — open positions + average cost.
4. get_equity_orders(604803171) — any resting/open orders (esp. stops).
5. get_equity_quotes for each held symbol; compute unrealized P&L.
Print a clean snapshot: equity, cash, deployed %, each position with unrealized P&L
and its resting stop, and drawdown vs the $500 start (kill-switch status). No commit.
