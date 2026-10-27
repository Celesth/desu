import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

PanelWindow {
    id: root

    readonly property var actions: [
        { label: "LOCK", glyph: "▣", action: "lock" },
        { label: "SUSPEND", glyph: "◒", action: "suspend" },
        { label: "RESTART", glyph: "↻", action: "reboot" },
        { label: "SHUT DOWN", glyph: "⏻", action: "shutdown" }
    ]

    visible: Power.open
    screen: Desktop.focusedScreen
    color: "#A0000000"
    exclusiveZone: 0
    exclusionMode: ExclusionMode.Ignore
    aboveWindows: true
    focusable: true

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.namespace: "desu-power"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Power.open
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: {
        if (visible) menu.forceActiveFocus();
    }

    Item {
        id: menu
        anchors.fill: parent
        focus: Power.open

        Keys.onEscapePressed: Power.hide()

        Rectangle {
            id: card
            anchors.centerIn: parent
            width: Math.min(560, parent.width - 32)
            height: Math.min(600, parent.height - 32)
            color: Theme.surface
            radius: 32
            border.width: Theme.borderWidth
            border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            text: "Power menu"
                            color: Theme.text
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.fontSize + 9
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: "SESSION CONTROLS"
                            color: Theme.textMuted
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.fontSize - 1
                            font.letterSpacing: 1
                        }
                    }

                    Rectangle {
                        implicitWidth: 42
                        implicitHeight: 42
                        radius: width / 2
                        color: closeHover.hovered ? Theme.selection : Theme.background
                        border.width: Theme.borderWidth
                        border.color: Theme.border

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: Theme.text
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.fontSize + 10
                        }

                        HoverHandler {
                            id: closeHover
                            cursorShape: Qt.PointingHandCursor
                        }

                        TapHandler {
                            onTapped: Power.hide()
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
                    Layout.fillHeight: true
                    columns: 2
                    rowSpacing: 12
                    columnSpacing: 12

                    Repeater {
                        model: root.actions

                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 120
                            color: tileHover.hovered ? Theme.selection : Theme.background
                            radius: 26
                            border.width: Theme.borderWidth
                            border.color: tileHover.hovered ? Theme.textMuted : Theme.border

                            Column {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.glyph
                                    color: Theme.text
                                    font.family: Settings.fontFamily
                                    font.pixelSize: Settings.fontSize + 18
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.label
                                    color: Theme.textSecondary
                                    font.family: Settings.fontFamily
                                    font.pixelSize: Settings.fontSize
                                    font.weight: Font.DemiBold
                                }
                            }

                            HoverHandler {
                                id: tileHover
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                onTapped: Power.request(modelData.action)
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: "CTRL + SUPER + BACKSPACE"
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize - 1
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Rectangle {
                anchors.fill: parent
                visible: Power.pendingAction.length > 0
                color: Theme.surface
                radius: parent.radius
                border.width: Theme.borderWidth
                border.color: Theme.border

                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - 64
                    spacing: 18

                    Text {
                        Layout.fillWidth: true
                        text: "Confirm " + Power.pendingAction + "?"
                        color: Theme.text
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.fontSize + 8
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "This will affect the current session."
                        color: Theme.textSecondary
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.fontSize
                        horizontalAlignment: Text.AlignHCenter
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10

                        Rectangle {
                            implicitWidth: 112
                            implicitHeight: 42
                            radius: 21
                            color: cancelHover.hovered ? Theme.selection : Theme.background
                            border.width: Theme.borderWidth
                            border.color: Theme.border

                            Text {
                                anchors.centerIn: parent
                                text: "CANCEL"
                                color: Theme.textSecondary
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.fontSize
                            }

                            HoverHandler {
                                id: cancelHover
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                onTapped: Power.pendingAction = ""
                            }
                        }

                        Rectangle {
                            implicitWidth: 112
                            implicitHeight: 42
                            radius: 21
                            color: confirmHover.hovered ? Theme.text : Theme.elevated
                            border.width: Theme.borderWidth
                            border.color: Theme.textMuted

                            Text {
                                anchors.centerIn: parent
                                text: "CONFIRM"
                                color: confirmHover.hovered ? Theme.background : Theme.text
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.fontSize
                                font.weight: Font.DemiBold
                            }

                            HoverHandler {
                                id: confirmHover
                                cursorShape: Qt.PointingHandCursor
                            }

                            TapHandler {
                                onTapped: Power.confirm()
                            }
                        }
                    }
                }
            }
        }
    }
}
