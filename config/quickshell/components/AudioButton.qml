import QtQuick
import "../services"

// Native volume control: left click opens pavucontrol, right click mutes,
// wheel adjusts the actual PipeWire default sink.
Rectangle {
    id: root

    implicitWidth: Math.max(64, labelText.implicitWidth + 16)
    implicitHeight: Settings.barHeight
    color: mouse.containsMouse ? Theme.surface : "transparent"
    radius: 0

    Text {
        id: labelText
        anchors.centerIn: parent
        text: AudioService.label
        color: AudioService.available ? Theme.textSecondary : Theme.textMuted
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: (event) => {
            if (event.button === Qt.LeftButton) {
                Desktop.openMixer();
            } else if (event.button === Qt.RightButton) {
                AudioService.toggleMute();
            }
            event.accepted = true;
        }
        onWheel: (event) => {
            AudioService.step(event.angleDelta.y > 0 ? 0.05 : -0.05);
            event.accepted = true;
        }
    }
}
