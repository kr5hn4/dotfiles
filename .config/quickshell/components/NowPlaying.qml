import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Row {
    id: root

    required property var theme

    property string status: ""
    property string trackInfo: ""
    property int trackLength: 0
    property real trackPosition: 0
    property bool isActive: status === "Playing" || status === "Paused"

    function formatTime(seconds) {
        const s = Math.floor(seconds)
        const mins = Math.floor(s / 60)
        const secs = s % 60
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }

    spacing: 0
    visible: isActive

    Process {
        id: metadataWatcher
        command: ["playerctl", "--player=%any", "metadata", "--follow", "--format", "{{ artist }} - {{ title }}|{{ mpris:length }}"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data) return;
                const parts = data.trim().split("|")
                root.trackInfo = parts[0]
                root.trackLength = parts[1] ? Math.floor(parseInt(parts[1]) / 1000000) : 0
            }
        }
    }

    Process {
        id: statusWatcher
        command: ["playerctl", "--player=%any", "status", "--follow"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data) return;
                root.status = data.trim()
            }
        }
    }

    Process {
    id: positionProc
    command: ["playerctl", "position"]
    running: false

    onRunningChanged: {
        if (!running) positionProc.running = false
    }

    stdout: SplitParser {
        onRead: (data) => {
            if (!data) return;
            const val = parseFloat(data.trim())
            if (!isNaN(val)) root.trackPosition = val
        }
    }
}


    Timer {
        interval: 1000
        running: root.status === "Playing"
        repeat: true
        onTriggered: positionProc.running = true
    }

    Rectangle {
        width: 400
        // width: nowPlayingRow.width + 24
        height: 24
        radius: root.theme.radius
        color: root.theme.bgAlt
        anchors.verticalCenter: parent.verticalCenter

        Row {
            id: nowPlayingRow
            anchors.centerIn: parent
            spacing: 12

            Text {
                id: statusIcon
                text: root.status === "Playing" ? "▶" : "⏸"
                color: root.status === "Playing" ? root.theme.green : root.theme.yellow
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.trackInfo
                color: root.theme.fg
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                anchors.verticalCenter: parent.verticalCenter
                width: 225
                maximumLineCount: 1
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }

            Text {
                text: root.formatTime(root.trackPosition) + " / " + root.formatTime(root.trackLength)
                color: root.theme.aqua
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
