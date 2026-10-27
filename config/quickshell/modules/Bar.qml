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

    color: "transparent"
    implicitHeight: Settings.barPanelHeight
    exclusiveZone: Settings.barPanelHeight + Settings.barMargin
    aboveWindows: true
    focusable: true

    anchors {
        top: Settings.barEdge !== "bottom"
        bottom: Settings.barEdge === "bottom"
        left: true
        right: true
    }
    margins {
        top: Settings.barEdge === "top" ? Settings.barMargin : 0
        bottom: Settings.barEdge === "bottom" ? Settings.barMargin : 0
        left: Settings.barSideInset
        right: Settings.barSideInset
    }

    WlrLayershell.namespace: "desu-bar"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: Settings.barInset
        anchors.bottomMargin: Settings.barInset
        color: Settings.barStyle === "compact" ? Theme.surface : Theme.background
        radius: Settings.barRadius
        border.width: Settings.barRadius > 0 ? Theme.borderWidth : 0
        border.color: Theme.border

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
                visible: Settings.barStyle === "classic"
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                color: Theme.border
            }

            ActiveWindow {
                visible: Settings.barStyle !== "minimal"
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Text {
                visible: Settings.barStyle !== "minimal" && Desktop.message.length > 0
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

                MprisButton {}

                AudioButton {}

                BarButton {
                    label: "⚙"
                    active: Settings.barSettingsOpen
                    tooltip: "BAR SETTINGS"
                    onClicked: Settings.toggleBarSettings()
                }

                BarButton {
                    label: Notifications.count > 0 ? "NOTE " + Notifications.count : "NOTE"
                    active: Notifications.open
                    dimmed: Notifications.count === 0
                    onClicked: Notifications.toggle()
                }

                BarButton {
                    label: "⏻"
                    active: Power.open
                    tooltip: "POWER MENU"
                    onClicked: Power.toggle()
                }

                BarButton {
                    label: SystemMonitor.compactLabel
                    active: SystemMonitor.open
                    tooltip: "SYSTEM MONITOR"
                    onClicked: SystemMonitor.open = !SystemMonitor.open
                }

                BarButton {
                    label: "THEME"
                    active: Theme.pickerOpen
                    tooltip: "THEME PICKER"
                    onClicked: Theme.togglePicker()
                }

                Clock {}
            }
        }
    }
}
}
