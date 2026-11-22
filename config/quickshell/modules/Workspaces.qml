import QtQuick
import Quickshell.Hyprland
import "../services"

// Event-driven workspace indicator. Hyprland's IPC singleton updates these bindings.
Item {
    id: root

    property string screenName: ""

    implicitWidth: capsule.width
    implicitHeight: Settings.barHeight

    readonly property var list: {
        const all = Hyprland.workspaces.values || [];
        const activeId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1;
        return all
            .filter(w => w.id > 0 && (!root.screenName || !w.monitor || w.monitor.name === root.screenName))
            .map(w => ({
                id: w.id,
                focused: w.id === activeId || w.focused === true,
                occupied: w.toplevels && w.toplevels.values
                    ? w.toplevels.values.length > 0 : false,
                urgent: w.urgent === true
            }))
            .sort((a, b) => a.id - b.id);
    }

    function focusWorkspace(id) {
        Hyprland.dispatch("workspace " + id);
    }

    Rectangle {
        id: capsule
        anchors.verticalCenter: parent.verticalCenter
        width: workspaceRow.width + 8
        height: Math.min(Settings.barHeight - 4, 24)
        radius: height / 2
        color: Qt.alpha(Theme.surface, 0.72)
        border.width: Theme.borderWidth
        border.color: Qt.alpha(Theme.border, 0.55)

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 3

            Repeater {
                model: root.list

                delegate: Item {
                    id: item
                    required property var modelData
                    readonly property bool active: modelData.focused
                    readonly property bool occupied: modelData.occupied
                    readonly property bool urgent: modelData.urgent

                    width: active ? 28 : (occupied ? 22 : 18)
                    height: capsule.height - 4

                    Behavior on width {
                        NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        id: background
                        anchors.fill: parent
                        radius: item.active ? 7 : 5
                        color: item.urgent ? Theme.errorColor
                            : item.active ? Theme.accent
                            : (mouse.containsMouse ? Theme.elevated : "transparent")

                        Behavior on color {
                            ColorAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: item.modelData.id
                        color: item.urgent || item.active ? Theme.accentText
                            : (item.occupied ? Theme.text : Theme.textMuted)
                        font.family: Settings.fontFamily
                        font.pixelSize: item.active ? Settings.fontSize : Math.max(8, Settings.fontSize - 1)
                        font.weight: item.active || item.occupied ? Font.DemiBold : Font.Normal

                        Behavior on color {
                            ColorAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 1
                        width: 4
                        height: 2
                        radius: 1
                        visible: item.occupied && !item.active && !item.urgent
                        color: Qt.alpha(Theme.accent, 0.8)
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
    }
}
