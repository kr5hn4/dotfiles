import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Row {
    id: root

    required property var theme
    property int memUsage: 0
    property int cpuUsage: 0
    property bool isRecording: false
    property int recordingDuration: 0

    function formatDuration(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    spacing: 12
    Layout.rightMargin: 12

    Process {
        id: memProc

        command: ["sh", "-c", "free | awk '/^Mem/ {print int($3*100/$2)}'"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const val = parseInt(data.trim());
                if (!isNaN(val))
                    root.memUsage = val;

            }
        }

    }

    Process {
        id: cpuProc

        command: ["sh", "-c", "top -bn2 -d0.5 | awk '/^%Cpu/ {print int($2+$4)}' | tail -n1"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const val = parseInt(data.trim());
                if (!isNaN(val))
                    root.cpuUsage = val;

            }
        }

    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true;
            cpuProc.running = true;
        }
    }

    // Initial CPU/Mem check
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            memProc.running = true;
            cpuProc.running = true;
        }
    }

    // Recording Watcher (Self Contained)
    Process {
        id: recordingWatcher

        command: ["sh", "-c", "while true; do [ -f /tmp/.recording_lock ] && echo 'REC' || echo 'IDLE'; inotifywait -qq -e create,delete,modify /tmp/ -t 1 2>/dev/null || sleep 1; done"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const wasRecording = root.isRecording;
                root.isRecording = (data.trim() === "REC");
                if (root.isRecording && !wasRecording)
                    root.recordingDuration = 0;

            }
        }

    }

    Timer {
        interval: 1000
        running: root.isRecording
        repeat: true
        onTriggered: root.recordingDuration++
    }

    // Recording Indicator
    Rectangle {
        visible: root.isRecording
        width: recText.width + 40
        height: 24
        radius: root.theme.radius
        color: root.theme.red
        anchors.verticalCenter: parent.verticalCenter

        Row {
            anchors.centerIn: parent
            spacing: 8

            // Pulsing dot
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: "white"
                anchors.verticalCenter: parent.verticalCenter

                SequentialAnimation on opacity {
                    running: root.isRecording
                    loops: Animation.Infinite

                    NumberAnimation {
                        to: 0.3
                        duration: 600
                    }

                    NumberAnimation {
                        to: 1
                        duration: 600
                    }

                }

            }

            Text {
                id: recText

                text: "REC " + root.formatDuration(root.recordingDuration)
                color: "white"
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

        }

        // Pulse animations for the container
        SequentialAnimation on opacity {
            running: root.isRecording
            loops: Animation.Infinite

            NumberAnimation {
                to: 0.4
                duration: 600
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                to: 1
                duration: 600
                easing.type: Easing.InOutSine
            }

        }

        SequentialAnimation on scale {
            running: root.isRecording
            loops: Animation.Infinite

            NumberAnimation {
                to: 1.03
                duration: 600
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                to: 1
                duration: 600
                easing.type: Easing.InOutSine
            }

        }

    }

    // CPU
    Rectangle {
        width: cpuText.width + memText.width + 24
        height: 24
        radius: root.theme.radius
        color: root.theme.bgAlt
        anchors.verticalCenter: parent.verticalCenter

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                id: cpuText

                text: "  " + root.cpuUsage + "% |"
                color: root.cpuUsage > 80 ? root.theme.red : (root.cpuUsage > 50 ? root.theme.yellow : root.theme.aqua)
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                font.bold: true

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }

                }

            }

            Text {
                id: memText

                text: "  " + root.memUsage + "%"
                color: root.memUsage > 80 ? root.theme.red : (root.memUsage > 60 ? root.theme.yellow : root.theme.aqua)
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                font.bold: true

                Behavior on color {
                    ColorAnimation {
                        duration: 300
                    }

                }

            }

        }

    }

    // Power
    Rectangle {
        width: powerText.width + 16
        height: 24
        radius: root.theme.radius
        color: root.theme.bgAlt
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: powerText

            anchors.centerIn: parent
            text: "⏻"
            color: root.theme.red
            font.family: root.theme.fontFamily
            font.pixelSize: root.theme.fontSize - 2
            font.bold: true
        }

    }

}
