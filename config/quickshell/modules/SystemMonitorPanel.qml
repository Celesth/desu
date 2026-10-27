import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

PanelWindow {
    id: root

    visible: SystemMonitor.open
    screen: Desktop.focusedScreen
    implicitWidth: 360
    implicitHeight: 360
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

    WlrLayershell.namespace: "desu-system-monitor"
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
                        text: "System monitor"
                        color: Theme.text
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.fontSize + 4
                        font.weight: Font.DemiBold
                    }

                    Text {
                        text: "LIVE STATUS"
                        color: Theme.textMuted
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.fontSize - 1
                        font.letterSpacing: 1
                    }
                }

                Text {
                    text: "2s"
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.border
            }

            Repeater {
                model: [
                    { label: "CPU", value: SystemMonitor.cpuPercent + "%", amount: SystemMonitor.cpuPercent },
                    { label: "RAM", value: SystemMonitor.ramPercent + "%", amount: SystemMonitor.ramPercent },
                    { label: "DISK", value: SystemMonitor.diskText, amount: parseInt(SystemMonitor.diskText) || 0 }
                ]

                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: modelData.label
                            color: Theme.textSecondary
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.fontSize
                            font.weight: Font.DemiBold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: modelData.value
                            color: Theme.text
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.fontSize
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 6
                        radius: 3
                        color: Theme.background

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(100, modelData.amount)) / 100
                            height: parent.height
                            radius: parent.radius
                            color: Theme.textSecondary
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.border
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 8
                columnSpacing: 12

                Text { text: "GPU"; color: Theme.textMuted; font.family: Settings.fontFamily; font.pixelSize: Settings.fontSize }
                Text { text: SystemMonitor.gpuText; color: Theme.textSecondary; font.family: Settings.fontFamily; font.pixelSize: Settings.fontSize; elide: Text.ElideRight; Layout.fillWidth: true }
                Text { text: "TEMP"; color: Theme.textMuted; font.family: Settings.fontFamily; font.pixelSize: Settings.fontSize }
                Text { text: SystemMonitor.temperatureText; color: Theme.textSecondary; font.family: Settings.fontFamily; font.pixelSize: Settings.fontSize }
                Text { text: "LOAD"; color: Theme.textMuted; font.family: Settings.fontFamily; font.pixelSize: Settings.fontSize }
                Text { text: SystemMonitor.loadText; color: Theme.textSecondary; font.family: Settings.fontFamily; font.pixelSize: Settings.fontSize }
                Text { text: "UPTIME"; color: Theme.textMuted; font.family: Settings.fontFamily; font.pixelSize: Settings.fontSize }
                Text { text: SystemMonitor.uptimeText; color: Theme.textSecondary; font.family: Settings.fontFamily; font.pixelSize: Settings.fontSize }
            }
        }
    }
}
