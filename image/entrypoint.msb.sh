#!/bin/bash

dockerd >/tmp/dockerd.log 2>&1 &
exec "$@"
