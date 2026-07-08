#!/usr/bin/env bash
# Back-compat shim. Notifications now go through Telegram via notify.sh.
# Kept so existing routines and the settings allowlist keep working unchanged.
# New agents should call scripts/notify.sh directly.
exec "$(cd "$(dirname "$0")" && pwd)/notify.sh" "$@"
