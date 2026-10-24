pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool open: false
    readonly property var list: server.trackedNotifications.values
    readonly property int count: list.length

    NotificationServer {
        id: server
        keepOnReload: true
        onNotification: notification => {
            notification.tracked = true;
        }
    }

    function toggle() {
        root.open = !root.open;
    }

    function openPanel() {
        root.open = true;
    }

    function closePanel() {
        root.open = false;
    }

    function dismiss(notification) {
        if (notification) notification.dismiss();
    }

    function clear() {
        const notifications = root.list.slice();
        for (let i = 0; i < notifications.length; i++) notifications[i].dismiss();
    }
}
