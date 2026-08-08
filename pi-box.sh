#!/bin/bash
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-docker}"
PI_BOX_IMAGE="${PI_BOX_IMAGE:-morchv/pi-box:latest}"
PI_BOX_HOME="${PI_BOX_HOME:-${HOME}/.pi-box/home}"

DEFAULT_WORKSPACE="$(pwd)"

# Parse optional CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --workspace)
            WORKSPACE="$2"
            shift 2
            ;;
        --workdir)
            WORKDIR="$2"
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

WORKSPACE="${WORKSPACE:-$DEFAULT_WORKSPACE}"

DEFAULT_WORKDIR="/workspace/$(basename "$WORKSPACE")"
WORKDIR="${WORKDIR:-$DEFAULT_WORKDIR}"

uid="$(id -u)"
gid="$(id -g)"

args=(
    --rm -it
    --user "${uid}:${gid}"
    -e CONTAINER_USER=pi
    -e CONTAINER_GROUP=pi
    -e LOCAL_LLM_API_KEY
    -e FIRECRAWL_API_KEY
    -e FIRECRAWL_API_URL
    -v "${PI_BOX_HOME}:/home/pi"
    -v "${WORKSPACE}:${DEFAULT_WORKDIR}"
    -w "${WORKDIR}"
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

"${DOCKER_BIN}" run "${args[@]}" "${PI_BOX_IMAGE}" pi "$@"
