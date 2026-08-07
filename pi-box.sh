#!/bin/bash
set -euo pipefail

uid="$(id -u)"
gid="$(id -g)"
workspace="/workspace/$(basename $(pwd))"

args=(
    --rm -it
    --user "${uid}:${gid}"
    -e CONTAINER_USER=pi
    -e CONTAINER_GROUP=pi
    -e LOCAL_LLM_API_KEY
    -e FIRECRAWL_API_KEY
    -e FIRECRAWL_API_URL
    -v "${PI_BOX_HOME:-${HOME}/.pi-box-home}:/home/pi"
    -v "$(pwd):$workspace"
    -w "$workspace"
    --security-opt=no-new-privileges
    --cap-drop=ALL
)

for supplementary_gid in $(id -G); do
    if [[ "$supplementary_gid" != "$gid" ]]; then
        args+=(--group-add "$supplementary_gid")
    fi
done

"${DOCKER_BIN:-docker}" run "${args[@]}" "${PI_BOX_IMAGE:-morchv/pi-box:latest}" "$@"
