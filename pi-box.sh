#!/bin/bash
set -euo pipefail

DOCKER_BIN="${DOCKER_BIN:-docker}"

PUID="${PUID:-$(id -u)}"
PGID="${PGID:-$(id -g)}"
SUPP_PGIDS="${SUPP_PGIDS:-$(id -G)}"

PI_BOX_IMAGE="${PI_BOX_IMAGE:-morchv/pi-box:latest}"
PI_BOX_ROOT="${PI_BOX_ROOT:-${HOME}/.pi-box}"
PI_BOX_HOME="${PI_BOX_HOME:-${PI_BOX_ROOT}/home}"
PI_BOX_ENV_FILE="${PI_BOX_ENV_FILE:-${PI_BOX_ROOT}/pi-box.env}"

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

container_name="pi-box--$(basename "$WORKSPACE")--$(openssl rand -hex 4)"

args=(
    --name "$container_name"
    --rm -it
    --user "${PUID}:${PGID}"
    -e LOCAL_LLM_API_KEY
    -e FIRECRAWL_API_KEY
    -e FIRECRAWL_API_URL
    -v "${WORKSPACE}:${DEFAULT_WORKDIR}"
    -w "${WORKDIR}"
    --security-opt=no-new-privileges
    --cap-drop=ALL
)

if [ "$PUID" -eq 0 ]; then
    args+=(-v "${PI_BOX_HOME}:/root")
else
    args+=(
        -v "${PI_BOX_HOME}:/home/pi"
        -e CONTAINER_USER=pi
        -e CONTAINER_GROUP=pi
    )
    if [[ "$(basename "${DOCKER_BIN}")" == "podman" ]]; then
        args+=(--userns=keep-id)
    fi
fi

for supplementary_gid in $SUPP_PGIDS; do
    if [[ "$supplementary_gid" != "$PGID" ]]; then
        args+=(--group-add "$supplementary_gid")
    fi
done

[ ! -f "$PI_BOX_ENV_FILE" ] || export $(grep -v '^#' "$PI_BOX_ENV_FILE" | xargs)

"${DOCKER_BIN}" run "${args[@]}" "${PI_BOX_IMAGE}" pi "$@"
