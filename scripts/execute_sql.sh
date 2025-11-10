#!/usr/bin/env sh

set -eu

# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then
    set -o pipefail
fi

log() {
    printf '[sql-grant] %s\n' "${1}"
}

if ! [ -x "$(command -v mysql)" ]; then
    log "Error: the mysql client is not installed or is not in your path. Please add the mysql client executable." >&2
    exit 1
elif ! [ -x "$(command -v nc)" ]; then
    log "Error: Netcat is not installed." >&2
    exit 1
fi

for j in $(seq 1 10); do
    READY=$(sh -c 'nc -v ${CLOUDSQL_PROXY_HOST} ${CLOUDSQL_PROXY_PORT} </dev/null; echo $?;' 2>/dev/null)

    if [ "$READY" -eq 0 ]; then
        log "Connection with CloudSQL Auth Proxy established at ${CLOUDSQL_PROXY_HOST}:${CLOUDSQL_PROXY_PORT}."
        break
    fi
    log "Waiting for Cloud SQL Proxy to start (attempt ${j}/10)..."
    sleep 1s
done

if [ "$READY" -eq 0 ]; then
    USER_IDENTIFIER="'${USER}'@'${USER_HOST}'"
    DATABASE_IDENTIFIER="\`${DATABASE}\`.*"

    log "Preparing privilege statements for ${USER_IDENTIFIER} on database \`${DATABASE}\` (MySQL ${MYSQL_VERSION})."

    case "${MYSQL_VERSION}" in
        MYSQL_5_7*)
            SQL_COMMANDS="REVOKE ALL PRIVILEGES, GRANT OPTION FROM ${USER_IDENTIFIER}; GRANT ALL PRIVILEGES ON ${DATABASE_IDENTIFIER} TO ${USER_IDENTIFIER};"
            ;;
        MYSQL_8_0*|MYSQL_8_4*)
            SQL_COMMANDS="REVOKE cloudsqlsuperuser FROM ${USER_IDENTIFIER}; SET DEFAULT ROLE NONE TO ${USER_IDENTIFIER}; GRANT ALL PRIVILEGES ON ${DATABASE_IDENTIFIER} TO ${USER_IDENTIFIER};"
            ;;
        *)
            log "ERROR: Unsupported MySQL version ${MYSQL_VERSION}." >&2
            exit 1
            ;;
    esac

    printf '[sql-grant] Executing SQL statements:\n%s\n' "${SQL_COMMANDS}"

    if ! MYSQL_PWD="${CLOUDSQL_PRIVILEGED_USER_PASSWORD}" mysql --host="${CLOUDSQL_PROXY_HOST}" --port="${CLOUDSQL_PROXY_PORT}" --user="${CLOUDSQL_PRIVILEGED_USER_NAME}" --execute="${SQL_COMMANDS}"; then
        log "ERROR: Failed to apply privileges for ${USER_IDENTIFIER} on ${DATABASE}." >&2
        exit 1
    fi

    log "Successfully applied privileges for ${USER_IDENTIFIER}."

    exit 0
else
    log "ERROR: cannot connect to the CloudSQL Auth Proxy at ${CLOUDSQL_PROXY_HOST}:${CLOUDSQL_PROXY_PORT}, please check your settings." >&2
    exit 1
fi
