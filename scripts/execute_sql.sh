#!/usr/bin/env sh

set -eu

# shellcheck disable=SC3040
if (set -o pipefail 2>/dev/null); then
    set -o pipefail
fi

log() {
    printf '[sql-grant] %s\n' "${1}"
}

mysql_exec() {
    MYSQL_PWD="${CLOUDSQL_PRIVILEGED_USER_PASSWORD}" mysql \
        --host="${CLOUDSQL_PROXY_HOST}" \
        --port="${CLOUDSQL_PROXY_PORT}" \
        --user="${CLOUDSQL_PRIVILEGED_USER_NAME}" \
        "$@"
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
            # On Cloud SQL MySQL 8.4, activate_all_roles_on_login is OFF and the
            # admin's default role (cloudsqlsuperuser) may not be set until the
            # admin has logged in interactively at least once. We prepend
            # "SET ROLE ALL;" to every statement so that each independent
            # mysql connection activates the full ROLE_ADMIN privileges needed
            # for SHOW GRANTS and REVOKE operations on other users.
            ROLE_PREFIX="SET ROLE ALL;"

            # Pre-check: verify whether the user has the cloudsqlsuperuser role
            # before attempting REVOKE, to avoid Access Denied (1045) errors when
            # the admin user lacks ROLE_ADMIN privileges.
            if ! GRANTS_OUTPUT=$(mysql_exec --execute="${ROLE_PREFIX} SHOW GRANTS FOR ${USER_IDENTIFIER};" 2>&1); then
                log "ERROR: Failed to retrieve grants for ${USER_IDENTIFIER}."
                log "${GRANTS_OUTPUT}" >&2
                exit 1
            fi

            HAS_SUPERUSER_ROLE=false
            if printf '%s' "${GRANTS_OUTPUT}" | grep -qi "cloudsqlsuperuser"; then
                HAS_SUPERUSER_ROLE=true
                log "cloudsqlsuperuser role found for ${USER_IDENTIFIER}; revoking."
                if ! REVOKE_OUTPUT=$(mysql_exec --execute="${ROLE_PREFIX} REVOKE cloudsqlsuperuser FROM ${USER_IDENTIFIER};" 2>&1); then
                    log "ERROR: Failed to revoke cloudsqlsuperuser role for ${USER_IDENTIFIER}."
                    log "${REVOKE_OUTPUT}" >&2
                    exit 1
                fi
                log "Removed cloudsqlsuperuser role from ${USER_IDENTIFIER}."
            else
                log "cloudsqlsuperuser role not found for ${USER_IDENTIFIER}; skipping REVOKE."
            fi

            if [ "${HAS_SUPERUSER_ROLE}" = true ]; then
                SQL_COMMANDS="${ROLE_PREFIX} SET DEFAULT ROLE NONE TO ${USER_IDENTIFIER}; GRANT ALL PRIVILEGES ON ${DATABASE_IDENTIFIER} TO ${USER_IDENTIFIER};"
            else
                SQL_COMMANDS="${ROLE_PREFIX} GRANT ALL PRIVILEGES ON ${DATABASE_IDENTIFIER} TO ${USER_IDENTIFIER};"
            fi
            ;;
        *)
            log "ERROR: Unsupported MySQL version ${MYSQL_VERSION}." >&2
            exit 1
            ;;
    esac

    printf '[sql-grant] Executing SQL statements:\n%s\n' "${SQL_COMMANDS}"

    if ! mysql_exec --execute="${SQL_COMMANDS}"; then
        log "ERROR: Failed to apply privileges for ${USER_IDENTIFIER} on ${DATABASE}." >&2
        exit 1
    fi

    log "Successfully applied privileges for ${USER_IDENTIFIER}."

    exit 0
else
    log "ERROR: cannot connect to the CloudSQL Auth Proxy at ${CLOUDSQL_PROXY_HOST}:${CLOUDSQL_PROXY_PORT}, please check your settings." >&2
    exit 1
fi
