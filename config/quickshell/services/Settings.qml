pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

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

    property string barEdge: normalizeEdge(env("DESU_BAR_EDGE", "top"))
    property string barStyle: normalizeStyle(env("DESU_BAR_STYLE", "classic"))
    readonly property int barHeight: Math.max(18, envInt("DESU_BAR_HEIGHT", 28))
    readonly property int barMargin: Math.max(0, envInt("DESU_BAR_MARGIN", 0))
    readonly property int barPadding: barStyle === "compact" ? 10 : 16
    readonly property int barInset: barStyle === "squircle" ? 4
        : (barStyle === "detached" ? 10 : 0)
    readonly property int barSideInset: barStyle === "squircle" ? 8
        : (barStyle === "detached" ? 36 : 0)
    readonly property int barRadius: barStyle === "squircle" ? 14
        : (barStyle === "detached" ? 18 : 0)
    readonly property int barPanelHeight: barHeight + barInset * 2
    readonly property string fontFamily: env("DESU_FONT", "Iosevka Nerd Font")
    readonly property int fontSize: Math.max(8, envInt("DESU_FONT_SIZE", 10))
    readonly property string timeFormat: env("DESU_TIME_FORMAT", "HH:mm")
    readonly property string dateFormat: env("DESU_DATE_FORMAT", "ddd dd MMM yyyy")

    readonly property string wallpaperDir: env("DESU_WALLPAPER_DIR", root.home + "/Pictures/Wallpapers")
    readonly property string recorderOutputDir: env("DESU_RECORDER_OUTPUT_DIR", root.home + "/Videos/Recordings")
    readonly property string stateDir: env("DESU_STATE_HOME", root.stateHome + "/desu")

    property bool barSettingsOpen: false
    property string barSettingsError: ""

    function normalizeEdge(value) {
        return value === "bottom" ? "bottom" : "top";
    }

    function normalizeStyle(value) {
        return ["classic", "compact", "minimal", "squircle", "detached"].indexOf(value) !== -1
            ? value : "classic";
    }

    function toggleBarSettings() {
        root.barSettingsOpen = !root.barSettingsOpen;
    }

    function closeBarSettings() {
        root.barSettingsOpen = false;
    }

    function setBarSettings(edge, style) {
        root.barEdge = root.normalizeEdge(edge);
        root.barStyle = root.normalizeStyle(style);
        root.barSettingsError = "";
        saveTimer.restart();
    }

    Timer {
        id: saveTimer
        interval: 100
        repeat: false
        onTriggered: {
            if (saveProcess.running) {
                saveTimer.restart();
                return;
            }
            saveProcess.command = [
                root.scriptsDir + "/desu-bar-settings",
                root.desuConfigHome + "/config",
                root.barEdge,
                root.barStyle
            ];
            saveProcess.running = true;
        }
    }

    Process {
        id: saveProcess
        stdout: StdioCollector { id: saveOutput }
        stderr: StdioCollector { id: saveError }
        onExited: (code) => {
            if (code !== 0) {
                root.barSettingsError = (saveError.text || "could not save bar settings").trim();
            }
        }
    }
}
