#!/usr/bin/env bash
# GitHub Codespaces is a temporary pilot runtime, not a 24/7 quota worker.
set -euo pipefail
umask 077
state="$HOME/.local/share/stacklight-onwatch"
private="$HOME/.config/stacklight-onwatch"
if [[ ! -x "$state/onwatch" || ! -s "$private/admin-password" ]]; then
  echo "onWatch not installed yet; run: bash .devcontainer/bootstrap-onwatch.sh"
  exit 1
fi

if curl -fsS --max-time 3 http://127.0.0.1:9211/ >/dev/null 2>&1; then
  echo "onWatch already responds on 127.0.0.1:9211"
  exit 0
fi

export ONWATCH_ADMIN_USER="stacklight"
export ONWATCH_ADMIN_PASS
ONWATCH_ADMIN_PASS="$(cat "$private/admin-password")"
export ONWATCH_DB_PATH="$state/onwatch.db"
export ONWATCH_PORT="9211"
export ONWATCH_POLL_INTERVAL="3600"
export ONWATCH_LOG_LEVEL="warn"

# Environment is scoped to this command only. No keys, OAuth tokens or
# browser sessions are copied from Stacklight into this Codespace.
nohup "$state/onwatch" --debugstdout > "$state/onwatch.log" 2>&1 < /dev/null &
echo "Started onWatch pilot (PID $!). View port 9211 in GitHub Codespaces."
echo "Login: stacklight; password stored under ~/.config/stacklight-onwatch/admin-password"
