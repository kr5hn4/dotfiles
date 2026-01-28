import "." as Components
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Row {
    id: trayRow

    // Need access to the parent window
    required property var parentWindow

    spacing: 8

    Components.Theme {
        id: theme
    }

    Repeater {
        model: SystemTray.items

        Rectangle {
            id: trayIcon

            width: 24
            height: 24
            color: "transparent"
            radius: 4

            // Hover effect
            Rectangle {
                anchors.fill: parent
                color: theme.aqua
                opacity: trayMouseArea.containsMouse ? 0.2 : 0
                radius: parent.radius

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }

                }

            }

            Image {
                anchors.centerIn: parent
                width: 20
                height: 20
                source: modelData.icon || ""
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            MouseArea {
                id: trayMouseArea

                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                        // Get position relative to parent window
                        var pos = trayIcon.mapToItem(trayRow.parentWindow.contentItem, 0, trayIcon.height);
                        modelData.display(trayRow.parentWindow, pos.x, pos.y);
                    } else if (mouse.button === Qt.LeftButton) {
                        if (modelData.onlyMenu && modelData.hasMenu) {
                            var pos = trayIcon.mapToItem(trayRow.parentWindow.contentItem, 0, trayIcon.height);
                            modelData.display(trayRow.parentWindow, pos.x, pos.y);
                        } else {
                            modelData.activate();
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate();
                    }
                }
            }

        }

    }

}
