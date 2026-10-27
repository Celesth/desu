import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

PanelWindow {
    id: root

    visible: Theme.pickerOpen
    screen: Desktop.focusedScreen
    implicitWidth: 360
    implicitHeight: 286
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: false

    anchors {
        top: Settings.barEdge !== "bottom"
        bottom: Settings.barEdge === "bottom"
        right: true
    }
    margins {
        top: Settings.barEdge === "top" ? Settings.barMargin + Settings.barPanelHeight : 0
        bottom: Settings.barEdge === "bottom" ? Settings.barMargin + Settings.barPanelHeight : 0
        right: 8
    }

    WlrLayershell.namespace: "desu-theme-picker"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        radius: 24
        border.width: Theme.borderWidth
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: "Theme picker"
                        color: Theme.text
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.fontSize + 4
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: Theme.name + " // PALETTE"
                        color: Theme.textMuted
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.fontSize - 1
                        font.letterSpacing: 1
                    }
                }

                Text {
                    text: "LIVE"
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize - 1
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.border
            }

            Repeater {
                model: Theme.palettes

                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: modelData.name === Theme.name ? Theme.selection : Theme.background
                    radius: 18
                    border.width: Theme.borderWidth
                    border.color: modelData.name === Theme.name ? Theme.textMuted : Theme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 14
                        spacing: 10

                        Repeater {
                            model: [modelData.background, modelData.selection, modelData.text]

                            delegate: Rectangle {
                                required property var modelData
                                implicitWidth: 14
                                implicitHeight: 14
                                radius: width / 2
                                color: modelData
                                border.width: 1
                                border.color: Theme.border
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: Theme.text
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.fontSize
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: modelData.name === Theme.name ? "ACTIVE" : "APPLY"
                            color: Theme.textMuted
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.fontSize - 1
                        }
                    }

                    HoverHandler {
                        id: hover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: {
                            Theme.apply(modelData.name, true);
                            Theme.pickerOpen = false;
                        }
                    }
                }
            }
        }
    }
}
