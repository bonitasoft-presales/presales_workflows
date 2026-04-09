#!/usr/bin/env bash
set -euo pipefail

LOCAL_PORT=9090
SSH_USER="${SSH_USER:-cleverage_denodo_bonitasoft}"
SSH_HOST="${SSH_HOST:-bastion-ssh.fr-01.cloud.alfa-safety.net}"

echo "Starting SSH tunnel on port ${LOCAL_PORT}..."
ssh -i ~/.ssh/cleverage_rsa \
  -p 2222 \
  -o PubkeyAcceptedAlgorithms=+ssh-rsa \
  -o ExitOnForwardFailure=yes \
  -L ${LOCAL_PORT}:127.0.0.1:${LOCAL_PORT} \
  "${SSH_USER}@${SSH_HOST}" \
  -fN

# Wait briefly for the tunnel to establish
sleep 1

# Test: check the local port is listening
if lsof -i TCP:${LOCAL_PORT} -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "Tunnel is up — port ${LOCAL_PORT} is listening."
else
  echo "ERROR: tunnel failed — port ${LOCAL_PORT} is not listening." >&2
  exit 1
fi