#!/usr/bin/env sh

if ! [ -x "$(command -v cloud_sql_proxy)" ]; then
    echo "Error: cloud_sql_proxy is not installed." >&2
    exit 1
elif ! [ -x "$(command -v nc)" ]; then
    echo "Error: Netcat is not installed." >&2
    exit 1
fi

SERVICE="cloud_sql_proxy"

if ! pgrep -x "$SERVICE" >/dev/null
then
    exec cloud_sql_proxy -instances="${CLOUDSDK_CORE_PROJECT}:${GCLOUD_PROJECT_REGION}:${CLOUDSQL_INSTANCE_NAME}"="tcp:0.0.0.0:${CLOUD_SQL_PROXY_PORT}" /dev/null 2>&1 &
fi

for j in $(seq 1 10); do
    READY=$(sh -c 'nc -v ${CLOUD_SQL_PROXY_HOST} ${CLOUD_SQL_PROXY_PORT} </dev/null; echo $?;' 2>/dev/null)
    if [ "$READY" -eq 0 ]; then
        echo "Connection Ready"
        break
    fi
    echo "Waiting for Cloud SQL Proxy to start... $j"
    sleep 1s
done

if [ "$READY" -eq 1 ]; then
    echo "Error: Problem to connect sql instance ${CLOUD_SQL_PROXY_HOST}"
    exit 1
fi
