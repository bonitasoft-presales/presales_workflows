#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT=9090
SSH_USER="${SSH_USER:-cleverage_denodo_bonitasoft}"
SSH_HOST="${SSH_HOST:-bastion-ssh.fr-01.cloud.alfa-safety.net}"

TIMEOUT=30
RETRY_DELAY=2

# Kill any existing tunnel on the port
EXISTING_PID=$(lsof -i TCP:${LOCAL_PORT} -sTCP:LISTEN -t 2>/dev/null || true)
if [ -n "$EXISTING_PID" ]; then
  echo "Stopping existing tunnel (PID ${EXISTING_PID}) on port ${LOCAL_PORT}..."
  kill "$EXISTING_PID"
  sleep 1
  echo "Existing tunnel stopped."
fi

echo "Starting SSH tunnel on port ${LOCAL_PORT}..."
ssh -i ~/.ssh/tunnel_key \
  -p 2222 \
  -o StrictHostKeyChecking=no \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  -o ExitOnForwardFailure=yes \
  -o ConnectTimeout=10 \
  -o ServerAliveInterval=15 \
  -o ServerAliveCountMax=3 \
  -o BatchMode=yes \
  -L ${LOCAL_PORT}:127.0.0.1:${LOCAL_PORT} \
  "${SSH_USER}@${SSH_HOST}" \
  -fN

# Wait for the tunnel to establish, with timeout
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  if lsof -i TCP:${LOCAL_PORT} -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "Tunnel is up — port ${LOCAL_PORT} is listening."
    exit 0
  fi
  sleep $RETRY_DELAY
  ELAPSED=$((ELAPSED + RETRY_DELAY))
done

echo "ERROR: tunnel failed — port ${LOCAL_PORT} is not listening after ${TIMEOUT}s." >&2
exit 1