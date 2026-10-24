pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property string message: ""
    property bool messageIsError: false

    readonly property var focusedScreen: {
        const monitor = Hyprland.focusedMonitor;
        if (monitor) {
            const screen = Quickshell.screens.find(s => Hyprland.monitorFor(s) === monitor);
            if (screen) return screen;
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    function notify(text, isError) {
        root.message = text || "";
        root.messageIsError = !!isError;
        messageTimer.restart();
    }

    Timer {
        id: messageTimer
        interval: 4500
        repeat: false
        onTriggered: {
            root.message = "";
            root.messageIsError = false;
        }
    }

    function openClipboard() {
        if (clipboardProc.running) return;
        clipboardProc.command = [Settings.scriptsDir + "/desu-clipboard", "show"];
        clipboardProc.running = true;
    }

    function openLauncher() {
        if (launcherProc.running) return;
        launcherProc.command = [Settings.scriptsDir + "/desu-launcher"];
        launcherProc.running = true;
    }

    function openMixer() {
        if (mixerProc.running) return;
        mixerProc.command = [Settings.scriptsDir + "/desu-audio"];
        mixerProc.running = true;
    }

    Process {
        id: clipboardProc
        stdout: StdioCollector { id: clipboardOut; waitForEnd: true }
        stderr: StdioCollector { id: clipboardErr; waitForEnd: true }
        onExited: (code) => {
            if (code !== 0) {
                const text = (clipboardErr.text || "clipboard helper failed").trim();
                root.notify(text, true);
            }
        }
    }

    Process {
        id: launcherProc
        stdout: StdioCollector { id: launcherOut; waitForEnd: true }
        stderr: StdioCollector { id: launcherErr; waitForEnd: true }
        onExited: (code) => {
            if (code !== 0) {
                const text = (launcherErr.text || "fuzzel is not available").trim();
                root.notify(text, true);
            }
        }
    }

    Process {
        id: mixerProc
        stdout: StdioCollector { id: mixerOut; waitForEnd: true }
        stderr: StdioCollector { id: mixerErr; waitForEnd: true }
        onExited: (code) => {
            if (code !== 0) {
                const text = (mixerErr.text || "pavucontrol is not available").trim();
                root.notify(text, true);
            }
        }
    }
}
