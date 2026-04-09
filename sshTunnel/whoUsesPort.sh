#!/usr/bin/env bash
set -euo pipefail

PORT="${1:-9090}"

PID=$(lsof -i TCP:${PORT} -sTCP:LISTEN -t 2>/dev/null || true)

if [ -z "$PID" ]; then
  echo "No process found on port ${PORT}."
  exit 0
fi

echo "Port ${PORT} is used by PID ${PID}:"
echo ""
echo "--- lsof ---"
lsof -i TCP:${PORT} -sTCP:LISTEN

echo ""
echo "--- process details ---"
ps -p ${PID} -o pid,user,command
