#!/usr/bin/env bash
# Ensure ~/.grok is writable by the grok user, then drop root.
# Named volumes and first-run mounts are often created as root, so login
# cannot write auth.json after the browser/device flow completes.
set -euo pipefail

GROK_UID=1000
GROK_GID=1000
AUTH_DIR="${GROK_HOME:-${HOME:-/home/grok}/.grok}"
RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/${GROK_UID}}"

mkdir -p "$AUTH_DIR" "$RUNTIME_DIR"

if [ "$(id -u)" -eq 0 ]; then
    chown -R "${GROK_UID}:${GROK_GID}" "$AUTH_DIR"
    chown "${GROK_UID}:${GROK_GID}" "$RUNTIME_DIR"
    chmod 0700 "$AUTH_DIR" "$RUNTIME_DIR"
    export HOME=/home/grok
    export GROK_HOME="${GROK_HOME:-/home/grok/.grok}"
    export XDG_RUNTIME_DIR="$RUNTIME_DIR"
    exec setpriv --reuid="${GROK_UID}" --regid="${GROK_GID}" --init-groups -- "$@"
fi

if [ ! -w "$AUTH_DIR" ]; then
    echo "error: cannot write to authentication directory ${AUTH_DIR}" >&2
    echo "hint: chown the volume to uid ${GROK_UID} or run the container without --user" >&2
    exit 1
fi

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-$RUNTIME_DIR}"
exec "$@"
