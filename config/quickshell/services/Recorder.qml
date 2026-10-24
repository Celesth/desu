pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Watches the recorder state file written by desu-recorder. No process is
// polled: FileView uses inotify and the only timer runs while a recording is
// active (to show elapsed time).
Singleton {
    id: root

    property bool active: false
    property string state: "idle"
    property string backend: ""
    property string output: ""
    property string error: ""
    property int pid: 0
    property int started: 0
    property int elapsed: 0

    readonly property string elapsedText: {
        const s = root.elapsed;
        return (s >= 3600 ? Math.floor(s / 3600) + ":" : "")
            + String(Math.floor((s % 3600) / 60)).padStart(2, "0") + ":"
            + String(s % 60).padStart(2, "0");
    }

    function parse(content) {
        const values = {};
        const lines = (content || "").split("\n");
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const eq = line.indexOf("=");
            if (eq > 0) values[line.slice(0, eq)] = line.slice(eq + 1);
        }
        root.state = values.state || "idle";
        root.active = root.state === "recording";
        root.backend = values.backend || "";
        root.output = values.output || "";
        root.error = values.error || "";
        root.pid = parseInt(values.pid || "0") || 0;
        root.started = parseInt(values.started || "0") || 0;
        if (root.active) root.updateElapsed();
        else root.elapsed = 0;
    }

    function updateElapsed() {
        if (!root.active || !root.started) {
            root.elapsed = 0;
            return;
        }
        root.elapsed = Math.max(0, Math.floor(Date.now() / 1000) - root.started);
    }

    function call(action) {
        if (actionProc.running) return;
        actionProc.command = [Settings.scriptsDir + "/desu-recorder", action];
        actionProc.running = true;
    }

    function start() { call("start"); }
    function stop() { call("stop"); }
    function toggle() { call(root.active ? "stop" : "start"); }

    FileView {
        id: stateFile
        path: Settings.runtimeDir + "/recorder.state"
        watchChanges: true
        printErrors: false
        onLoaded: root.parse(text())
        onFileChanged: reload()
        onLoadFailed: {
            root.state = "idle";
            root.active = false;
            root.elapsed = 0;
        }
    }

    Timer {
        id: tick
        interval: 1000
        repeat: true
        running: root.active
        onTriggered: root.updateElapsed()
    }

    Process {
        id: actionProc
        stdout: StdioCollector { id: actionOut; waitForEnd: true }
        stderr: StdioCollector { id: actionErr; waitForEnd: true }
        onExited: (code) => {
            const text = (code === 0 ? actionOut.text : actionErr.text).trim();
            if (text.length > 0) Desktop.notify(text, code !== 0);
            if (code === 0) stateFile.reload();
        }
    }
}
