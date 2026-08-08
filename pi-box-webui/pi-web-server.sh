#!/bin/bash

pi-web-sessiond 2>&1 &
sessiond_pid=$!

pi-web-server 2>&1 &
server_pid=$!

status=0
wait "$sessiond_pid" || status=$?
wait "$server_pid" || {
  server_status=$?
  if [ "$status" -eq 0 ]; then
    status=$server_status
  fi
}

exit "$status"
