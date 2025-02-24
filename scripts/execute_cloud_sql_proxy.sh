#!/usr/bin/env sh

if ! [ -x "$(command -v cloud_sql_proxy)" ]; then
    echo "Error: cannot find the cloud_sql_proxy executable, please install it or add to your path." >&2
    exit 1
elif ! [ -x "$(command -v nc)" ]; then
    echo "Error: Netcat is not installed." >&2
    exit 1
fi

SERVICE="cloud_sql_proxy"

if ! pgrep -x "$SERVICE" >/dev/null
then
    exec cloud_sql_proxy -instances="${CLOUDSDK_CORE_PROJECT}:${GCLOUD_PROJECT_REGION}:${CLOUDSQL_INSTANCE_NAME}"="tcp:0.0.0.0:${CLOUDSQL_PROXY_PORT}" /dev/null 2>&1 &
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

if [ "$READY" -eq 1 ]; then
    echo "ERROR: cannot connect to the CloudSQL Auth Proxy at ${CLOUDSQL_PROXY_HOST}, please check your settings."
    exit 1
fi
