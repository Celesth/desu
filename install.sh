#!/usr/bin/env bash
# Install DESU without assuming where the repository was cloned.

set -euo pipefail

SELF=$(readlink -f -- "${BASH_SOURCE[0]}")
ROOT=$(dirname -- "$SELF")
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${XDG_DATA_HOME:=${HOME}/.local/share}"
: "${XDG_STATE_HOME:=${HOME}/.local/state}"
: "${XDG_CACHE_HOME:=${HOME}/.cache}"
: "${DESU_BIN_DIR:=${HOME}/.local/bin}"

CONFIG_TARGET="${XDG_CONFIG_HOME}/desu"
PAYLOAD_SOURCE="${ROOT}/config"
COMMAND_TARGET="${DESU_BIN_DIR}/desu"
COMMAND_CONFIG="${COMMAND_TARGET}.config"
INSTALL_HYPRLAND=0
STAMP=$(date +%Y%m%d-%H%M%S)-$$

usage() {
    cat <<EOF
usage: ./install.sh [--bin-dir DIR] [--config-dir DIR] [--hyprland]

Installs the DESU payload, CLI, and settings. Existing targets are moved to
a timestamped backup before they are changed.
EOF
}

while (($#)); do
    case "$1" in
        --bin-dir)
            [[ $# -ge 2 ]] || { printf '%s\n' 'install.sh: --bin-dir needs a path' >&2; exit 2; }
            DESU_BIN_DIR=$2
            COMMAND_TARGET="${DESU_BIN_DIR}/desu"
            COMMAND_CONFIG="${COMMAND_TARGET}.config"
            shift 2
            ;;
        --config-dir)
            [[ $# -ge 2 ]] || { printf '%s\n' 'install.sh: --config-dir needs a path' >&2; exit 2; }
            CONFIG_TARGET=$2
            shift 2
            ;;
        --hyprland)
            INSTALL_HYPRLAND=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'install.sh: unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

[[ -d $PAYLOAD_SOURCE ]] || { printf '%s\n' "install.sh: missing payload: $PAYLOAD_SOURCE" >&2; exit 1; }
[[ -x ${ROOT}/desu ]] || { printf '%s\n' 'install.sh: desu CLI is not executable' >&2; exit 1; }

backup_path() {
    local path=$1 backup
    [[ -e $path || -L $path ]] || return 0
    backup="${path}.backup-${STAMP}"
    mv -- "$path" "$backup"
    printf 'backup: %s -> %s\n' "$path" "$backup"
}

mkdir -p "$DESU_BIN_DIR" "$(dirname -- "$CONFIG_TARGET")" \
    "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"

# A whole config directory is backed up atomically, so user edits and unknown
# files survive an upgrade and uninstall never has to guess ownership.
backup_path "$CONFIG_TARGET"
mkdir -p "$CONFIG_TARGET"
for payload_dir in quickshell scripts fuzzel hyprland; do
    cp -a -- "${PAYLOAD_SOURCE}/${payload_dir}" "$CONFIG_TARGET/"
done
install -m 644 "${PAYLOAD_SOURCE}/desu/config" "$CONFIG_TARGET/config"
install -m 644 "${ROOT}/VERSION" "${CONFIG_TARGET}/VERSION"
chmod 700 "$CONFIG_TARGET/scripts" 2>/dev/null || true
find "$CONFIG_TARGET/scripts" -type f -exec chmod 755 {} +

backup_path "$COMMAND_TARGET"
install -m 755 "${ROOT}/desu" "$COMMAND_TARGET"
backup_path "$COMMAND_CONFIG"
printf '%s\n' "$CONFIG_TARGET" >"$COMMAND_CONFIG"
chmod 600 "$COMMAND_CONFIG"

printf '%s\n' "$ROOT" >"${CONFIG_TARGET}/.source"

if (( INSTALL_HYPRLAND )); then
    HYPRLAND_TARGET="${XDG_CONFIG_HOME}/hypr/hyprland.lua"
    backup_path "$HYPRLAND_TARGET"
    mkdir -p "$(dirname -- "$HYPRLAND_TARGET")"
    install -m 644 "${PAYLOAD_SOURCE}/hyprland/hyprland.lua" "$HYPRLAND_TARGET"
    printf 'hyprland: %s\n' "$HYPRLAND_TARGET"
fi

printf 'installed DESU %s\n' "$(head -n 1 "${ROOT}/VERSION")"
printf 'command: %s\n' "$COMMAND_TARGET"
printf 'config:  %s\n' "$CONFIG_TARGET"
printf '%s\n' 'Run `desu doctor`; use `./install.sh --hyprland` to install the Lua Hyprland main config.'
