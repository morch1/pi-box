#!/bin/bash
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-docker}"
PI_BOX_IMAGE="${PI_BOX_IMAGE:-morchv/pi-box:latest}"

uid="$(id -u)"
gid="$(id -g)"
workspace="/workspace/$(basename $(pwd))"
home_dir="${PI_BOX_HOME:-${HOME}/.pi-box/home}"

args=(
    --rm -it
    --user "${uid}:${gid}"
    -e CONTAINER_USER=pi
    -e CONTAINER_GROUP=pi
    -e LOCAL_LLM_API_KEY
    -e FIRECRAWL_API_KEY
    -e FIRECRAWL_API_URL
    -v "${home_dir}:/home/pi"
    -v "$(pwd):$workspace"
    -w "$workspace"
    --security-opt=no-new-privileges
    --cap-drop=ALL
)

if [[ "$(basename "${DOCKER_BIN}")" == "podman" ]]; then
    args+=(--userns=keep-id)
fi

for supplementary_gid in $(id -G); do
    if [[ "$supplementary_gid" != "$gid" ]]; then
        args+=(--group-add "$supplementary_gid")
    fi
done

"${DOCKER_BIN}" run "${args[@]}" "${PI_BOX_IMAGE}" "$@"
