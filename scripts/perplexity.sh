#!/usr/bin/env bash
# Research wrapper. All market research routes through Perplexity.
# Usage: bash scripts/perplexity.sh "<query>"
# Exits 3 if PERPLEXITY_API_KEY is unset so the caller can fall back to web search.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
[[ -f "$ENV_FILE" ]] && { set -a; source "$ENV_FILE"; set +a; }

query="${1:-}"
[[ -z "$query" ]] && { echo 'usage: perplexity.sh "<query>"' >&2; exit 1; }
[[ -z "${PERPLEXITY_API_KEY:-}" ]] && { echo "WARN: PERPLEXITY_API_KEY unset; fall back to web search." >&2; exit 3; }

MODEL="${PERPLEXITY_MODEL:-sonar}"
payload="$(python3 -c "
import json,sys
print(json.dumps({'model':sys.argv[1],'messages':[
 {'role':'system','content':'You are a precise financial research assistant. Cite every claim. Be concise.'},
 {'role':'user','content':sys.argv[2]}]}))
" "$MODEL" "$query")"

curl -fsS https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$payload"
echo
