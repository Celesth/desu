import QtQuick
import Quickshell.Hyprland
import "../services"

// Event-driven workspace list. Hyprland's IPC singleton updates these bindings.
Row {
    id: root

    property string screenName: ""

    readonly property var list: {
        const all = Hyprland.workspaces.values || [];
        return all
            .filter(w => w.id > 0 && (!root.screenName || !w.monitor || w.monitor.name === root.screenName))
            .sort((a, b) => a.id - b.id);
    }

    spacing: 0

    function focusWorkspace(id) {
        Hyprland.dispatch("workspace " + id);
    }

    Repeater {
        model: root.list

        delegate: Rectangle {
            id: item
            required property var modelData
            width: 22
            height: Settings.barHeight
            color: modelData.focused ? Theme.elevated
                 : (mouse.containsMouse ? Theme.surface : "transparent")
            border.width: modelData.focused ? Theme.borderWidth : 0
            border.color: Theme.border
            radius: 0

            Text {
                anchors.centerIn: parent
                text: item.modelData.id
                color: item.modelData.focused ? Theme.text
                     : (item.modelData.urgent ? Theme.text : Theme.textMuted)
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.focusWorkspace(item.modelData.id)
            }
        }
    }
}
