#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname $(readlink -f "${BASH_SOURCE[0]}"))" && pwd)"
DOCKER_BIN="${DOCKER_BIN:-podman}"

PI_BOX_IMAGE="${PI_BOX_IMAGE:-morchv/pi-box:latest}"
PI_BOX_ROOT="${PI_BOX_ROOT:-${HOME}/.pi-box}"
PI_BOX_HOME="${PI_BOX_HOME:-${PI_BOX_ROOT}/home}"
PI_BOX_ENV_FILE="${PI_BOX_ENV_FILE:-${PI_BOX_ROOT}/pi-box.env}"

PI_BOX_SECCOMP_FILE="${PI_BOX_SECCOMP_FILE:-${SCRIPT_DIR}/devcontainers/pi-box/.devcontainer/seccomp.json}"

WORKSPACE="$(pwd)"
WORKDIR="/workspace/$(basename "$WORKSPACE")"

container_name="pi-box--$(basename "$WORKSPACE")--$(openssl rand -hex 4)"

[[ "$(basename "${DOCKER_BIN}")" == "podman" ]] && is_podman=true || is_podman=false

args=(
    --name "$container_name"
    --hostname "pi-box"
    --rm -it
    --env-file "${PI_BOX_ENV_FILE}"
    --userns=keep-id:uid=1000,gid=1000
    --group-add keep-groups
    -w "${WORKDIR}"
    -v "${WORKSPACE}:${WORKDIR}:z"
    -v "${PI_BOX_HOME}:/home/pi:z"
    --cap-drop=ALL
    --cap-add SETUID
    --cap-add SETGID
    --cap-add SYS_CHROOT
    --cap-add SETFCAP
    --security-opt label=nested
    --security-opt seccomp=unconfined
    --device /dev/fuse
    --device /dev/net/tun
)

command=pi
if [[ "${1:-}" == "bash" ]]; then
    command=bash
    shift
fi

"${DOCKER_BIN}" run "${args[@]}" "${PI_BOX_IMAGE}" "$command" "$@"
