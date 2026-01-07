import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

ShellRoot {
    id: root

    // =========================
    // Gruvbox Theme (Dark)
    // =========================
    readonly property color colBg: "#282828"
    readonly property color colBgAlt: "#3c3836"
    readonly property color colFg: "#ebdbb2"
    readonly property color colMuted: "#928374"
    readonly property color colOrange: "#fe8019"
    readonly property color colAqua: "#8ec07c"
    readonly property color colGreen: "#b8bb26"
    readonly property color colYellow: "#fabd2f"
    readonly property color colPurple: "#d3869b"
    readonly property color colRed: "#fb4934"

    // =========================
    // Font
    // =========================
    readonly property string fontFamily: "Fira Code"
    readonly property int fontSize: 18

    // =========================
    // System state
    // =========================
    property int memUsage: 0
    property int cpuUsage: 0
    property int volumeLevel: 0
    property int currentTag: 1
    property string wifiInfo: "󰖪 offline"
    property string layoutMode: "tile"
    property bool isRecording: false

    // =========================
    // Layout mode mapping
    // =========================
    readonly property var layoutModeMap: ({
        "S": "scroller",
        "T": "tile",
        "G": "grid",
        "M": "monocle",
        "K": "deck",
        "CT": "center_tile",
        "RT": "right_tile",
        "VS": "vertical_scroller",
        "VT": "vertical_tile",
        "VG": "vertical_grid",
        "VK": "vertical_deck",
        "TG": "tgmix"
    })

    readonly property var layoutIcons: ({
        "tile": "󰕰",
        "scroller": "󰦪",
        "monocle": "󰊓",
        "grid": "󰇊",
        "deck": "󰝘",
        "center_tile": "󰝘",
        "vertical_tile": "󰢮",
        "right_tile": "󰕰",
        "vertical_scroller": "󰦪",
        "vertical_grid": "󰇊",
        "vertical_deck": "󰝘",
        "tgmix": "󰕰"
    })

    readonly property var workspaceIcons: [
        "",  // Code
        "",  // Browser (Chrome / web)
        "",  // Notes
        "󰏜",  // Files
        "󰉋",  // Games
        "󰭹",  // Chat / Discord
        "",  // Meeting
        "",  // logs
        ""   // Music
    ]

    // =========================
    // Helper function for layout mode parsing
    // =========================
    function parseLayoutMode(code) {
        return layoutModeMap[code] || "tile"
    }

    // =========================
    // Recording state watcher
    // =========================
    Process {
        id: recordingWatcher
        command: ["sh", "-c", "while true; do [ -f /tmp/.recording_lock ] && echo 'REC' || echo 'IDLE'; inotifywait -qq -e create,delete,modify /tmp/ -t 1 2>/dev/null; done"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                isRecording = (data.trim() === "REC")
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // System monitoring processes
    // =========================
    Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                cpuUsage = Math.round(parseFloat(data.trim()))
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const parts = data.trim().split(/\s+/)
                memUsage = Math.round(100 * (+parts[2]) / (+parts[1] || 1))
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const match = data.match(/Volume:\s*([\d.]+)/)
                if (match) volumeLevel = Math.round(parseFloat(match[1]) * 100)
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: wifiProc
        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | awk -F: '/^yes/ { ssid = $2; s = $3; i = (s > 80 ? \"󰤨\" : s > 60 ? \"󰤥\" : s > 40 ? \"󰤢\" : s > 20 ? \"󰤟\" : \"󰤯\"); printf \"%s %s %s%%\\n\", i, ssid, s; found = 1; } END { if (!found) print \"󰖪 Disconnected\"; }'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                wifiInfo = data.trim()
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // Layout mode watcher
    // =========================
    Process {
        id: layoutWatcher
        command: ["mmsg", "-o", "HDMI-A-1", "-wl"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const parts = data.trim().split(/\s+/)
                if (parts.length >= 2 && parts[0] === "layout") {
                    const newMode = parseLayoutMode(parts[1])
                    if (newMode !== layoutMode) {
                        layoutMode = newMode
                    }
                }
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // Tag/workspace watchers
    // =========================
    Process {
        id: tagsWatcher
        command: ["mmsg", "-o", "HDMI-A-1", "-wt"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const line = data.trim()
                if (line.startsWith("tag ")) {
                    const parts = line.split(/\s+/)
                    if (parts.length >= 5) {
                        const tagNum = parseInt(parts[1])
                        const isActive = parseInt(parts[4]) === 1
                        if (isActive && tagNum >= 1 && tagNum <= 9) {
                            currentTag = tagNum
                        }
                    }
                }
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // Initial state processes
    // =========================
    Process {
        id: tagsProc
        command: ["sh", "-c", "mmsg -o HDMI-A-1 -gt | awk '/\\(null\\)/ {n++; if (n % 3 == 2) v = $4 + 0; print int(1 + log(v)/log(2))}' | tail -n 1"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                const tag = parseInt(data.trim())
                if (tag >= 1 && tag <= 9) {
                    currentTag = tag
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: layoutProc
        command: ["sh", "-c", "mmsg -o HDMI-A-1 -gl | awk '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                layoutMode = parseLayoutMode(data.trim())
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // Polling timers
    // =========================
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true
            volProc.running = true
            cpuProc.running = true
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: wifiProc.running = true
    }

    // =========================
    // Panel
    // =========================
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            height: 32
            color: root.colBg
            mask: null

            Rectangle {
                anchors.fill: parent
                color: root.colBg

                // Clock (Centered)
                Text {
                    id: clockText
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(new Date(), "ddd MMM dd  HH:mm")
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    font.bold: true
                    z: 10

                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = Qt.formatDateTime(new Date(), "ddd MMM dd  HH:mm")
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item { width: 24 }
                    
                    Text {
                        text: "🌴"
                        color: "white"
                        font.pixelSize: 24
                        verticalAlignment: Text.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { width: 24 }

                    // Workspaces/Tags (1–9)
                    Repeater {
                        model: 9

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            color: "transparent"

                            property int tagNum: index + 1
                            property bool isActive: root.currentTag === tagNum
                            property bool isHovered: false

                            Text {
                                anchors.centerIn: parent
                                text: root.workspaceIcons[parent.tagNum - 1]
                                color: parent.isActive ? root.colAqua : (parent.isHovered ? root.colAqua : root.colMuted)
                                font.family: root.fontFamily
                                font.pixelSize: 20
                                scale: parent.isHovered ? 1.15 : 1.0

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on scale { NumberAnimation { duration: 100 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true

                                onEntered: parent.isHovered = true
                                onExited: parent.isHovered = false

                                onClicked: {
                                    const proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                    proc.command = ["mmsg", "-s", "-t", parent.tagNum.toString()]
                                    proc.running = true
                                }
                            }
                        }
                    }

                    Item { width: 24 }

                    // Layout Mode Indicator
                    Rectangle {
                        Layout.preferredWidth: layoutModeText.width + 20
                        Layout.preferredHeight: 24
                        color: root.colBgAlt
                        radius: 4

                        Text {
                            id: layoutModeText
                            anchors.centerIn: parent
                            text: (root.layoutIcons[root.layoutMode] || "󰕰") + " " + root.layoutMode.toUpperCase()
                            color: root.colOrange
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 2
                            font.bold: true
                        }
                    }

                    Item { width: 12 }

                    // Window Title
                    Rectangle {
                        Layout.preferredWidth: 350
                        Layout.fillHeight: true
                        color: "transparent"
                        clip: true

                        Text {
                            id: titleText
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: windowTitle
                            color: root.colPurple
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 2
                            font.bold: true
                            elide: Text.ElideRight
                            width: parent.width
                            visible: windowTitle !== ""
                            opacity: 0

                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            Component.onCompleted: opacity = 1
                            onTextChanged: {
                                opacity = 0
                                opacityTimer.restart()
                            }

                            Timer {
                                id: opacityTimer
                                interval: 50
                                onTriggered: titleText.opacity = 1
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }
                    Item { Layout.preferredWidth: clockText.width }
                    Item { Layout.fillWidth: true }

                    // System stats (Right)
                    Row {
                        spacing: 12
                        Layout.rightMargin: 12

                        // Recording Indicator
                        Rectangle {
                            width: recText.width + 32
                            height: 24
                            radius: 12
                            color: root.colRed
                            visible: root.isRecording
                            anchors.verticalCenter: parent.verticalCenter

                            SequentialAnimation on opacity {
                                running: root.isRecording
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.3; duration: 800; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                            }

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "●"
                                    color: "white"
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    id: recText
                                    text: "REC"
                                    color: "white"
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize - 2
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // WiFi
                        Rectangle {
                            width: wifiText.width + 16
                            height: 24
                            radius: 4
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: wifiText
                                anchors.centerIn: parent
                                text: wifiInfo
                                color: root.colYellow
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true
                            }
                        }

                        // CPU
                        Rectangle {
                            width: cpuText.width + 16
                            height: 24
                            radius: 4
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: cpuText
                                anchors.centerIn: parent
                                text: "CPU " + cpuUsage + "%"
                                color: cpuUsage > 80 ? root.colRed : (cpuUsage > 50 ? root.colYellow : root.colGreen)
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true

                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }

                        // Volume
                        Rectangle {
                            width: volText.width + 16
                            height: 24
                            radius: 4
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter

                            property bool isHovered: false
                            scale: isHovered ? 1.05 : 1.0

                            Behavior on scale { NumberAnimation { duration: 100 } }

                            Text {
                                id: volText
                                anchors.centerIn: parent
                                text: "VOL " + volumeLevel + "%"
                                color: root.colGreen
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered: parent.isHovered = true
                                onExited: parent.isHovered = false

                                onWheel: wheel => {
                                    const change = wheel.angleDelta.y > 0 ? "5%+" : "5%-"
                                    const proc = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                    proc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", change]
                                    proc.running = true
                                    volProc.running = true
                                }
                            }
                        }

                        // Memory
                        Rectangle {
                            width: memText.width + 16
                            height: 24
                            radius: 4
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: memText
                                anchors.centerIn: parent
                                text: "MEM " + memUsage + "%"
                                color: memUsage > 80 ? root.colRed : (memUsage > 60 ? root.colYellow : root.colAqua)
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true

                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }
                    }

                    Item { width: 12 }
                }
            }
        }
    }
}
