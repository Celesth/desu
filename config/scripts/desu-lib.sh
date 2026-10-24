#!/usr/bin/env bash
# Shared helpers for the DESU CLI and helper scripts.
# This file is sourced. It is deliberately dependency-free beyond coreutils.

# ---------------------------------------------------------------------------
# Locations
# ---------------------------------------------------------------------------

_desu_lib_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

case "$_desu_lib_dir" in
    */config/scripts) DESU_PAYLOAD_ROOT=${_desu_lib_dir%/config/scripts} ;;
    *)                DESU_PAYLOAD_ROOT=$(dirname -- "$_desu_lib_dir") ;;
esac
export DESU_PAYLOAD_ROOT

: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${DESU_CONFIG_HOME:=${XDG_CONFIG_HOME}/desu}"
: "${XDG_STATE_HOME:=${HOME}/.local/state}"
: "${XDG_CACHE_HOME:=${HOME}/.cache}"
: "${XDG_DATA_HOME:=${HOME}/.local/share}"

if [[ -n ${XDG_RUNTIME_DIR:-} && -d ${XDG_RUNTIME_DIR:-} ]]; then
    : "${DESU_RUNTIME_DIR:=${XDG_RUNTIME_DIR}/desu}"
else
    : "${DESU_RUNTIME_DIR:=/tmp/desu-$(id -u)}"
fi

DESU_CONFIG_FILE="${DESU_CONFIG_HOME}/config"
DESU_STATE_HOME="${XDG_STATE_HOME}/desu"
DESU_CACHE_HOME="${XDG_CACHE_HOME}/desu"
DESU_DATA_HOME="${XDG_DATA_HOME}/desu"

DESU_PIDFILE="${DESU_RUNTIME_DIR}/desu.pid"
DESU_SHELL_LOG="${DESU_STATE_HOME}/quickshell.log"
DESU_RECORDER_STATE="${DESU_RUNTIME_DIR}/recorder.state"
DESU_RECORDER_PIDFILE="${DESU_RUNTIME_DIR}/recorder.pid"
DESU_RECORDER_LOCK="${DESU_RUNTIME_DIR}/recorder.lock"
DESU_CLIP_TEXT_PIDFILE="${DESU_RUNTIME_DIR}/cliphist-text.pid"
DESU_CLIP_IMAGE_PIDFILE="${DESU_RUNTIME_DIR}/cliphist-image.pid"
DESU_WALLPAPER_STATE="${DESU_STATE_HOME}/wallpaper"

export DESU_CONFIG_HOME DESU_CONFIG_FILE DESU_STATE_HOME DESU_CACHE_HOME \
       DESU_DATA_HOME DESU_RUNTIME_DIR DESU_PIDFILE DESU_SHELL_LOG \
       DESU_RECORDER_STATE DESU_RECORDER_PIDFILE DESU_RECORDER_LOCK \
       DESU_CLIP_TEXT_PIDFILE DESU_CLIP_IMAGE_PIDFILE DESU_WALLPAPER_STATE

# Payload-relative directories. Repo layout is config/*, installed payload is
# ~/.config/desu/*.
if [[ -d ${DESU_PAYLOAD_ROOT}/config/quickshell ]]; then
    DESU_QUICKSHELL_DIR="${DESU_PAYLOAD_ROOT}/config/quickshell"
    DESU_SCRIPTS_DIR="${DESU_PAYLOAD_ROOT}/config/scripts"
    DESU_FUZZEL_DIR="${DESU_PAYLOAD_ROOT}/config/fuzzel"
    DESU_HYPRLAND_DIR="${DESU_PAYLOAD_ROOT}/config/hyprland"
else
    DESU_QUICKSHELL_DIR="${DESU_PAYLOAD_ROOT}/quickshell"
    DESU_SCRIPTS_DIR="${DESU_PAYLOAD_ROOT}/scripts"
    DESU_FUZZEL_DIR="${DESU_PAYLOAD_ROOT}/fuzzel"
    DESU_HYPRLAND_DIR="${DESU_PAYLOAD_ROOT}/hyprland"
fi

DESU_SHELL_QML="${DESU_QUICKSHELL_DIR}/shell.qml"
DESU_FUZZEL_CONFIG="${DESU_FUZZEL_DIR}/fuzzel.ini"
export DESU_QUICKSHELL_DIR DESU_SCRIPTS_DIR DESU_FUZZEL_DIR \
       DESU_HYPRLAND_DIR DESU_SHELL_QML DESU_FUZZEL_CONFIG

_desu_find_version() {
    local f
    for f in "${DESU_PAYLOAD_ROOT}/VERSION" "${DESU_PAYLOAD_ROOT}/../VERSION"; do
        if [[ -r $f ]]; then
            head -n 1 "$f"
            return 0
        fi
    done
    printf 'unknown\n'
}
DESU_VERSION=$(_desu_find_version)
export DESU_VERSION

# ---------------------------------------------------------------------------
# Settings
# ---------------------------------------------------------------------------

# Defaults document the supported knobs. Existing environment variables win
# over the settings file, so `DESU_BAR_HEIGHT=34 desu start` works.
_desu_defaults() {
    DESU_BAR_EDGE="top"
    DESU_BAR_HEIGHT=28
    DESU_BAR_MARGIN=0
    DESU_FONT="Iosevka Nerd Font"
    DESU_FONT_SIZE=10
    DESU_WALLPAPER_DIR="${HOME}/Pictures/Wallpapers"
    DESU_WALLPAPER_BACKEND="awww"
    DESU_RECORDER_BACKEND="auto"
    DESU_RECORDER_OUTPUT_DIR="${HOME}/Videos/Recordings"
    DESU_RECORDER_FPS=60
    DESU_RECORDER_AUDIO=1
    DESU_RECORDER_QUALITY="very_high"
    DESU_RECORDER_OPTIONS=""
    DESU_TIME_FORMAT="HH:mm"
    DESU_DATE_FORMAT="ddd dd MMM yyyy"
    DESU_LAUNCHER="fuzzel"
}

_desu_expand_path() {
    local p=$1
    case "$p" in
        "~") p=${HOME} ;;
        "~/"*) p="${HOME}/${p#\~/}" ;;
    esac
    p=${p//\$\{HOME\}/${HOME}}
    p=${p//\$HOME/${HOME}}
    printf '%s' "$p"
}

desu_load_settings() {
    local _desu_env_vars=() _desu_env_values=() _var

    # Remember explicitly supplied environment variables.
    while IFS= read -r _var; do
        _desu_env_vars+=("$_var")
        _desu_env_values+=("${!_var}")
    done < <(compgen -e | grep '^DESU_' || true)

    _desu_defaults
    if [[ -r $DESU_CONFIG_FILE ]]; then
        # The settings file is shell syntax and may use $HOME.
        # shellcheck disable=SC1090
        source "$DESU_CONFIG_FILE"
    fi

    local i
    for i in "${!_desu_env_vars[@]}"; do
        printf -v "${_desu_env_vars[$i]}" '%s' "${_desu_env_values[$i]}"
    done

    DESU_WALLPAPER_DIR=$(_desu_expand_path "$DESU_WALLPAPER_DIR")
    DESU_RECORDER_OUTPUT_DIR=$(_desu_expand_path "$DESU_RECORDER_OUTPUT_DIR")

    export DESU_BAR_EDGE DESU_BAR_HEIGHT DESU_BAR_MARGIN DESU_FONT \
           DESU_FONT_SIZE DESU_WALLPAPER_DIR DESU_WALLPAPER_BACKEND \
           DESU_RECORDER_BACKEND DESU_RECORDER_OUTPUT_DIR DESU_RECORDER_FPS \
           DESU_RECORDER_AUDIO DESU_RECORDER_QUALITY DESU_RECORDER_OPTIONS \
           DESU_TIME_FORMAT DESU_DATE_FORMAT DESU_LAUNCHER
}

# ---------------------------------------------------------------------------
# Runtime helpers
# ---------------------------------------------------------------------------

desu_ensure_dirs() {
    mkdir -p "$DESU_RUNTIME_DIR" "$DESU_STATE_HOME" "$DESU_CACHE_HOME" "$DESU_CONFIG_HOME"
    chmod 700 "$DESU_RUNTIME_DIR" 2>/dev/null || true
}

desu_have() { command -v "$1" >/dev/null 2>&1; }

desu_qs() {
    if desu_have quickshell; then
        command -v quickshell
    elif desu_have qs; then
        command -v qs
    else
        return 127
    fi
}

desu_pid_from_file() {
    local file=$1 pid
    [[ -r $file ]] || return 1
    read -r pid <"$file" || return 1
    [[ $pid =~ ^[0-9]+$ ]] || return 1
    printf '%s\n' "$pid"
}

desu_pid_alive() {
    local pid=$1
    [[ $pid =~ ^[0-9]+$ ]] || return 1
    kill -0 "$pid" 2>/dev/null
}

# Check that a pid still belongs to the expected program before signalling it.
# This prevents killing an unrelated process after pid reuse.
desu_pid_matches() {
    local pid=$1 needle=$2 cmd
    [[ -r /proc/$pid/cmdline ]] || return 1
    cmd=$(tr '\0' ' ' <"/proc/$pid/cmdline" 2>/dev/null) || return 1
    [[ $cmd == *"$needle"* ]]
}

desu_shell_pid() {
    local pid
    pid=$(desu_pid_from_file "$DESU_PIDFILE") || return 1
    desu_pid_alive "$pid" || return 1
    desu_pid_matches "$pid" quickshell || desu_pid_matches "$pid" /qs || return 1
    printf '%s\n' "$pid"
}

desu_shell_running() {
    desu_shell_pid >/dev/null 2>&1
}

desu_ipc() {
    local pid
    pid=$(desu_shell_pid) || return 4
    "$(desu_qs)" ipc --pid "$pid" call desu "$@"
}

desu_status_json() {
    local pid state=stopped ipc=no recorder=unknown
    if pid=$(desu_shell_pid); then
        state=running
        if desu_ipc ping >/dev/null 2>&1; then ipc=ok; else ipc=unreachable; fi
    fi
    if [[ -x ${DESU_SCRIPTS_DIR}/desu-recorder ]]; then
        recorder=$("${DESU_SCRIPTS_DIR}/desu-recorder" status --field state 2>/dev/null || echo unknown)
    fi
    printf '{"version":"%s","state":"%s","pid":%s,"ipc":"%s","recorder":"%s","shell":"%s"}\n' \
        "$DESU_VERSION" "$state" "${pid:-0}" "$ipc" "$recorder" "$DESU_SHELL_QML"
}

# ---------------------------------------------------------------------------
# Clipboard watchers
# ---------------------------------------------------------------------------

desu_clipboard_watchers_start() {
    desu_have cliphist || return 0
    desu_have wl-paste || return 0

    if ! (desu_pid_from_file "$DESU_CLIP_TEXT_PIDFILE" >/dev/null &&
          desu_pid_alive "$(desu_pid_from_file "$DESU_CLIP_TEXT_PIDFILE")"); then
        setsid wl-paste --type text --watch cliphist store \
            >>"${DESU_STATE_HOME}/cliphist.log" 2>&1 </dev/null &
        printf '%s\n' "$!" >"$DESU_CLIP_TEXT_PIDFILE"
    fi

    if ! (desu_pid_from_file "$DESU_CLIP_IMAGE_PIDFILE" >/dev/null &&
          desu_pid_alive "$(desu_pid_from_file "$DESU_CLIP_IMAGE_PIDFILE")"); then
        setsid wl-paste --type image --watch cliphist store \
            >>"${DESU_STATE_HOME}/cliphist.log" 2>&1 </dev/null &
        printf '%s\n' "$!" >"$DESU_CLIP_IMAGE_PIDFILE"
    fi
}

_desu_stop_one() {
    local pidfile=$1 pid
    pid=$(desu_pid_from_file "$pidfile") || { rm -f "$pidfile"; return 0; }
    if desu_pid_alive "$pid" && desu_pid_matches "$pid" wl-paste; then
        kill -TERM "$pid" 2>/dev/null || true
    fi
    rm -f "$pidfile"
}

desu_clipboard_watchers_stop() {
    _desu_stop_one "$DESU_CLIP_TEXT_PIDFILE"
    _desu_stop_one "$DESU_CLIP_IMAGE_PIDFILE"
}

# ---------------------------------------------------------------------------
# Misc
# ---------------------------------------------------------------------------

desu_detach() {
    # Run a command fully detached from the caller and return immediately.
    setsid "$@" >>"${DESU_STATE_HOME}/detached.log" 2>&1 </dev/null &
}

desu_fuzzel() {
    local -a args=(fuzzel)
    [[ -r $DESU_FUZZEL_CONFIG ]] && args+=(--config "$DESU_FUZZEL_CONFIG")
    args+=("$@")
    exec "${args[@]}"
}

desu_require_shell() {
    if ! desu_shell_running; then
        printf 'desu: shell is not running (start it with: desu start)\n' >&2
        return 1
    fi
}
