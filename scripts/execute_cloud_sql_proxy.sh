#!/usr/bin/env sh

set -eu

# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then
    set -o pipefail
fi

log() {
    printf '[sql-proxy] %s\n' "${1}"
}

PROXY_BIN=""
if command -v cloud_sql_proxy >/dev/null 2>&1; then
    PROXY_BIN="cloud_sql_proxy"
else
    log "Error: cannot find the Cloud SQL Auth Proxy executable cloud_sql_proxy. Please install it or add it to your PATH." >&2
    exit 1
fi

if ! command -v nc >/dev/null 2>&1; then
    log "Error: Netcat is not installed." >&2
    exit 1
fi

CONNECTION_NAME="${CLOUDSDK_CORE_PROJECT}:${GCLOUD_PROJECT_REGION}:${CLOUDSQL_INSTANCE_NAME}"

if ! pgrep -x "$PROXY_BIN" >/dev/null; then
    log "Starting Cloud SQL Auth Proxy (${PROXY_BIN}) for ${CONNECTION_NAME} on localhost:${CLOUDSQL_PROXY_PORT}."
    "${PROXY_BIN}" "${CONNECTION_NAME}" --port "${CLOUDSQL_PROXY_PORT}" >/dev/null 2>&1 &
    sleep 1s
else
    log "Cloud SQL Auth Proxy already running; skipping start."
fi

for j in $(seq 1 10); do
    READY=$(sh -c 'nc -v ${CLOUDSQL_PROXY_HOST} ${CLOUDSQL_PROXY_PORT} </dev/null; echo $?;' 2>/dev/null)
    if [ "$READY" -eq 0 ]; then
        log "Connection with Cloud SQL Auth Proxy established at ${CLOUDSQL_PROXY_HOST}:${CLOUDSQL_PROXY_PORT}."
        break
    fi
    log "Waiting for Cloud SQL Proxy to start (attempt ${j}/10)..."
    sleep 1s
done

if [ "$READY" -ne 0 ]; then
    log "ERROR: cannot connect to the Cloud SQL Auth Proxy at ${CLOUDSQL_PROXY_HOST}:${CLOUDSQL_PROXY_PORT}, please check your settings." >&2
    exit 1
fi
