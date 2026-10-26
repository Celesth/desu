import QtQuick
import Quickshell.Services.Mpris
import "../services"

Rectangle {
    id: root

    function currentPlayer() {
        const players = Mpris.players.values || [];
        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying) return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    readonly property var player: root.currentPlayer()
    readonly property string title: player
        ? ((player.trackArtist ? player.trackArtist + " - " : "")
            + (player.trackTitle || player.identity || "MPRIS"))
        : ""

    visible: Settings.barStyle !== "minimal" && player !== null
    implicitWidth: visible ? Math.min(300, titleText.implicitWidth + 102) : 0
    implicitHeight: Settings.barHeight
    color: mouse.containsMouse ? Theme.surface : "transparent"

    Text {
        id: previousText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        text: "<"
        horizontalAlignment: Text.AlignHCenter
        color: Theme.textSecondary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.player && root.player.canGoPrevious) root.player.previous()
        }
    }

    Text {
        id: playText
        anchors.left: previousText.right
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        text: root.player && root.player.isPlaying ? "||" : ">"
        horizontalAlignment: Text.AlignHCenter
        color: Theme.text
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.player && root.player.canTogglePlaying) root.player.togglePlaying()
        }
    }

    Text {
        id: titleText
        anchors.left: playText.right
        anchors.right: nextText.left
        anchors.verticalCenter: parent.verticalCenter
        text: root.title
        color: Theme.textSecondary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize
        elide: Text.ElideRight

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.player && root.player.canTogglePlaying) root.player.togglePlaying()
            onWheel: (event) => {
                if (!root.player) return;
                if (event.angleDelta.y > 0 && root.player.canGoPrevious) root.player.previous();
                if (event.angleDelta.y < 0 && root.player.canGoNext) root.player.next();
                event.accepted = true;
            }
        }
    }

    Text {
        id: nextText
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 24
        text: ">"
        horizontalAlignment: Text.AlignHCenter
        color: Theme.textSecondary
        font.family: Settings.fontFamily
        font.pixelSize: Settings.fontSize

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.player && root.player.canGoNext) root.player.next()
        }
    }
}
