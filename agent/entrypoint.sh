#!/bin/sh
# Container entrypoint for mager-agent.
#
# Reads configuration from environment variables so the same image works with
# `docker run`, `docker compose`, Kubernetes, Nomad, etc. without a custom
# command override.
set -eu

if [ -z "${MAGER_WORKER_URL:-}" ]; then
  echo "MAGER_WORKER_URL is required (e.g. https://your-worker.workers.dev)" >&2
  exit 1
fi

STATE_DIR="${MAGER_STATE_DIR:-/var/lib/mager}"
CLOUDFLARED_PATH="${MAGER_CLOUDFLARED_PATH:-/usr/local/bin/cloudflared}"

# shellcheck disable=SC2086
# Append -machine-name only when set so the agent's hostname fallback still
# works inside containers that have a meaningful hostname.
exec /usr/local/bin/mager-agent \
  -worker-url "${MAGER_WORKER_URL}" \
  -state-dir "${STATE_DIR}" \
  -cloudflared-path "${CLOUDFLARED_PATH}" \
  ${MAGER_MACHINE_NAME:+-machine-name "${MAGER_MACHINE_NAME}"} \
  "$@"
