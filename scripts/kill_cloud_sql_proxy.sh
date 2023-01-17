#!/usr/bin/env sh

SERVICE="cloud_sql_proxy"

if pgrep -x "$SERVICE" >/dev/null; then
    # It's better to take some time and to wait for the other tasks to finish
    # before killing the proxy; do not entering a sleep time, can lead to a
    # race condition error when simultaneously creating and destroying resources.
    sleep 5s
    PID_CLOUD_SQL_PROXY=$(pgrep -x ${SERVICE})
    kill "$PID_CLOUD_SQL_PROXY" || true
fi
