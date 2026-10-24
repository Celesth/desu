import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../services"

PanelWindow {
    id: root

    visible: Notifications.open
    implicitWidth: 420
    implicitHeight: 300
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
        top: Settings.barEdge === "top" ? Settings.barMargin + Settings.barHeight : 0
        bottom: Settings.barEdge === "bottom" ? Settings.barMargin + Settings.barHeight : 0
        right: 8
    }

    WlrLayershell.namespace: "desu-notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        color: Theme.surface
        border.width: Theme.borderWidth
        border.color: Theme.border

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "NOTIFICATIONS"
                    color: Theme.text
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize + 1
                    font.weight: Font.DemiBold
                }

                Text {
                    Layout.fillWidth: true
                    text: Notifications.count + " unread"
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize
                }

                Rectangle {
                    implicitWidth: clearLabel.implicitWidth + 16
                    implicitHeight: 24
                    color: Theme.elevated
                    border.width: Theme.borderWidth
                    border.color: Theme.border

                    Text {
                        id: clearLabel
                        anchors.centerIn: parent
                        text: "CLEAR"
                        color: Theme.text
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.fontSize - 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.clear()
                    }
                }

                Rectangle {
                    implicitWidth: closeLabel.implicitWidth + 16
                    implicitHeight: 24
                    color: Theme.elevated
                    border.width: Theme.borderWidth
                    border.color: Theme.border

                    Text {
                        id: closeLabel
                        anchors.centerIn: parent
                        text: "CLOSE"
                        color: Theme.text
                        font.family: Settings.fontFamily
                        font.pixelSize: Settings.fontSize - 1
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifications.closePanel()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.border
            }

            ListView {
                id: notificationList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: Notifications.list

                delegate: Rectangle {
                    id: card
                    required property var modelData
                    width: notificationList.width
                    height: Math.max(68, bodyText.implicitHeight + 32)
                    color: Theme.background
                    border.width: Theme.borderWidth
                    border.color: Theme.border

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        IconImage {
                            visible: card.modelData.image.length > 0 || card.modelData.appIcon.length > 0
                            source: card.modelData.image.length > 0
                                ? card.modelData.image : card.modelData.appIcon
                            implicitSize: 28
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.appName + "  " + card.modelData.summary
                                color: Theme.text
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.fontSize
                                font.weight: Font.DemiBold
                                elide: Text.ElideRight
                            }

                            Text {
                                id: bodyText
                                Layout.fillWidth: true
                                text: card.modelData.body
                                color: Theme.textSecondary
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.fontSize - 1
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 24
                            color: Theme.elevated
                            border.width: Theme.borderWidth
                            border.color: Theme.border

                            Text {
                                anchors.centerIn: parent
                                text: "×"
                                color: Theme.text
                                font.family: Settings.fontFamily
                                font.pixelSize: Settings.fontSize + 2
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Notifications.dismiss(card.modelData)
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: Notifications.count === 0
                    text: "NO NOTIFICATIONS"
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize
                }
            }
        }
    }
}
