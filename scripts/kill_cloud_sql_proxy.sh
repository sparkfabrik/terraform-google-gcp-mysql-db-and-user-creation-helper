#!/usr/bin/env sh

set -eu

# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then
    set -o pipefail
fi

log() {
    printf '[sql-proxy] %s\n' "${1}"
}

get_process_command() {
    ps -p "${1}" -o command= 2>/dev/null || true
}

process_matches_expected_proxy() {
    PROCESS_COMMAND=$(get_process_command "${1}")

    [ -n "${PROCESS_COMMAND}" ] || return 1

    case "${PROCESS_COMMAND}" in
        *"cloud_sql_proxy"*) ;;
        *) return 1 ;;
    esac

    case "${PROCESS_COMMAND}" in
        *"${CONNECTION_NAME}"*) ;;
        *) return 1 ;;
    esac

    case "${PROCESS_COMMAND}" in
        *"--port ${CLOUDSQL_PROXY_PORT:-1234}"*|*"--port=${CLOUDSQL_PROXY_PORT:-1234}"*) return 0 ;;
        *) return 1 ;;
    esac
}

CLOUDSQL_PROXY_BIN="cloud_sql_proxy"
PID_FILE="/tmp/cloudsql-proxy-${CLOUDSQL_PROXY_PORT:-1234}.pid"
INSTANCE_FILE="/tmp/cloudsql-proxy-${CLOUDSQL_PROXY_PORT:-1234}.instance"
LOG_FILE="/tmp/cloudsql-proxy-${CLOUDSQL_PROXY_PORT:-1234}.log"
CONNECTION_NAME="${CLOUDSDK_CORE_PROJECT}:${GCLOUD_PROJECT_REGION}:${CLOUDSQL_INSTANCE_NAME}"

if [ -f "${PID_FILE}" ]; then
    PID=$(cat "${PID_FILE}")
    if kill -0 "${PID}" 2>/dev/null; then
        if process_matches_expected_proxy "${PID}"; then
            log "Stopping ${CLOUDSQL_PROXY_BIN} (PID: ${PID})."
            kill "${PID}" || true
            sleep 2s
        else
            log "PID ${PID} from ${PID_FILE} does not match the expected proxy; skipping."
        fi
    else
        log "PID ${PID} from ${PID_FILE} is no longer running; nothing to stop."
    fi
    rm -f "${PID_FILE}" "${INSTANCE_FILE}" "${LOG_FILE}"
elif pgrep -x "$CLOUDSQL_PROXY_BIN" >/dev/null; then
    log "Detected running ${CLOUDSQL_PROXY_BIN} not managed by this module (no PID file); skipping."
else
    log "No running ${CLOUDSQL_PROXY_BIN} found; nothing to stop."
fi
