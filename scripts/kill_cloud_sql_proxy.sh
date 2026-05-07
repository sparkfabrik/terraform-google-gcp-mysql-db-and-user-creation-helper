#!/usr/bin/env sh

set -eu

# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then
    set -o pipefail
fi

log() {
    printf '[sql-proxy] %s\n' "${1}"
}

CLOUDSQL_PROXY_BIN="cloud_sql_proxy"
PID_FILE="/tmp/cloudsql-proxy-${CLOUDSQL_PROXY_PORT:-1234}.pid"
INSTANCE_FILE="/tmp/cloudsql-proxy-${CLOUDSQL_PROXY_PORT:-1234}.instance"

if [ -f "${PID_FILE}" ]; then
    PID=$(cat "${PID_FILE}")
    if kill -0 "${PID}" 2>/dev/null; then
        log "Stopping ${CLOUDSQL_PROXY_BIN} (PID: ${PID})."
        kill "${PID}" || true
        sleep 2s
    else
        log "PID ${PID} from ${PID_FILE} is no longer running; nothing to stop."
    fi
    rm -f "${PID_FILE}" "${INSTANCE_FILE}"
elif pgrep -x "$CLOUDSQL_PROXY_BIN" >/dev/null; then
    log "Detected running ${CLOUDSQL_PROXY_BIN} not managed by this module (no PID file); skipping."
else
    log "No running ${CLOUDSQL_PROXY_BIN} found; nothing to stop."
fi
