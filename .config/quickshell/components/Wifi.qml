import QtQuick
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    required property var theme
    property string wifiInfo: "󰖪 offline"

    width: wifiText.width + 16
    height: 24
    radius: theme.radius
    color: theme.bgAlt
    anchors.verticalCenter: parent.verticalCenter

    Text {
        id: wifiText

        anchors.centerIn: parent
        text: root.wifiInfo
        color: theme.yellow
        font.family: theme.fontFamily
        font.pixelSize: theme.fontSize - 2
        font.bold: true
    }

    // =========================
    // WiFi Watcher Logic
    // =========================
    Timer {
        id: wifiDebounce

        interval: 500
        repeat: false
        onTriggered: wifiCheck.running = true
    }

    Process {
        id: wifiMonitor

        command: ["nmcli", "monitor"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                wifiDebounce.restart();
            }
        }

    }

    Process {
        id: wifiCheck

        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | awk -F: '/^yes/ { ssid = $2; s = $3; i = (s > 80 ? \"󰤨  \" : s > 60 ? \"󰤥  \" : s > 40 ? \"󰤢  \" : s > 20 ? \"󰤟  \" : \"󰤯  \"); printf \"%s%s\", i, ssid; found = 1; } END { if (!found) print \"󰖪  Disconnected\"; }'"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                root.wifiInfo = data.trim();
            }
        }

    }

    // Initial WiFi check
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: wifiCheck.running = true
    }

}
