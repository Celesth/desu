pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool open: false
    property string pendingAction: ""

    function show() {
        root.pendingAction = "";
        root.open = true;
    }

    function hide() {
        root.pendingAction = "";
        root.open = false;
    }

    function toggle() {
        if (root.open) root.hide();
        else root.show();
    }

    function request(action) {
        if (action === "lock") {
            root.execute("hyprlock -c \"$HOME/.config/hypr/hyprlock.conf\"");
            return;
        }
        root.pendingAction = action;
    }

    function confirm() {
        const commands = {
            suspend: "systemctl suspend",
            reboot: "systemctl reboot",
            shutdown: "systemctl poweroff"
        };
        const command = commands[root.pendingAction];
        if (!command) return;
        root.execute(command);
    }

    function execute(command) {
        if (actionProcess.running) return;
        root.hide();
        actionProcess.command = ["sh", "-c", command];
        actionProcess.running = true;
    }

    Process {
        id: actionProcess

        stdout: StdioCollector { id: actionOutput }
        stderr: StdioCollector { id: actionError }

        onExited: (code) => {
            if (code !== 0) {
                Desktop.notify((actionError.text || "power action failed").trim(), true);
            }
        }
    }
}
