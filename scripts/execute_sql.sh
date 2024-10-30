#!/usr/bin/env sh

if ! [ -x "$(command -v mysql)" ]; then
    echo "Error: the mysql client is not installed or is not in your path. Please add the mysql client executable." >&2
    exit 1
elif ! [ -x "$(command -v nc)" ]; then
    echo "Error: Netcat is not installed." >&2
    exit 1
fi

for j in $(seq 1 10); do
    READY=$(sh -c 'nc -v ${CLOUDSQL_PROXY_HOST} ${CLOUDSQL_PROXY_PORT} </dev/null; echo $?;' 2>/dev/null)

    if [ "$READY" -eq 0 ]; then
        echo "Connection with with CloudSQL Auth Proxy established at ${CLOUDSQL_PROXY_HOST}."
        break
    fi
    echo "Waiting for Cloud SQL Proxy to start... $j"
    sleep 1s
done

if [ "$READY" -eq 0 ]; then
    if [ "$MYSQL_VERSION" = "MYSQL_5_7" ]; then
    mysql --host=${CLOUDSQL_PROXY_HOST} --port=${CLOUDSQL_PROXY_PORT} --user=${CLOUDSQL_PRIVILEGED_USER_NAME} --password=${CLOUDSQL_PRIVILEGED_USER_PASSWORD} --execute="REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${USER}'@'${USER_HOST}'; GRANT ALL ON ${DATABASE}.* TO ${USER}@'${USER_HOST}';"
    fi

    if [ "$MYSQL_VERSION" = "MYSQL_8_0" ]; then
    mysql --host=${CLOUDSQL_PROXY_HOST} --port=${CLOUDSQL_PROXY_PORT} --user=${CLOUDSQL_PRIVILEGED_USER_NAME} --password=${CLOUDSQL_PRIVILEGED_USER_PASSWORD} --execute="REVOKE cloudsqlsuperuser FROM '${USER}'@'${USER_HOST}'; GRANT ALL ON ${DATABASE}.* TO ${USER}@'${USER_HOST}';"
    fi

    exit 0
else
    echo "ERROR: cannot connect to the CloudSQL Auth Proxy at ${CLOUDSQL_PROXY_HOST}, please check your settings."
    exit 1
fi
