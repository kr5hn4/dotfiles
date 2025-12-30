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
    property color colBg: "#282828"        // bg0
    property color colBgAlt: "#3c3836"     // bg1
    property color colFg: "#ebdbb2"        // primary foreground
    property color colMuted: "#928374"     // gray / inactive

    property color colOrange: "#fe8019"
    property color colAqua: "#8ec07c"
    property color colGreen: "#b8bb26"
    property color colBlue: "#83a598"
    property color colYellow: "#fabd2f"
    property color colPurple: "#d3869b"

    // =========================
    // Font
    // =========================
    property string fontFamily: "Fira Code"
    property int fontSize: 18

    // =========================
    // System state
    // =========================
    property int memUsage: 0
    property int volumeLevel: 0
    property int currentTag: 1
    property string wifiInfo: "󰖪 0%"
    property string windowTitle: ""

    // =========================
    // Memory usage
    // =========================
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var p = data.trim().split(/\s+/)
                memUsage = Math.round(100 * (+p[2]) / (+p[1] || 1))
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // Volume (PipeWire/WirePlumber)
    // =========================
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var m = data.match(/Volume:\s*([\d.]+)/)
                if (m) volumeLevel = Math.round(parseFloat(m[1]) * 100)
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // WiFi info with SSID
    // =========================
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
    // Window title watcher
    // Format: "HDMI-A-1 title <actual title>"
    // =========================
    Process {
        id: titleWatcher
        command: ["mmsg", "-w", "-c"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var line = data.trim()
                var parts = line.split(/\s+/)
                
                // Look for lines with "title" in column 2
                if (parts.length >= 3 && parts[1] === "title") {
                    // Join everything from column 3 onwards as the title
                    windowTitle = parts.slice(2).join(" ")
                    console.log("Window title:", windowTitle)
                }
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // Watch for tag changes in real-time using mmsg -wt
    // Format: "tag <num> <state1> <state2> <active>"
    // Active tag has 1 in the last column
    // =========================
    Process {
        id: tagsWatcher
        command: ["mmsg", "-o", "HDMI-A-1", "-wt"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var line = data.trim()
                
                // Parse lines starting with "tag"
                if (line.startsWith("tag ")) {
                    var parts = line.split(/\s+/)
                    if (parts.length >= 5) {
                        var tagNum = parseInt(parts[1])
                        var isActive = parseInt(parts[4]) === 1
                        
                        if (isActive && tagNum >= 1 && tagNum <= 9) {
                            currentTag = tagNum
                            console.log("Active tag:", currentTag)
                        }
                    }
                }
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // Get initial tag state
    // =========================
    Process {
        id: tagsProc
        command: ["sh", "-c", "mmsg -o HDMI-A-1 -gt | awk '/\\(null\\)/ {n++; if (n % 3 == 2) v = $4 + 0; print int(1 + log(v)/log(2))}' | tail -n 1"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var tag = parseInt(data.trim())
                if (tag >= 1 && tag <= 9) {
                    currentTag = tag
                    console.log("Initial tag:", currentTag)
                }
            }
        }
        Component.onCompleted: running = true
    }

    // =========================
    // Timers for polling system stats
    // =========================
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true
            volProc.running = true
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            wifiProc.running = true
        }
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
            
            // Allow content to overflow panel bounds for popups
            mask: null

            Rectangle {
                anchors.fill: parent
                color: root.colBg

                // =========================
                // Date and Time (Absolutely centered)
                // =========================
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
                        onTriggered: clockText.text =
                            Qt.formatDateTime(new Date(), "ddd MMM dd  HH:mm")
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    Item { width: 12 }

                    // =========================
                    // Workspaces/Tags (1–9)
                    // =========================
                    Repeater {
                        model: 9

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            color: "transparent"

                            property int tagNum: index + 1
                            property bool isActive: root.currentTag === tagNum

                            Rectangle {
                                anchors.centerIn: parent
                                width: 24
                                height: 24
                                radius: 4
                                color: parent.isActive ? root.colBgAlt : "transparent"
                                border.color: parent.isActive ? root.colOrange : root.colMuted
                                border.width: parent.isActive ? 2 : 1

                                Text {
                                    anchors.centerIn: parent
                                    text: parent.parent.tagNum
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize - 2
                                    font.bold: parent.parent.isActive
                                    color: parent.parent.isActive ? root.colAqua : root.colMuted
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    console.log("Clicked tag", parent.tagNum)
                                    var proc = Qt.createQmlObject(
                                        'import Quickshell.Io; Process {}',
                                        root
                                    )
                                    proc.command = ["mmsg", "-s", "-t", parent.tagNum.toString()]
                                    proc.running = true
                                }
                            }
                        }
                    }

                    Item { width: 12 }

                    // =========================
                    // Window Title
                    // =========================
                    Rectangle {
                        Layout.preferredWidth: 350
                        Layout.fillHeight: true
                        color: "transparent"
                        clip: true

                        Text {
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
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Spacer for clock (keep layout balanced)
                    Item { 
                        Layout.preferredWidth: clockText.width
                    }

                    Item { Layout.fillWidth: true }

                    // =========================
                    // System stats (Right)
                    // =========================
                    Row {
                        spacing: 16
                        Layout.rightMargin: 12

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

                        // Volume with scroll and popup
                        Rectangle {
                            id: volumeWidget
                            width: volText.width + 16
                            height: 24
                            radius: 4
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter

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
                                id: volumeMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                
                                onWheel: wheel => {
                                    var delta = wheel.angleDelta.y
                                    var change = delta > 0 ? "5%+" : "5%-"
                                    
                                    var proc = Qt.createQmlObject(
                                        'import Quickshell.Io; Process {}',
                                        root
                                    )
                                    proc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", change]
                                    proc.running = true
                                    
                                    // Immediately refresh volume
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
                                color: root.colBlue
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true
                            }
                        }
                    }

                    Item { width: 12 }
                }
            }
        }
    }
}
