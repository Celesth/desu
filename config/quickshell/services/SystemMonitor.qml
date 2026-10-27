pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool open: false
    property int cpuPercent: 0
    property int ramPercent: 0
    property string gpuText: "GPU —"
    property string temperatureText: "—"
    property string diskText: "—"
    property string uptimeText: "—"
    property string loadText: "—"

    property real previousTotal: 0
    property real previousIdle: 0

    readonly property string compactLabel: "SYS " + root.cpuPercent + "%"

    function refresh() {
        if (!statsProcess.running) {
            statsProcess.command = ["sh", "-c",
                "awk '/^cpu / { total=$2+$3+$4+$5+$6+$7+$8+$9; idle=$5+$6 } " +
                "/^MemTotal:/ { totalmem=$2 } /^MemAvailable:/ { available=$2 } " +
                "END { printf \"%s\\t%s\\t%s\\t%s\", total, idle, totalmem, available }' /proc/stat /proc/meminfo; " +
                "printf '\\t%s\\t%s\\t' \"$(awk '{print int($1)}' /proc/uptime)\" \"$(awk '{print $1}' /proc/loadavg)\"; " +
                "temperature=$(for file in /sys/class/thermal/thermal_zone*/temp; do " +
                "[ -r \"$file\" ] || continue; value=$(cat \"$file\"); " +
                "[ \"$value\" -gt 1000 ] 2>/dev/null && value=$((value / 1000)); " +
                "printf '%s\\n' \"$value\"; done | sort -nr | head -n1); " +
                "printf '%s\\t' \"${temperature:-0}\"; " +
                "df -P \"$HOME\" | awk 'NR==2 { gsub(\"%\", \"\", $5); print $5 }'"
            ];
            statsProcess.running = true;
        }

        if (!gpuProcess.running) {
            gpuProcess.command = ["sh", "-c",
                "if command -v nvidia-smi >/dev/null 2>&1; then " +
                "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu " +
                "--format=csv,noheader,nounits 2>/dev/null | head -n1 | " +
                "awk -F, '{ gsub(/[[:space:]]/, \"\", $1); gsub(/[[:space:]]/, \"\", $2); " +
                "printf \"GPU %s%% · %s°C\", $1, $2 }'; " +
                "else printf 'GPU —'; fi"
            ];
            gpuProcess.running = true;
        }
    }

    function formatUptime(seconds) {
        const days = Math.floor(seconds / 86400);
        const hours = Math.floor((seconds % 86400) / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        if (days > 0) return days + "d " + hours + "h";
        if (hours > 0) return hours + "h " + minutes + "m";
        return minutes + "m";
    }

    Timer {
        interval: 2000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: statsProcess
        stdout: StdioCollector { id: statsOutput; waitForEnd: true }
        onExited: (code) => {
            if (code !== 0) return;
            const values = statsOutput.text.trim().split("\t");
            if (values.length < 8) return;

            const total = parseFloat(values[0]);
            const idle = parseFloat(values[1]);
            if (root.previousTotal > 0 && total > root.previousTotal) {
                const totalDelta = total - root.previousTotal;
                const idleDelta = idle - root.previousIdle;
                root.cpuPercent = Math.round(Math.max(0, Math.min(100,
                    (1 - idleDelta / totalDelta) * 100)));
            }
            root.previousTotal = total;
            root.previousIdle = idle;

            const memoryTotal = parseFloat(values[2]);
            const memoryAvailable = parseFloat(values[3]);
            root.ramPercent = Math.round(Math.max(0, Math.min(100,
                (1 - memoryAvailable / memoryTotal) * 100)));
            root.uptimeText = root.formatUptime(parseInt(values[4]) || 0);
            root.loadText = values[5] || "—";
            const temperature = parseInt(values[6]) || 0;
            root.temperatureText = temperature > 0 ? temperature + "°C" : "—";
            root.diskText = values[7] ? values[7] + "%" : "—";
        }
    }

    Process {
        id: gpuProcess
        stdout: StdioCollector { id: gpuOutput; waitForEnd: true }
        onExited: (code) => {
            root.gpuText = code === 0 && gpuOutput.text.trim().length > 0
                ? gpuOutput.text.trim() : "GPU —";
        }
    }
}
