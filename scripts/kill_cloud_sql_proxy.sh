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
if pgrep -x "$CLOUDSQL_PROXY_BIN" >/dev/null; then
    log "Detected running ${CLOUDSQL_PROXY_BIN}; waiting 5 seconds before shutdown to avoid race conditions."
    sleep 5s
    # Obtain the PID of the running Cloud SQL Auth Proxy and terminate gently.
    PID="$(pgrep -x "$CLOUDSQL_PROXY_BIN")"
    log "Stopping ${CLOUDSQL_PROXY_BIN} (PID(s): ${PID})."

    kill "${PID}" || true
fi
