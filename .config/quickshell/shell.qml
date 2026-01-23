import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "components" as Components
import "modules" as Modules

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

    // Arch logo color and border radius
    readonly property color archLogoColor: "#458588"
    readonly property int radius: 16

    // =========================
    // Font
    // =========================

    readonly property string fontFamily: "FiraMono Nerd Font"
    readonly property int fontSize: 18

    // =========================
    // System state
    // =========================
    property int memUsage: 0
    property int cpuUsage: 0
    property int volumeLevel: 0
    property bool volumeMuted: false
    property int currentTag: 1
    property string wifiInfo: "󰖪 offline"
    property string layoutMode: "tile"
    property bool isRecording: false
    property int recordingDuration: 0 // in seconds
    property bool showVolumeOverlay: false
    property bool showVolumeOSD: false

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

    readonly property var workspaceIcons: ["󰆍", "", "", "󰚩", "", "󰡳", "󱛿", "", "󰂖"]

    // =========================
    // Helper function for layout mode parsing
    // =========================
    function parseLayoutMode(code) {
        return layoutModeMap[code] || "tile";
    }

    // Helper function to format recording duration
    function formatDuration(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
    }

    // =========================
    // Recording state watcher
    // =========================
    Process {
        id: recordingWatcher

        command: ["sh", "-c", "while true; do [ -f /tmp/.recording_lock ] && echo 'REC' || echo 'IDLE'; inotifywait -qq -e create,delete,modify /tmp/ -t 1 2>/dev/null || sleep 1; done"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const wasRecording = isRecording;
                isRecording = (data.trim() === "REC");
                // Reset timer when recording starts
                if (isRecording && !wasRecording)
                    recordingDuration = 0;

            }
        }

    }

    // Recording duration timer
    Timer {
        interval: 1000
        running: root.isRecording
        repeat: true
        onTriggered: root.recordingDuration++
    }

    // =========================
    // EVENT-DRIVEN: Volume monitoring with pactl subscribe
    // =========================
    Process {
        id: volumeMonitor

        command: ["sh", "-c", "pactl subscribe | grep --line-buffered \"'change' on sink\""]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                // Trigger volume check when sink changes
                volumeCheck.running = true;
            }
        }

    }

    Process {
        id: volumeCheck

        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const match = data.match(/Volume:\s*([\d.]+)/);
                if (match)
                    volumeLevel = Math.round(parseFloat(match[1]) * 100);

                volumeMuted = data.includes("[MUTED]");
            }
        }

    }

    // Initial volume check
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: volumeCheck.running = true
    }

    // =========================
    // EVENT-DRIVEN: WiFi monitoring with debouncing
    // =========================
    Timer {
        id: wifiDebounce
        interval: 500 // Wait 500ms before checking WiFi after events
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

                // Debounce: restart timer on each event
                wifiDebounce.restart();
            }
        }
    }

    Process {
        id: wifiCheck

        command: ["sh", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | awk -F: '/^yes/ { ssid = $2; s = $3; i = (s > 80 ? \"󰤨 \" : s > 60 ? \"󰤥 \" : s > 40 ? \"󰤢 \" : s > 20 ? \"󰤟 \" : \"󰤯 \"); printf \"%s%s\", i, ssid; found = 1; } END { if (!found) print \"󰖪 Disconnected\"; }'"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                wifiInfo = data.trim();
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

    // Memory usage process
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
                    memUsage = val;

            }
        }

    }

    // CPU usage process
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
                    cpuUsage = val;

            }
        }

    }

    // Timer triggers for cpu and memory usage
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true;
            cpuProc.running = true;
        }
    }

    // Initial checks
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: {
            memProc.running = true;
            cpuProc.running = true;
        }
    }

    // =======================
    // Reusable wpctl process
    // =======================
    Process {
        id: volumeChangeProc

        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]
        running: false
    }

    Process {
        id: tagSwitchProc

        command: ["mmsg", "-s", "-t", "1"]
        running: false
    }

    // =========================
    // Layout mode watcher
    // =========================
    Process {
        id: layoutWatcher

        command: ["mmsg", "-o", "HDMI-A-1", "-wl"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const parts = data.trim().split(/\s+/);
                if (parts.length >= 2 && parts[0] === "layout") {
                    const newMode = parseLayoutMode(parts[1]);
                    if (newMode !== layoutMode)
                        layoutMode = newMode;

                }
            }
        }

    }

    // =========================
    // Tag/workspace watchers
    // =========================
    Process {
        id: tagsWatcher

        command: ["mmsg", "-o", "HDMI-A-1", "-wt"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const line = data.trim();
                if (line.startsWith("tag ")) {
                    const parts = line.split(/\s+/);
                    if (parts.length >= 5) {
                        const tagNum = parseInt(parts[1]);
                        const isActive = parseInt(parts[4]) === 1;
                        if (isActive && tagNum >= 1 && tagNum <= 9)
                            currentTag = tagNum;

                    }
                }
            }
        }

    }

    // =========================
    // Initial state processes
    // =========================
    Process {
        id: tagsProc

        command: ["sh", "-c", "mmsg -o HDMI-A-1 -gt | awk '/\\(null\\)/ {n++; if (n % 3 == 2) v = $4 + 0; print int(1 + log(v)/log(2))}' | tail -n 1"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const tag = parseInt(data.trim());
                if (tag >= 1 && tag <= 9)
                    currentTag = tag;

            }
        }

    }

    Process {
        id: layoutProc

        command: ["sh", "-c", "mmsg -o HDMI-A-1 -gl | awk '{print $2}'"]
        Component.onCompleted: running = true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                layoutMode = parseLayoutMode(data.trim());
            }
        }

    }

    // =========================
    // Volume OSD auto-hide timer
    // =========================
    Timer {
        id: volumeOSDTimer

        interval: 1500
        repeat: false
        onTriggered: root.showVolumeOSD = false
    }

    // =========================
    // Panel
    // =========================
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen: modelData
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

                    Item {
                        width: 24
                    }

                    Text {
                        text: "󰣇"
                        color: root.archLogoColor
                        font.pixelSize: 24
                        verticalAlignment: Text.AlignVCenter
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        width: 24
                    }

                    // Workspaces/Tags (1–9) - With sliding indicator!
                    Item {
                        Layout.preferredWidth: 32 * 9
                        Layout.preferredHeight: 32

                        // Sliding background highlight
                        Rectangle {
                            id: activeIndicator

                            width: 32
                            height: 32
                            radius: root.radius
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter
                            x: (root.currentTag - 1) * 32
                            opacity: 0.8

                            Behavior on x {
                                NumberAnimation {
                                    duration: 300
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                        // Workspace icons
                        Repeater {
                            model: 9

                            Rectangle {
                                property int tagNum: index + 1
                                property bool isActive: root.currentTag === tagNum
                                property bool isHovered: false

                                x: index * 32
                                width: 32
                                height: 32
                                color: "transparent"

                                Text {
                                    anchors.centerIn: parent
                                    text: root.workspaceIcons[parent.tagNum - 1]
                                    color: parent.isActive ? root.colAqua : (parent.isHovered ? root.colAqua : root.colMuted)
                                    font.family: root.fontFamily
                                    font.pixelSize: 20
                                    scale: parent.isActive ? 1.15 : (parent.isHovered ? 1.1 : 1)
                                    z: 1 // Above background

                                    Behavior on color {
                                        ColorAnimation {
                                            duration: 150
                                        }

                                    }

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 200
                                            easing.type: Easing.OutBack
                                        }

                                    }

                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true
                                    onEntered: parent.isHovered = true
                                    onExited: parent.isHovered = false
                                    onClicked: {
                                        // Use reusable process instead of creating new ones
                                        tagSwitchProc.command = ["mmsg", "-s", "-t", parent.tagNum.toString()];
                                        tagSwitchProc.running = true;
                                    }
                                }

                            }

                        }

                    }

                    Item {
                        width: 24
                    }

                    // Layout Mode Indicator
                    Rectangle {
                        Layout.preferredWidth: layoutModeText.width + 20
                        Layout.preferredHeight: 24
                        color: root.colBgAlt
                        radius: root.radius

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

                    Item {
                        width: 12
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.preferredWidth: clockText.width
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // System stats (Right)
                    Row {
                        spacing: 12
                        Layout.rightMargin: 12

                        // Recording Indicator
                        Rectangle {
                            width: recText.width + 40
                            height: 24
                            radius: root.radius
                            color: root.colRed
                            visible: root.isRecording
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
                                    font.family: root.fontFamily
                                    font.pixelSize: root.fontSize - 2
                                    font.bold: true
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                            }

                            // Enhanced pulsing animation
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

                            // Subtle scale pulse
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

                        // WiFi
                        Rectangle {
                            width: wifiText.width + 16
                            height: 24
                            radius: root.radius
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

                        // Volume
                        Rectangle {
                            id: volumeRect

                            property bool isHovered: false

                            width: volText.width + 16
                            height: 24
                            radius: root.radius
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter
                            scale: isHovered ? 1.05 : 1

                            Text {
                                id: volText

                                anchors.centerIn: parent
                                text: (root.volumeMuted ? "󰖁" : " ") + " " + volumeLevel + "%"
                                color: root.colGreen
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true
                            }

                            MouseArea {
                                // Don't immediately hide - let overlay handle it
                                // The overlay has its own hide timer that will trigger

                                id: volumeMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                propagateComposedEvents: false
                                onEntered: {
                                    parent.isHovered = true;
                                    root.showVolumeOverlay = true;
                                }
                                onExited: {
                                    parent.isHovered = false;
                                }
                                onWheel: (wheel) => {
                                    const change = wheel.angleDelta.y > 0 ? "5%+" : "5%-";
                                    volumeChangeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", change];
                                    volumeChangeProc.running = true;
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 100
                                }

                            }

                        }

                        // CPU
                        Rectangle {
                            width: cpuText.width + 16
                            height: 24
                            radius: root.radius
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: cpuText

                                anchors.centerIn: parent
                                text: "  " + cpuUsage + "%"
                                color: cpuUsage > 80 ? root.colRed : (cpuUsage > 50 ? root.colYellow : root.colAqua)
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 300
                                    }

                                }

                            }

                        }

                        // Memory
                        Rectangle {
                            width: memText.width + 16
                            height: 24
                            radius: root.radius
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: memText

                                anchors.centerIn: parent
                                text: "  " + memUsage + "%"
                                color: memUsage > 80 ? root.colRed : (memUsage > 60 ? root.colYellow : root.colAqua)
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 300
                                    }

                                }

                            }

                        }

                        // Power
                        Rectangle {
                            width: powerText.width + 16
                            height: 24
                            radius: root.radius
                            color: root.colBgAlt
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: powerText

                                anchors.centerIn: parent
                                text: "⏻"
                                color: root.colRed
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 2
                                font.bold: true
                            }

                        }

                    }

                    Item {
                        width: 8
                    }

                }

            }

        }

    }

    // Volume slider overlay
    Variants {
        model: Quickshell.screens

        Components.VolumeSliderOverlay {
            screen: modelData // Now modelData exists!
            colBg: root.colBg
            colBgAlt: root.colBgAlt
            colFg: root.colFg
            colGreen: root.colGreen
            colAqua: root.colAqua
            radius: root.radius
            fontFamily: root.fontFamily
            fontSize: root.fontSize
            volumeLevel: root.volumeLevel
            showOverlay: root.showVolumeOverlay
            onHideRequested: {
                root.showVolumeOverlay = false;
            }
            onVolumeChanged: {
                volumeCheck.running = true;
            }
        }

    }

    // Generic Circular Progress Bar - Volume
    Variants {
        model: Quickshell.screens

        Components.GenericCircularProgressBar {
            property var modelData

            osdType: "volume"
            colBg: root.colBg
            colAccent: root.colGreen
            colFg: root.colFg
            fontFamily: root.fontFamily
        }

    }

    Variants {
        model: Quickshell.screens

        Components.USBDeviceDetection {
            property var modelData

            colBg: root.colBg
            colFg: root.colFg
            fontFamily: root.fontFamily
        }

    }

    Variants {
        model: Quickshell.screens

        Components.ScreenRegionOverlay {
            borderColor: root.colRed
            borderWidth: 3
        }

    }

}
