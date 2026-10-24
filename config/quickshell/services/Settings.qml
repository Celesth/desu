pragma Singleton

import QtQuick
import Quickshell

// Settings are injected by the `desu` CLI as DESU_* environment variables.
// When the shell is started directly with `quickshell -p`, the same defaults
// are used.
Singleton {
    id: root

    function env(name, fallback) {
        const value = Quickshell.env(name);
        return (value !== undefined && value !== null && value !== "") ? value : fallback;
    }

    function envInt(name, fallback) {
        const value = parseInt(Quickshell.env(name));
        return isNaN(value) ? fallback : value;
    }

    readonly property string home: env("HOME", "")
    readonly property string configHome: env("XDG_CONFIG_HOME", root.home + "/.config")
    readonly property string desuConfigHome: env("DESU_CONFIG_HOME", root.configHome + "/desu")
    readonly property string stateHome: env("XDG_STATE_HOME", root.home + "/.local/state")
    readonly property string cacheHome: env("XDG_CACHE_HOME", root.home + "/.cache")
    readonly property string runtimeDir: env("DESU_RUNTIME_DIR",
        env("XDG_RUNTIME_DIR", "/tmp") + "/desu")

    readonly property string version: env("DESU_VERSION", "dev")
    readonly property string shellDir: Quickshell.shellDir
    readonly property string scriptsDir: env("DESU_SCRIPTS_DIR", root.shellDir + "/../scripts")
    readonly property string fuzzelConfig: env("DESU_FUZZEL_CONFIG",
        root.desuConfigHome + "/fuzzel/fuzzel.ini")

    readonly property string barEdge: env("DESU_BAR_EDGE", "top")
    readonly property int barHeight: Math.max(18, envInt("DESU_BAR_HEIGHT", 28))
    readonly property int barMargin: Math.max(0, envInt("DESU_BAR_MARGIN", 0))
    readonly property string fontFamily: env("DESU_FONT", "Iosevka Nerd Font")
    readonly property int fontSize: Math.max(8, envInt("DESU_FONT_SIZE", 10))
    readonly property string timeFormat: env("DESU_TIME_FORMAT", "HH:mm")
    readonly property string dateFormat: env("DESU_DATE_FORMAT", "ddd dd MMM yyyy")

    readonly property string wallpaperDir: env("DESU_WALLPAPER_DIR", root.home + "/Pictures/Wallpapers")
    readonly property string recorderOutputDir: env("DESU_RECORDER_OUTPUT_DIR", root.home + "/Videos/Recordings")
    readonly property string stateDir: env("DESU_STATE_HOME", root.stateHome + "/desu")
}
