#!/bin/bash
set -euo pipefail

uid="$(id -u)"
gid="$(id -g)"

runtime_dir="${TMPDIR:-/tmp}/container-user-${uid}"
mkdir -p "$runtime_dir"

passwd_file="$runtime_dir/passwd"
group_file="$runtime_dir/group"

cp /etc/passwd "$passwd_file"
cp /etc/group "$group_file"

if getent passwd "$uid" >/dev/null 2>&1; then
    sed -i "s/^\([^:]*\):x:${uid}:/${USERNAME}:x:${uid}:/" "$passwd_file"
else
    echo "${USERNAME}:x:${uid}:${gid}:${USERNAME}:${HOME}:/bin/bash" >> "$passwd_file"
fi

if getent group "$gid" >/dev/null 2>&1; then
    sed -i "s/^\([^:]*\):x:${gid}:/${USERNAME}:x:${gid}:/" "$group_file"
else
    echo "${USERNAME}:x:${gid}:" >> "$group_file"
fi

export NSS_WRAPPER_PASSWD="$passwd_file"
export NSS_WRAPPER_GROUP="$group_file"
export LD_PRELOAD="/usr/lib/libnss_wrapper.so${LD_PRELOAD:+:$LD_PRELOAD}"

exec "$@"
