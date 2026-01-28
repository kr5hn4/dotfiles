import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root

    required property var theme
    required property var volumeModule

    // PanelWindow properties
    height: 32
    color: "transparent"
    mask: null

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0)

        // Logo (Centered)
        Logo {
            theme: root.theme
            anchors.centerIn: parent
            z: 10
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            Item {
                width: 28
            }

            // Workspaces/Tags (1–9)
            Workspaces {
                id: workspaces

                theme: root.theme
            }

            Item {
                width: 24
            }

            // Layout Mode Indicator
            Rectangle {
                Layout.preferredWidth: layoutModeText.width + 20
                Layout.preferredHeight: 24
                color: root.theme.bgAlt
                radius: root.theme.radius

                Text {
                    id: layoutModeText

                    anchors.centerIn: parent
                    text: (workspaces.layoutIcons[workspaces.layoutMode] || "󰕰") + " " + workspaces.layoutMode.toUpperCase()
                    color: root.theme.orange
                    font.family: root.theme.fontFamily
                    font.pixelSize: root.theme.fontSize - 2
                    font.bold: true
                }

            }

            Item {
                width: 12
            }

            Item {
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
            }

            // System stats (Right)
            Row {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                Wifi {
                    theme: root.theme
                }

                Volume {
                    id: volumeComponent

                    theme: root.theme
                    volume: root.volumeModule
                }

                SystemStats {
                    theme: root.theme
                }

                SystemTray {
                    parentWindow: barWindow
                }

            }

            Item {
                width: 28
            }

        }

    }

}
