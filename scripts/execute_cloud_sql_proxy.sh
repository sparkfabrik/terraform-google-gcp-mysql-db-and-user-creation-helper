#!/usr/bin/env sh

set -eu

# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then
    set -o pipefail
fi

log() {
    printf '[sql-proxy] %s\n' "${1}"
}

CLOUDSQL_PROXY_BIN=""
if command -v cloud_sql_proxy >/dev/null 2>&1; then
    CLOUDSQL_PROXY_BIN="cloud_sql_proxy"
else
    log "Error: cannot find the Cloud SQL Auth Proxy executable cloud_sql_proxy. Please install it or add it to your PATH." >&2
    exit 1
fi

CONNECTION_NAME="${CLOUDSDK_CORE_PROJECT}:${GCLOUD_PROJECT_REGION}:${CLOUDSQL_INSTANCE_NAME}"
PROXY_LOG_FILE=$(mktemp /tmp/cloudsql-proxy-XXXXXX.log)

if ! pgrep -x "$CLOUDSQL_PROXY_BIN" >/dev/null; then
    log "Starting Cloud SQL Auth Proxy (${CLOUDSQL_PROXY_BIN}) for ${CONNECTION_NAME} on localhost:${CLOUDSQL_PROXY_PORT}."
    "${CLOUDSQL_PROXY_BIN}" "${CONNECTION_NAME}" --port "${CLOUDSQL_PROXY_PORT}" >"${PROXY_LOG_FILE}" 2>&1 &
    PROXY_PID=$!
    sleep 2s

    # Check if the proxy process is still running after startup.
    if ! kill -0 "${PROXY_PID}" 2>/dev/null; then
        log "ERROR: Cloud SQL Auth Proxy exited immediately. Logs:"
        cat "${PROXY_LOG_FILE}" >&2
        rm -f "${PROXY_LOG_FILE}"
        exit 1
    fi
    log "Cloud SQL Auth Proxy started (PID: ${PROXY_PID})."
else
    log "Cloud SQL Auth Proxy already running; skipping start."
fi

rm -f "${PROXY_LOG_FILE}"
