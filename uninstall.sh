#!/usr/bin/env bash
# Remove DESU's installed payload while preserving user state and backups.

set -euo pipefail

: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${DESU_BIN_DIR:=${HOME}/.local/bin}"
CONFIG_TARGET="${XDG_CONFIG_HOME}/desu"
COMMAND_TARGET="${DESU_BIN_DIR}/desu"
COMMAND_CONFIG="${COMMAND_TARGET}.config"
STAMP=$(date +%Y%m%d-%H%M%S)-$$
PURGE=0

usage() {
    cat <<EOF
usage: ./uninstall.sh [--purge] [--bin-dir DIR] [--config-dir DIR]

Moves the installed DESU payload and command to backups. --purge also removes
DESU state and cache after an explicit request.
EOF
}

while (($#)); do
    case "$1" in
        --purge) PURGE=1; shift ;;
        --bin-dir)
            [[ $# -ge 2 ]] || { printf '%s\n' 'uninstall.sh: --bin-dir needs a path' >&2; exit 2; }
            COMMAND_TARGET="$2/desu"
            COMMAND_CONFIG="${COMMAND_TARGET}.config"
            shift 2
            ;;
        --config-dir)
            [[ $# -ge 2 ]] || { printf '%s\n' 'uninstall.sh: --config-dir needs a path' >&2; exit 2; }
            CONFIG_TARGET=$2
            shift 2
            ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'uninstall.sh: unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
done

move_to_backup() {
    local path=$1
    [[ -e $path || -L $path ]] || return 0
    mv -- "$path" "${path}.removed-${STAMP}"
    printf 'removed: %s (recoverable backup kept)\n' "$path"
}

move_to_backup "$COMMAND_TARGET"
move_to_backup "$COMMAND_CONFIG"
move_to_backup "$CONFIG_TARGET"

if (( PURGE )); then
    : "${XDG_STATE_HOME:=${HOME}/.local/state}"
    : "${XDG_CACHE_HOME:=${HOME}/.cache}"
    rm -rf -- "${XDG_STATE_HOME}/desu" "${XDG_CACHE_HOME}/desu"
    printf '%s\n' 'purged: DESU state and cache'
else
    printf '%s\n' 'preserved: DESU state and cache (use --purge to remove them)'
fi
