#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname $(readlink -f "${BASH_SOURCE[0]}"))" && pwd)"

PI_BOX_IMAGE="${PI_BOX_IMAGE:-gitea.home.morch.al/morchv/pi-box:latest}"
PI_BOX_ROOT="${PI_BOX_ROOT:-${HOME}/.pi-box}"
PI_BOX_HOME="${PI_BOX_HOME:-${PI_BOX_ROOT}/home}"
PI_BOX_ENV_FILE="${PI_BOX_ENV_FILE:-${PI_BOX_ROOT}/pi-box.env}"

WORKSPACE="$(pwd)"
WORKDIR="/workspace/$(basename "$WORKSPACE")"

container_name="pi-box--$(basename "$WORKSPACE")--$(openssl rand -hex 4)"

args=(
    --name "$container_name"
    --hostname "pi-box"
    --entrypoint /usr/local/bin/entrypoint.msb.sh
    --workdir "${WORKDIR}"
    --mount-dir "${WORKSPACE}:${WORKDIR}"
    --mount-dir "${PI_BOX_HOME}:/home/pi"
    --mount-named docker-data:/var/lib/docker:kind=disk,size=10G
)

while read -r line || [[ -n "$line" ]]; do
    if [[ -z "$line" ]]; then continue; fi
    args+=(--env "$line")
done < <(grep -v '^#' "$PI_BOX_ENV_FILE")

command=pi
if [[ "${1:-}" == "bash" ]]; then
    command=bash
    shift
elif [[ "${1:-}" == "update" ]]; then
    msb pull "${PI_BOX_IMAGE}"
fi

msb run "${args[@]}" "${PI_BOX_IMAGE}" -- "$command" "$@"
msb rm --force --quiet "$container_name"
