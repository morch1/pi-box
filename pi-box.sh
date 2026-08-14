#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname $(readlink -f "${BASH_SOURCE[0]}"))" && pwd)"

PI_BOX_ROOT="${PI_BOX_ROOT:-${HOME}/.pi-box}"
PI_BOX_ENV_FILE="${PI_BOX_ENV_FILE:-${PI_BOX_ROOT}/pi-box.env}"

while read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" ]]; then continue; fi
    eval $line
    ENV_ARGS+=(--env "$line")
done < <(grep -v '^#' "$PI_BOX_ENV_FILE")

PI_BOX_IMAGE="${PI_BOX_IMAGE:-morchv/pi-box:latest}"

install() {
    curl -fsSL https://install.microsandbox.dev | sh
    msb pull "${PI_BOX_IMAGE}"
    ln -s "${SCRIPT_DIR}/pi-box.sh" "${HOME}/.local/bin/pi-box"
    [ -f "${HOME}/.local/bin/pi" ] || ln -s "${HOME}/.local/bin/pi-box" "${HOME}/.local/bin/pi"
}

run() {
    local command="$1"
    local workspace="$(pwd)"
    local workdir="/workspace/$(basename "$workspace")"
    local vm_name="pi-box-$(basename "$workspace")-$(openssl rand -hex 4)"
    local args=(
        --name "$vm_name"
        --hostname "pi-box"
        --entrypoint /usr/local/bin/entrypoint.msb.sh
        --workdir "${workdir}"
        --mount-dir "${workspace}:${workdir}"
        --mount-dir "${PI_BOX_ROOT}/home:/home/pi"
        --mount-named docker-data:/var/lib/docker:kind=disk,size=10G
    )
    shift
    msb run "${args[@]}" "${ENV_ARGS[@]}" "${PI_BOX_IMAGE}" -- "$command" "$@"
    msb rm --force --quiet "$vm_name"
}

command=pi
if [[ "${1:-}" == "bash" ]]; then
    command=bash
    shift
elif [[ "${1:-}" == "update" ]]; then
    msb pull "${PI_BOX_IMAGE}"
elif [[ "${1:-}" == "install-pi-box" ]]; then
    install
    exit 0
fi

run "$command" "$@"