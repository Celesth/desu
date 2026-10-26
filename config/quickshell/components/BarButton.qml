import QtQuick
import "../services"

// Flat rectangular bar action. No radius, no animation, no shadows.
Rectangle {
    id: root

    property string label: ""
    property bool active: false
    property bool dimmed: false
    property string tooltip: ""

    signal clicked()

    implicitWidth: labelText.implicitWidth + Settings.barPadding
    implicitHeight: Settings.barHeight
    color: root.active ? Theme.elevated : (mouse.containsMouse ? Theme.surface : "transparent")
    border.width: root.active ? Theme.borderWidth : 0
    border.color: Theme.border
    radius: 0

    Text {
        id: labelText
        anchors.centerIn: parent
        text: root.label
        color: root.dimmed ? Theme.textMuted : Theme.text
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize
        font.weight: Font.Medium
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
