import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

// Small, focused settings drawer for the bar itself. Choices are applied
// immediately and persisted by the Settings singleton.
PanelWindow {
    id: root

    visible: Settings.barSettingsOpen
    screen: Desktop.focusedScreen
    implicitWidth: 350
    implicitHeight: 250
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true

    anchors {
        top: Settings.barEdge === "top"
        bottom: Settings.barEdge === "bottom"
        right: true
    }
    margins {
        top: Settings.barEdge === "top" ? Settings.barMargin + Settings.barPanelHeight + 8 : 0
        bottom: Settings.barEdge === "bottom" ? Settings.barMargin + Settings.barPanelHeight + 8 : 0
        right: 8
    }

    WlrLayershell.namespace: "desu-bar-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Settings.barSettingsOpen
        ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Shortcut {
        sequence: "Escape"
        enabled: Settings.barSettingsOpen
        onActivated: Settings.closeBarSettings()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        border.width: Theme.borderWidth
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "BAR SETTINGS"
                    color: Theme.text
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize + 1
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true }

                BarOptionButton {
                    label: "CLOSE"
                    active: false
                    onClicked: Settings.closeBarSettings()
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.border
            }

            Text {
                text: "DESIGN"
                color: Theme.textMuted
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize - 1
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { value: "classic", label: "CLASSIC", hint: "Full" },
                        { value: "compact", label: "COMPACT", hint: "Tight" },
                        { value: "minimal", label: "MINIMAL", hint: "Clean" },
                        { value: "squircle", label: "SQUIRCLE", hint: "Inset" },
                        { value: "detached", label: "DETACHED", hint: "Float" }
                    ]

                    delegate: BarOptionButton {
                        required property var modelData
                        Layout.fillWidth: true
                        label: modelData.label
                        hint: modelData.hint
                        active: Settings.barStyle === modelData.value
                        onClicked: Settings.setBarSettings(Settings.barEdge, modelData.value)
                    }
                }
            }

            Text {
                text: "LOCATION"
                color: Theme.textMuted
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize - 1
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Repeater {
                    model: [
                        { value: "top", label: "TOP" },
                        { value: "bottom", label: "BOTTOM" }
                    ]

                    delegate: BarOptionButton {
                        required property var modelData
                        Layout.fillWidth: true
                        label: modelData.label
                        active: Settings.barEdge === modelData.value
                        onClicked: Settings.setBarSettings(modelData.value, Settings.barStyle)
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: Settings.barSettingsError.length > 0
                    ? Settings.barSettingsError
                    : "Changes apply immediately and are saved."
                color: Settings.barSettingsError.length > 0 ? Theme.text : Theme.textMuted
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize - 1
                elide: Text.ElideRight
            }
        }
    }

    component BarOptionButton: Rectangle {
        property string label: ""
        property string hint: ""
        property bool active: false
        signal clicked()

        implicitWidth: 72
        implicitHeight: 34
        color: active ? Theme.elevated : (mouse.containsMouse ? Theme.background : Theme.surface)
        border.width: active ? Theme.borderWidth : 0
        border.color: Theme.border

        Column {
            anchors.centerIn: parent
            spacing: 1

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.parent.label
                color: Theme.text
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize - 1
                font.weight: Font.Medium
            }

            Text {
                visible: parent.parent.hint.length > 0
                anchors.horizontalCenter: parent.horizontalCenter
                text: parent.parent.hint
                color: Theme.textMuted
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize - 2
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
