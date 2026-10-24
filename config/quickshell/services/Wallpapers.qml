pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Wallpaper browser state. Thumbnail generation happens once per changed file
// in desu-wallpaper-thumbs; the GridView only decodes visible cells.
Singleton {
    id: root

    property bool open: false
    property bool loading: false
    property string error: ""
    property string selected: ""
    property var items: []
    property bool applying: false

    function show() {
        root.open = true;
    }

    function hide() {
        root.open = false;
    }

    function refresh() {
        if (listProc.running) return;
        root.loading = true;
        root.error = "";
        listProc.command = [Settings.scriptsDir + "/desu-wallpaper-thumbs"];
        listProc.running = true;
    }

    function parseList(text) {
        const result = [];
        const lines = (text || "").split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            if (!line.length) continue;
            const parts = line.split("\t");
            if (parts.length < 2) continue;
            result.push({
                path: parts[0],
                thumb: parts[1],
                name: parts.length > 2 ? parts[2] : parts[0].split("/").pop()
            });
        }
        root.items = result;
    }

    function apply(path) {
        if (!path || applying) return;
        root.applying = true;
        root.error = "";
        applyProc.command = [Settings.scriptsDir + "/desu-wallpaper", "set", path];
        applyProc.running = true;
    }

    onOpenChanged: {
        if (root.open) root.refresh();
    }

    FileView {
        id: selectedFile
        path: Settings.stateDir + "/wallpaper"
        watchChanges: true
        printErrors: false
        onLoaded: {
            const lines = text().split("\n");
            root.selected = lines.length > 0 ? lines[0] : "";
        }
        onFileChanged: reload()
    }

    Process {
        id: listProc
        stdout: StdioCollector { id: listOut; waitForEnd: true }
        stderr: StdioCollector { id: listErr; waitForEnd: true }
        onExited: (code) => {
            root.loading = false;
            if (code === 0) {
                root.parseList(listOut.text);
            } else {
                root.items = [];
                root.error = (listErr.text || "could not list wallpapers").trim();
            }
        }
    }

    Process {
        id: applyProc
        stdout: StdioCollector { id: applyOut; waitForEnd: true }
        stderr: StdioCollector { id: applyErr; waitForEnd: true }
        onExited: (code) => {
            root.applying = false;
            if (code === 0) {
                root.open = false;
                const message = (applyOut.text || "wallpaper applied").trim();
                Desktop.notify(message, false);
                selectedFile.reload();
            } else {
                root.error = (applyErr.text || "could not apply wallpaper").trim();
                Desktop.notify(root.error, true);
            }
        }
    }
}
