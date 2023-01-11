#!/usr/bin/env sh

if ! [ -x "$(command -v mysql)" ]; then
    echo "Error: mysql is not installed." >&2
    exit 1
fi

for j in $(seq 1 10); do
    READY=$(sh -c 'exec 3<> /dev/tcp/${CLOUD_SQL_PROXY_HOST}/${CLOUD_SQL_PROXY_PORT};echo $?' 2>/dev/null)

    if [ "$READY" -eq 0 ]; then
        echo "Connection Ready"
        break
    fi
    echo "Waiting for Cloud SQL Proxy to start... $j"
    sleep 1s
done

if [ "$READY" -eq 0 ]; then
    %{~ if trimspace(mysql_version) == "MYSQL_5_7" }
    mysql --host=${CLOUD_SQL_PROXY_HOST} --port=${CLOUD_SQL_PROXY_PORT} --user=${SQL_USER_ADMIN} --password=${SQL_PASSWORD_ADMIN} --execute="REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${USER}'@'%'; GRANT ALL ON ${DATABASE}.* TO ${USER}@'%';"
    %{ endif ~}

    %{~ if trimspace(mysql_version) == "MYSQL_8_0" }
    mysql --host=${CLOUD_SQL_PROXY_HOST} --port=${CLOUD_SQL_PROXY_PORT} --user=${SQL_USER_ADMIN} --password=${SQL_PASSWORD_ADMIN} --execute="REVOKE cloudsqlsuperuser FROM '${USER}'@'%'; GRANT ALL ON ${DATABASE}.* TO ${USER}@'%';"
    %{ endif ~}

    exit 0
else
    echo "Error: Problem to connect sql instance ${CLOUD_SQL_PROXY_HOST}"
    exit 1
fi
