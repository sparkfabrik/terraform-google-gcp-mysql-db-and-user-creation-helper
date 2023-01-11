#!/usr/bin/env sh

SERVICE="cloud_sql_proxy"

if pgrep -x "$SERVICE" >/dev/null 
then
    PID_CLOUD_SQL_PROXY=$(pgrep -x ${SERVICE})
    kill "$PID_CLOUD_SQL_PROXY" || true
fi
