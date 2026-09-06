import "../components/" as Components
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland

PanelWindow {
    id: notifWindow

    property var notification
    required property var screen

    function closeNotification() {
        slideTransform.y = -150;
        notifRect.opacity = 0;
        notifRect.scale = 0.95;
        destroyTimer.start();
    }

    WlrLayershell.layer: WlrLayer.Overlay
    width: 380
    height: notifRect.height
    visible: true
    color: "transparent"
    Component.onCompleted: {
        slideTransform.y = 0;
        notifRect.opacity = 1;
        notifRect.scale = 1;
        progressTimer.start();
    }

    Components.Theme {
        id: theme
    }

    anchors {
        top: true
        right: true
    }

    margins {
        top: screen.height * 0.25
        right: (screen.width - 380) / 2
    }

    Rectangle {
        id: notifRect

        width: parent.width
        height: contentColumn.height + 40
        color: Qt.rgba(theme.bg.r, theme.bg.g, theme.bg.b, 0.95)
        radius: 20
        border.color: Qt.rgba(1, 1, 1, 0.1)
        border.width: 1
        opacity: 0
        scale: 0.95

        // Progress bar container at the top
        Rectangle {
            id: progressContainer

            height: 0.75
            radius: 16
            color: theme.muted

            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 1
                leftMargin: 18
                rightMargin: 18
            }

            // Animated progress bar
            Rectangle {
                id: progressBar

                width: parent.width
                radius: 16
                color: {
                    switch (notification.urgency) {
                    case NotificationUrgency.Critical:
                        return theme.red;
                    case NotificationUrgency.Normal:
                        return theme.aqua;
                    case NotificationUrgency.Low:
                        return theme.muted;
                    default:
                        return theme.green;
                    }
                }
                opacity: 0.8

                anchors {
                    top: parent.top
                    left: parent.left
                    bottom: parent.bottom
                }

                Behavior on width {
                    NumberAnimation {
                        duration: 50
                        easing.type: Easing.Linear
                    }

                }

            }

        }

        // Subtle urgency indicator
        Rectangle {
            width: 3
            radius: 1.5
            color: {
                switch (notification.urgency) {
                case NotificationUrgency.Critical:
                    return theme.red;
                case NotificationUrgency.Normal:
                    return theme.aqua;
                default:
                    return theme.muted;
                }
            }
            opacity: 0.6

            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: 16
                topMargin: 16
                bottomMargin: 16
            }

        }

        Row {
            spacing: 16

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: 24
                leftMargin: 40
            }

            // App icon
            Image {
                id: appIcon

                width: 48
                height: 48
                source: notification.image || notification.icon || ""
                visible: source != ""
                fillMode: Image.PreserveAspectFit
                smooth: true

                // Fallback to app name initial if no icon
                Rectangle {
                    anchors.fill: parent
                    visible: !parent.visible && notification.appName
                    color: theme.aqua
                    radius: 12
                    opacity: 0.2

                    Text {
                        anchors.centerIn: parent
                        text: notification.appName ? notification.appName.charAt(0).toUpperCase() : "N"
                        color: theme.fg
                        font.family: theme.fontFamily
                        font.pixelSize: 20
                        font.bold: true
                    }

                }

            }

            Column {
                id: contentColumn

                spacing: 6
                width: parent.width - (appIcon.visible ? appIcon.width + 16 : 0)

                // App name - ultra subtle
                Text {
                    text: notification.appName || "Notification"
                    color: theme.muted
                    font.family: theme.fontFamily
                    font.pixelSize: 11
                    opacity: 0.6
                    width: parent.width
                }

                // Summary - clear hierarchy
                Text {
                    text: notification.summary
                    color: theme.fg
                    font.family: theme.fontFamily
                    font.pixelSize: 15
                    font.bold: true
                    width: parent.width
                    wrapMode: Text.Wrap
                }

                // Body - readable
                Text {
                    visible: notification.body !== ""
                    text: notification.body
                    color: theme.muted
                    font.family: theme.fontFamily
                    font.pixelSize: 13
                    lineHeight: 1.4
                    width: parent.width
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                }

                // Notification actions (if any)
                Row {
                    visible: notification.actions && notification.actions.length > 0
                    spacing: 8
                    width: parent.width

                    Repeater {
                        model: notification.actions || []

                        Rectangle {
                            width: actionText.width + 20
                            height: 28
                            radius: 14
                            color: Qt.rgba(theme.aqua.r, theme.aqua.g, theme.aqua.b, 0.15)
                            border.color: theme.aqua
                            border.width: 1

                            Text {
                                id: actionText

                                anchors.centerIn: parent
                                text: modelData.text || modelData.id
                                color: theme.aqua
                                font.family: theme.fontFamily
                                font.pixelSize: 11
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    notification.invokeAction(modelData.id);
                                    closeNotification();
                                }
                            }

                        }

                    }

                }

            }

        }

        // Close button (top right)
        Rectangle {
            width: 24
            height: 24
            radius: 12
            color: "transparent"

            anchors {
                top: parent.top
                right: parent.right
                margins: 12
            }

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: theme.muted
                font.pixelSize: 14
                opacity: closeArea.containsMouse ? 1 : 0.5
            }

            MouseArea {
                id: closeArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: closeNotification()
            }

        }

        // Hover interaction
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            z: -1
            onEntered: {
                notifRect.color = theme.bgAlt;
                closeTimer.stop();
                progressTimer.stop();
            }
            onExited: {
                notifRect.color = theme.bg;
                closeTimer.restart();
                progressTimer.restart();
            }
        }

        // Behaviors for smooth animation
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }

        }

        // Transform for slide animation
        transform: Translate {
            id: slideTransform

            y: -150

            Behavior on y {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

    // Progress timer - updates every 50ms
    Timer {
        id: progressTimer

        property real elapsed: 0
        property real totalDuration: 4000 // Match closeTimer duration

        interval: 50
        repeat: true
        running: false
        onTriggered: {
            elapsed += interval;
            var progress = 1 - (elapsed / totalDuration);
            progressBar.width = progressContainer.width * Math.max(0, progress);
            if (progress <= 0)
                stop();

        }
    }

    Timer {
        id: closeTimer
        interval: 4000
        running: true
        onTriggered: closeNotification()
    }

    Timer {
        id: destroyTimer
        interval: 200
        onTriggered: notifWindow.destroy()
    }

}
