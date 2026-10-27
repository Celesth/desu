pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Single source of truth for the monochrome palette. Components never
// hard-code colors.
Singleton {
    property color background: "#202020"
    property color surface: "#292929"
    property color elevated: "#333333"
    property color border: "#555555"
    property color text: "#E6E6E6"
    property color textSecondary: "#B8B8B8"
    property color textMuted: "#858585"
    property color selection: "#3A3A3A"

    property string name: "MONO"
    property bool pickerOpen: false

    readonly property var palettes: [
        {
            name: "MONO",
            background: "#202020",
            surface: "#292929",
            elevated: "#333333",
            border: "#555555",
            text: "#E6E6E6",
            textSecondary: "#B8B8B8",
            textMuted: "#858585",
            selection: "#3A3A3A"
        },
        {
            name: "EMBER",
            background: "#211B1A",
            surface: "#2C2220",
            elevated: "#3A2A26",
            border: "#735047",
            text: "#F6E4DC",
            textSecondary: "#D7B8AB",
            textMuted: "#A48277",
            selection: "#5A342A"
        },
        {
            name: "ICE",
            background: "#182126",
            surface: "#202D34",
            elevated: "#2B3D46",
            border: "#587481",
            text: "#E5F2F5",
            textSecondary: "#B4D0D7",
            textMuted: "#7D9CA5",
            selection: "#345562"
        }
    ]

    readonly property int borderWidth: 1
    readonly property int gap: 2

    function findPalette(value) {
        const wanted = (value || "").trim().toUpperCase();
        for (let i = 0; i < palettes.length; i++) {
            if (palettes[i].name === wanted) return palettes[i];
        }
        return palettes[0];
    }

    function apply(value, persist) {
        const palette = findPalette(value);
        name = palette.name;
        background = palette.background;
        surface = palette.surface;
        elevated = palette.elevated;
        border = palette.border;
        text = palette.text;
        textSecondary = palette.textSecondary;
        textMuted = palette.textMuted;
        selection = palette.selection;
        if (persist) {
            saveProcess.command = [
                Settings.scriptsDir + "/desu-theme",
                Settings.stateDir + "/theme",
                name
            ];
            saveProcess.running = true;
        }
    }

    function togglePicker() {
        pickerOpen = !pickerOpen;
    }

    FileView {
        id: selectedTheme
        path: Settings.stateDir + "/theme"
        watchChanges: true
        printErrors: false
        onLoaded: apply(text(), false)
        onFileChanged: reload()
    }

    Process {
        id: saveProcess
        stderr: StdioCollector { id: saveError }
        onExited: (code) => {
            if (code !== 0) Desktop.notify((saveError.text || "could not save theme").trim(), true);
        }
    }
}
