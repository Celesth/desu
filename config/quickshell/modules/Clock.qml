import QtQuick
import Quickshell
import "../services"

// Minute-precision native clock. Hovering swaps the time for the date; there
// is no per-second timer and no polling.
Item {
    id: root

    readonly property bool hovered: mouse.containsMouse
    implicitHeight: Settings.barHeight
    implicitWidth: Math.max(timeText.implicitWidth, dateText.implicitWidth) + 16

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: timeText
        anchors.centerIn: parent
        visible: !root.hovered
        text: Qt.formatDateTime(clock.date, Settings.timeFormat)
        color: Theme.textSecondary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize
    }

    Text {
        id: dateText
        anchors.centerIn: parent
        visible: root.hovered
        text: Qt.formatDateTime(clock.date, Settings.dateFormat)
        color: Theme.text
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
