import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../components"
import "../services"

// One layer-shell panel per screen. Sharp rectangle, no blur, no animation.
PanelWindow {
    id: bar

    readonly property string screenName: bar.screen ? bar.screen.name : ""

    color: Theme.background
    implicitHeight: Settings.barHeight + (Notifications.open ? 300 : 0)
    exclusiveZone: implicitHeight + Settings.barMargin
    aboveWindows: true
    focusable: false

    anchors {
        top: Settings.barEdge !== "bottom"
        bottom: Settings.barEdge === "bottom"
        left: true
        right: true
    }
    margins {
        top: Settings.barEdge === "top" ? Settings.barMargin : 0
        bottom: Settings.barEdge === "bottom" ? Settings.barMargin : 0
        left: 0
        right: 0
    }

    WlrLayershell.namespace: "desu-bar"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Column {
        anchors.fill: parent
        spacing: 0

        RowLayout {
            width: parent.width
            height: Settings.barHeight
            spacing: 0

            Workspaces {
                screenName: bar.screenName
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                color: Theme.border
            }

            ActiveWindow {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Text {
                visible: Desktop.message.length > 0
                text: Desktop.message
                color: Desktop.messageIsError ? Theme.text : Theme.textMuted
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize
                elide: Text.ElideRight
                Layout.maximumWidth: 280
                Layout.rightMargin: 8
            }

            Row {
                Layout.alignment: Qt.AlignVCenter

                Tray {}

                AudioButton {}

                BarButton {
                    label: Notifications.count > 0 ? "NOTE " + Notifications.count : "NOTE"
                    active: Notifications.open
                    dimmed: Notifications.count === 0
                    onClicked: Notifications.toggle()
                }

                Clock {}
            }
        }

        NotificationPanel {
            width: parent.width
            height: Notifications.open ? 300 : 0
        }
    }
}
