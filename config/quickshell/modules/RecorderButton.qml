import QtQuick
import "../services"

Rectangle {
    id: root

    readonly property string label: Recorder.active ? "● " + Recorder.elapsedText : "REC"

    implicitWidth: labelText.implicitWidth + 12
    implicitHeight: Settings.barHeight
    color: Recorder.active || Recorder.settingsOpen
        ? Theme.elevated : (pointer.containsMouse ? Theme.surface : "transparent")
    border.width: Recorder.active || Recorder.settingsOpen ? Theme.borderWidth : 0
    border.color: Recorder.active ? Theme.accent : Theme.border

    Text {
        id: labelText
        anchors.centerIn: parent
        text: root.label
        color: Recorder.active ? Theme.accent : Theme.text
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize
        font.weight: Font.Medium
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: function(event) {
            if (event.button === Qt.RightButton) Recorder.toggleSettings();
            else Recorder.toggle();
        }
    }
}
