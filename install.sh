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
    BACKUP_PATH=$backup
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

install_matugen() {
    local matugen_dir="${XDG_CONFIG_HOME}/matugen"
    local matugen_config="${matugen_dir}/config.toml"
    local kitty_dir="${XDG_CONFIG_HOME}/kitty"
    local kitty_conf="${kitty_dir}/kitty.conf"
    local btop_dir="${XDG_CONFIG_HOME}/btop"
    local btop_conf="${btop_dir}/btop.conf"
    local btop_theme="${btop_dir}/themes/desu.theme"

    [[ -f ${PAYLOAD_SOURCE}/matugen/config.toml ]] || return 0
    mkdir -p "${matugen_dir}/templates"
    if [[ -f $matugen_config ]] && ! cmp -s "${PAYLOAD_SOURCE}/matugen/config.toml" "$matugen_config"; then
        backup_path "$matugen_config"
    fi
    install -m 644 "${PAYLOAD_SOURCE}/matugen/config.toml" "$matugen_config"
    for template in "${PAYLOAD_SOURCE}/matugen/templates"/*; do
        [[ -f $template ]] || continue
        install -m 644 "$template" "${matugen_dir}/templates/$(basename -- "$template")"
    done

    mkdir -p "$kitty_dir"
    if [[ -f $kitty_conf ]] && ! grep -Fqx 'include desu-colors.conf' "$kitty_conf"; then
        backup_path "$kitty_conf"
        cat "$BACKUP_PATH" >"$kitty_conf"
        printf '\ninclude desu-colors.conf\n' >>"$kitty_conf"
    elif [[ ! -f $kitty_conf ]]; then
        printf 'include desu-colors.conf\n' >"$kitty_conf"
    fi

    mkdir -p "${btop_dir}/themes"
    if [[ -f $btop_conf ]] && ! grep -Fq "color_theme = \"$btop_theme\"" "$btop_conf"; then
        backup_path "$btop_conf"
        awk -v theme="$btop_theme" '
            /^color_theme[[:space:]]*=/ {
                print "color_theme = \"" theme "\""
                replaced = 1
                next
            }
            { print }
            END {
                if (!replaced) print "color_theme = \"" theme "\""
            }
        ' "$BACKUP_PATH" >"$btop_conf"
    elif [[ ! -f $btop_conf ]]; then
        printf 'color_theme = "%s"\n' "$btop_theme" >"$btop_conf"
    fi
}

install_matugen

install_starship() {
    local starship_target="${XDG_CONFIG_HOME}/starship.toml"
    local fish_dir="${XDG_CONFIG_HOME}/fish"
    local fish_config="${fish_dir}/config.fish"

    if [[ -f ${PAYLOAD_SOURCE}/starship.toml ]]; then
        mkdir -p "$(dirname -- "$starship_target")"
        if [[ -f $starship_target ]] && ! cmp -s "${PAYLOAD_SOURCE}/starship.toml" "$starship_target"; then
            backup_path "$starship_target"
        fi
        install -m 644 "${PAYLOAD_SOURCE}/starship.toml" "$starship_target"
    fi

    if command -v starship >/dev/null 2>&1; then
        mkdir -p "$fish_dir"
        if [[ -f $fish_config ]] && ! grep -Fq 'starship init fish | source' "$fish_config"; then
            backup_path "$fish_config"
            cat "$BACKUP_PATH" >"$fish_config"
            printf '\nstarship init fish | source\n' >>"$fish_config"
        elif [[ ! -f $fish_config ]]; then
            printf 'starship init fish | source\n' >"$fish_config"
        fi
    fi
}

install_starship

install_fastfetch() {
    local fastfetch_dir="${XDG_CONFIG_HOME}/fastfetch"
    local fastfetch_config="${fastfetch_dir}/config.jsonc"
    local fish_dir="${XDG_CONFIG_HOME}/fish"
    local fish_config="${fish_dir}/config.fish"

    if [[ -f ${PAYLOAD_SOURCE}/fastfetch/config.jsonc ]]; then
        mkdir -p "$fastfetch_dir"
        install -m 644 "${PAYLOAD_SOURCE}/fastfetch/config.jsonc" "$fastfetch_config"
        if [[ -f ${fastfetch_dir}/desu.jsonc ]]; then
            backup_path "${fastfetch_dir}/desu.jsonc"
        fi
    fi

    if ! command -v fish >/dev/null 2>&1; then
        return 0
    fi

    mkdir -p "$fish_dir"
    if [[ -f $fish_config ]]; then
        if grep -Fq 'function fish_greeting' "$fish_config" || \
                ! grep -Fq '# DESU Fastfetch' "$fish_config" || \
                ! grep -Fq 'fastfetch --config "$HOME/.config/fastfetch/config.jsonc"' "$fish_config"; then
            backup_path "$fish_config"
            awk '
                /^function fish_greeting([[:space:]]|$)/ {
                    skipping = 1
                    depth = 1
                    next
                }
                /^# DESU Fastfetch$/ {
                    skipping_fastfetch = 1
                    next
                }
                skipping_fastfetch {
                    if ($0 ~ /^end([[:space:]]|$)/) skipping_fastfetch = 0
                    next
                }
                skipping {
                    if ($0 ~ /^(if|for|while|function)[[:space:]]/) depth++
                    if ($0 ~ /^end([[:space:]]|$)/) {
                        depth--
                        if (depth == 0) skipping = 0
                    }
                    next
                }
                { print }
            ' "$BACKUP_PATH" >"$fish_config"
            cat >>"$fish_config" <<'EOF'

# DESU Fastfetch
function ffetch
    fastfetch --config "$HOME/.config/fastfetch/config.jsonc" $argv
end
EOF
        fi
    else
        cat >"$fish_config" <<'EOF'
# DESU Fastfetch
function ffetch
    fastfetch --config "$HOME/.config/fastfetch/config.jsonc" $argv
end
EOF
    fi
}

install_fastfetch

backup_path "$COMMAND_TARGET"
install -m 755 "${ROOT}/desu" "$COMMAND_TARGET"
backup_path "$COMMAND_CONFIG"
printf '%s\n' "$CONFIG_TARGET" >"$COMMAND_CONFIG"
chmod 600 "$COMMAND_CONFIG"

printf '%s\n' "$ROOT" >"${CONFIG_TARGET}/.source"

generate_matugen() {
    local wallpaper_state="${XDG_STATE_HOME}/desu/wallpaper"
    local wallpaper
    command -v matugen >/dev/null 2>&1 || return 0
    [[ -r $wallpaper_state ]] || return 0
    wallpaper=$(sed -n '1p' "$wallpaper_state")
    [[ -f $wallpaper ]] || return 0
    matugen image "$wallpaper" --source-color-index 0 --mode dark --quiet ||
        printf '%s\n' 'warning: Matugen could not generate the current palette' >&2
}

generate_matugen

if (( INSTALL_HYPRLAND )); then
    HYPRLAND_TARGET="${XDG_CONFIG_HOME}/hypr/hyprland.lua"
    HYPRLAND_MODULE_TARGET="${XDG_CONFIG_HOME}/hypr/desu"
    backup_path "$HYPRLAND_MODULE_TARGET"
    mkdir -p "$HYPRLAND_MODULE_TARGET"
    cp -a -- "${PAYLOAD_SOURCE}/hyprland/desu/." "$HYPRLAND_MODULE_TARGET/"
    backup_path "$HYPRLAND_TARGET"
    mkdir -p "$(dirname -- "$HYPRLAND_TARGET")"
    install -m 644 "${PAYLOAD_SOURCE}/hyprland/hyprland.lua" "$HYPRLAND_TARGET"
    HYPRIDLE_TARGET="${XDG_CONFIG_HOME}/hypr/hypridle.conf"
    HYPRLOCK_TARGET="${XDG_CONFIG_HOME}/hypr/hyprlock.conf"
    backup_path "$HYPRIDLE_TARGET"
    backup_path "$HYPRLOCK_TARGET"
    install -m 644 "${PAYLOAD_SOURCE}/hyprland/hypridle.conf" "$HYPRIDLE_TARGET"
    install -m 644 "${PAYLOAD_SOURCE}/hyprland/hyprlock.conf" "$HYPRLOCK_TARGET"
    printf 'hyprland: %s\n' "$HYPRLAND_TARGET"
    printf 'hyprland modules: %s\n' "$HYPRLAND_MODULE_TARGET"
    printf 'hypridle: %s\n' "$HYPRIDLE_TARGET"
    printf 'hyprlock: %s\n' "$HYPRLOCK_TARGET"
fi

printf 'installed DESU %s\n' "$(head -n 1 "${ROOT}/VERSION")"
printf 'command: %s\n' "$COMMAND_TARGET"
printf 'config:  %s\n' "$CONFIG_TARGET"
printf '%s\n' 'Run `desu doctor`; use `./install.sh --hyprland` to install the Lua Hyprland main config.'
