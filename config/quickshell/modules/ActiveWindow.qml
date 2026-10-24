import QtQuick
import Quickshell.Hyprland
import "../services"

// Active toplevel title, updated by Hyprland events.
Item {
    id: root

    implicitWidth: 120
    implicitHeight: Settings.barHeight

    // Quickshell's activeToplevel is populated by the activewindow event. If
    // the shell started while a window was already focused, fall back to the
    // toplevel model's activated flag until the first focus event arrives.
    readonly property var toplevel: Hyprland.activeToplevel
        ? Hyprland.activeToplevel
        : (Hyprland.toplevels.values.find(t => t.activated) || null)

    Text {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        verticalAlignment: Text.AlignVCenter
        text: root.toplevel ? (root.toplevel.title || "") : ""
        color: Theme.textSecondary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize
        elide: Text.ElideRight
    }
}
