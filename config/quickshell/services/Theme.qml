pragma Singleton

import QtQuick
import Quickshell

// Single source of truth for the monochrome palette. Components never
// hard-code colors.
Singleton {
    readonly property color background: "#202020"
    readonly property color surface: "#292929"
    readonly property color elevated: "#333333"
    readonly property color border: "#555555"
    readonly property color text: "#E6E6E6"
    readonly property color textSecondary: "#B8B8B8"
    readonly property color textMuted: "#858585"
    readonly property color selection: "#3A3A3A"

    readonly property int borderWidth: 1
    readonly property int gap: 2
}
