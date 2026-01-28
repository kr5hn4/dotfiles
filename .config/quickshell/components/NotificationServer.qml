import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications

NotificationServer {
    id: notificationServer

    onNotification: (notification) => {
        console.log("Notification received:", notification.summary);
        notification.tracked = false;
        // Create a popup window for this notification
        var component = Qt.createComponent("../overlays/NotificationOverlay.qml");
        var popup = component.createObject(null, {
            "notification": notification,
            "screen": Quickshell.screens[0]
        });
    }
}
