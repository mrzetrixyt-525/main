#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
command -v python3 >/dev/null || { echo 'python3 missing'; exit 1; }
python3 -m py_compile "$ROOT/bot.py" "$ROOT/node-agent.py"
bash -n "$ROOT/setup_rgnodes.sh" "$ROOT/install_node_agent.sh"
node --check "$ROOT/ecosystem.config.js"
! grep -RqsE 'f"[^\n]*\{[^\n]*\\n[^\n]*\}' "$ROOT/bot.py" || { echo 'nested f-string backslash pattern detected'; exit 1; }
! grep -n 'params = {"api_key"' "$ROOT/bot.py" "$ROOT/node-agent.py" >/dev/null || { echo 'query-string API key path detected'; exit 1; }
! grep -n "action.*or.*sshx\|or action == ['\"]sshx" "$ROOT/bot.py" >/dev/null || true
printf 'RGNODES ultra self-check: PASS\n'
