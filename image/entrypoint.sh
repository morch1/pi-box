#!/bin/bash
set -euo pipefail

uid="$(id -u)"
gid="$(id -g)"

username="${CONTAINER_USER:-dev}"
groupname="${CONTAINER_GROUP:-dev}"

# Use a location the arbitrary runtime UID can write to.
runtime_dir="${TMPDIR:-/tmp}/container-user-${uid}"
mkdir -p "$runtime_dir"

passwd_file="$runtime_dir/passwd"
group_file="$runtime_dir/group"

# Start with the image's normal passwd/group databases so root and installed
# system users/groups still resolve normally.
cp /etc/passwd "$passwd_file"
cp /etc/group "$group_file"

# If this numeric UID already has an entry, overwrite the username with CONTAINER_USER.
# Otherwise, add one dynamically.
if getent passwd "$uid" >/dev/null 2>&1; then
    sed -i "s/^\([^:]*\):x:${uid}:/${username}:x:${uid}:/" "$passwd_file"
else
    echo "${username}:x:${uid}:${gid}:${username}:${HOME:-/home/${username}}:/bin/bash" >> "$passwd_file"
fi

if getent group "$gid" >/dev/null 2>&1; then
    sed -i "s/^\([^:]*\):x:${gid}:/${groupname}:x:${gid}:/" "$group_file"
else
    echo "${groupname}:x:${gid}:" >> "$group_file"
fi

export NSS_WRAPPER_PASSWD="$passwd_file"
export NSS_WRAPPER_GROUP="$group_file"
export LD_PRELOAD="/usr/lib/libnss_wrapper.so${LD_PRELOAD:+:$LD_PRELOAD}"
export TERM=xterm-256color
export HOME="/home/${username}"

exec "$@"
