import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../services"

// Full-screen wallpaper picker on the focused monitor. Thumbnails are cached
// by the helper script and loaded asynchronously by the grid.
PanelWindow {
    id: root

    visible: Wallpapers.open
    screen: Desktop.focusedScreen
    color: "#202020CC"
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
    margins {
        top: 0
        bottom: 0
        left: 0
        right: 0
    }

    WlrLayershell.namespace: "desu-wallpaper"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: Wallpapers.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: {
        if (visible) content.forceActiveFocus();
    }

    Shortcut {
        sequence: "Escape"
        enabled: Wallpapers.open
        onActivated: Wallpapers.hide()
    }

    Item {
        id: content
        anchors.centerIn: parent
        width: Math.min(760, parent.width - 40)
        height: Math.min(480, parent.height - 40)
        focus: true

        Keys.onEscapePressed: Wallpapers.hide()

        Rectangle {
            anchors.fill: parent
            color: Theme.surface
            border.width: Theme.borderWidth
            border.color: Theme.border
        }

        Rectangle {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 34
            color: Theme.background

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Text {
                    text: "WALLPAPERS"
                    color: Theme.text
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize + 1
                    font.weight: Font.DemiBold
                }

                Text {
                    text: Wallpapers.items.length + " images"
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize
                }

                Text {
                    Layout.fillWidth: true
                    text: Settings.wallpaperDir
                    color: Theme.textMuted
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize
                    elide: Text.ElideMiddle
                }

                Text {
                    text: "ESC CLOSE"
                    color: Theme.textSecondary
                    font.family: Settings.fontFamily
                    font.pixelSize: Settings.fontSize
                }
            }
        }

        GridView {
            id: grid
            anchors.top: header.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 8
            clip: true
            cellWidth: 184
            cellHeight: 126
            cacheBuffer: 0
            boundsBehavior: Flickable.StopAtBounds
            model: Wallpapers.items

            delegate: Item {
                id: cell
                required property var modelData
                width: grid.cellWidth
                height: grid.cellHeight

                readonly property bool selected: cell.modelData.path === Wallpapers.selected

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    color: cell.selected ? Theme.elevated : Theme.surface
                    border.width: (cell.selected || hover.containsMouse) ? Theme.borderWidth : 0
                    border.color: Theme.border
                    radius: 0

                    Image {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 4
                        height: parent.height - 26
                        source: cell.modelData.thumb
                        asynchronous: true
                        cache: true
                        sourceSize.width: 176
                        sourceSize.height: 96
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 22
                        color: Theme.background

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            verticalAlignment: Text.AlignVCenter
                            text: cell.modelData.name
                            color: Theme.textSecondary
                            font.family: Settings.fontFamily
                            font.pixelSize: Settings.fontSize - 1
                            elide: Text.ElideMiddle
                        }
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Wallpapers.apply(cell.modelData.path)
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: Wallpapers.loading
            text: "LOADING THUMBNAILS..."
            color: Theme.textMuted
            font.family: Settings.fontFamily
            font.pixelSize: Settings.fontSize + 1
        }

        Text {
            anchors.centerIn: parent
            visible: !Wallpapers.loading && Wallpapers.items.length === 0
            text: Wallpapers.error.length > 0
                ? Wallpapers.error
                : "NO WALLPAPERS IN " + Settings.wallpaperDir
            color: Wallpapers.error.length > 0 ? Theme.text : Theme.textMuted
            font.family: Settings.fontFamily
            font.pixelSize: Settings.fontSize + 1
            wrapMode: Text.Wrap
            width: parent.width - 80
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 8
            visible: Wallpapers.error.length > 0
            text: Wallpapers.error
            color: Theme.text
            font.family: Settings.fontFamily
            font.pixelSize: Settings.fontSize
            elide: Text.ElideRight
        }
    }
}
