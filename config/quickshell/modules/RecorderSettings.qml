import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

PanelWindow {
    id: root

    visible: Recorder.settingsOpen
    screen: Desktop.focusedScreen
    implicitWidth: 300
    implicitHeight: 210
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

    WlrLayershell.namespace: "desu-recorder-settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Recorder.settingsOpen
        ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    Shortcut {
        sequence: "Escape"
        enabled: Recorder.settingsOpen
        onActivated: Recorder.closeSettings()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        border.width: Theme.borderWidth
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "RECORDING"
                    color: Theme.text
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize + 1
                    font.weight: Font.DemiBold
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "RIGHT CLICK REC"
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize - 2
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.border
            }

            Text {
                text: "BACKEND"
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
                        { value: "wf-recorder", label: "WF" },
                        { value: "gpu-screen-recorder", label: "GPU" },
                        { value: "auto", label: "AUTO" }
                    ]

                    delegate: OptionButton {
                        required property var modelData
                        Layout.fillWidth: true
                        label: modelData.label
                        active: Recorder.configuredBackend === modelData.value
                        onClicked: Recorder.saveSettings(
                            modelData.value,
                            Recorder.configuredFps,
                            Recorder.configuredAudio
                        )
                    }
                }
            }

            Text {
                text: "FRAME RATE"
                color: Theme.textMuted
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize - 1
                font.weight: Font.DemiBold
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                OptionButton {
                    Layout.fillWidth: true
                    label: "30 FPS"
                    active: Recorder.configuredFps === 30
                    onClicked: Recorder.saveSettings(
                        Recorder.configuredBackend, 30, Recorder.configuredAudio
                    )
                }

                OptionButton {
                    Layout.fillWidth: true
                    label: "60 FPS"
                    active: Recorder.configuredFps === 60
                    onClicked: Recorder.saveSettings(
                        Recorder.configuredBackend, 60, Recorder.configuredAudio
                    )
                }

                OptionButton {
                    Layout.fillWidth: true
                    label: Recorder.configuredAudio ? "AUDIO ON" : "AUDIO OFF"
                    active: Recorder.configuredAudio
                    onClicked: Recorder.saveSettings(
                        Recorder.configuredBackend,
                        Recorder.configuredFps,
                        !Recorder.configuredAudio
                    )
                }
            }

            Text {
                Layout.fillWidth: true
                text: "WF-RECORDER captures the focused output."
                color: Theme.textMuted
                font.family: Settings.fontFamily
                font.pixelSize: Settings.fontSize - 1
                elide: Text.ElideRight
            }
        }
    }

    component OptionButton: Rectangle {
        property string label: ""
        property bool active: false
        signal clicked()

        implicitHeight: 30
        color: active ? Theme.elevated : (pointer.containsMouse ? Theme.background : Theme.surface)
        border.width: active ? Theme.borderWidth : 0
        border.color: Theme.border

        Text {
            anchors.centerIn: parent
            text: parent.label
            color: Theme.text
            font.family: Settings.fontFamily
            font.pixelSize: Settings.fontSize - 1
            font.weight: Font.Medium
        }

        MouseArea {
            id: pointer
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
