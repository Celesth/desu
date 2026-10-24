import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "../services"

// Standard StatusNotifierItem host. Clicking activates an item, right-clicking
// opens its DBus menu when one is provided.
Row {
    id: root

    property var barWindow
    property bool atBottom: Settings.barEdge === "bottom"
    spacing: 0
    visible: SystemTray.items.values.length > 0

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem
            required property SystemTrayItem modelData
            width: Settings.barHeight
            height: Settings.barHeight

            IconImage {
                id: icon
                anchors.centerIn: parent
                implicitSize: Math.max(14, Settings.barHeight - 12)
                source: trayItem.modelData.icon
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: (event) => {
                    if (event.button === Qt.LeftButton) {
                        trayItem.modelData.activate();
                    } else if (trayItem.modelData.hasMenu) {
                        menu.open();
                    }
                    event.accepted = true;
                }
            }

            QsMenuAnchor {
                id: menu
                menu: trayItem.modelData.menu
                anchor {
                    item: mouse
                    adjustment: PopupAdjustment.ResizeY | PopupAdjustment.SlideX
                    gravity: root.atBottom ? Edges.Top : Edges.Bottom
                    edges: root.atBottom ? Edges.Top : Edges.Bottom
                }
            }
        }
    }
}
