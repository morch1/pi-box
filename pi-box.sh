#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname $(readlink -f "${BASH_SOURCE[0]}"))" && pwd)"
DOCKER_BIN="${DOCKER_BIN:-docker}"

PI_BOX_ROOT="${PI_BOX_ROOT:-${HOME}/.pi-box}"
PI_BOX_ENV_FILE="${PI_BOX_ENV_FILE:-${PI_BOX_ROOT}/pi-box.env}"
PI_BOX_IMAGE="${PI_BOX_IMAGE:-morchv/pi-box:latest}"

workspace="$(pwd)"
workdir="/workspace/$(basename "$workspace")"
container_name="pi-box-$(basename "$workspace")-$(openssl rand -hex 4)"
[[ "$(basename "${DOCKER_BIN}")" == "podman" ]] && is_podman=true || is_podman=false

args=(
    --rm -it
    --name "$container_name"
    --hostname "pi-box"
    --workdir "${workdir}"
    --volume "${workspace}:${workdir}"
    --volume "${PI_BOX_ROOT}/home:/home/pi"
    --security-opt=no-new-privileges
    --cap-drop=ALL
)

if $is_podman; then
    args+=(
        --userns=keep-id:uid=1000,gid=1000
        --group-add keep-groups
    )
else
    uid="$(id -u)"
    gid="$(id -g)"
    args+=(
        --user "${uid}:${gid}"
        --entrypoint "/usr/local/bin/entrypoint.docker.sh"
    )
    for supplementary_gid in $(id -G); do
        if [[ "$supplementary_gid" != "$gid" ]]; then
            args+=(--group-add "$supplementary_gid")
        fi
    done
fi

while read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" ]]; then continue; fi
    args+=(--env "$line")
done < <(grep -v '^#' "$PI_BOX_ENV_FILE")

command=pi
if [[ "${1:-}" == "bash" ]]; then
    command=bash
    shift
elif [[ "${1:-}" == "update" ]]; then
    "${DOCKER_BIN}" pull "${PI_BOX_IMAGE}"
fi

"${DOCKER_BIN}" run "${args[@]}" "${PI_BOX_IMAGE}" -- "$command" "$@"
