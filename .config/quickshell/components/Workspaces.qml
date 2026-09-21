import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Dependencies
    required property var theme

    // Output this bar is shown on
    readonly property string outputName: "HDMI-A-1"

    // =========================
    // Logic: Workspaces & Layouts
    // =========================
    property int currentTag: 1
    property string layoutMode: "tile"
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
            "DW": "dwindle",
            "F": "fair",
            "VF": "vertical_fair"
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

    function switchTag(tagNum) {
        tagSwitchProc.command = ["mmsg", "dispatch", "view," + tagNum.toString()];
        tagSwitchProc.running = true;
    }

    function parseLayoutMode(code) {
        return layoutModeMap[code] || "tile";
    }

    // Apply one monitor object from mmsg's JSON
    function applyMonitor(mon) {
        if (!mon || mon.name !== outputName)
            return;

        let tag = 0;
        if (mon.active_tags && mon.active_tags.length > 0) {
            tag = mon.active_tags[0];
        } else if (mon.tags) {
            const activeTag = mon.tags.find(x => x.is_active);
            if (activeTag)
                tag = activeTag.index;
        }
        if (tag >= 1 && tag <= 9 && tag !== currentTag)
            currentTag = tag;

        if (mon.layout_symbol) {
            const mode = parseLayoutMode(mon.layout_symbol);
            if (mode !== layoutMode)
                layoutMode = mode;
        }
    }

    // Handles both {"monitors":[...]} frames and a bare monitor object
    function applyFrame(obj) {
        if (obj && Array.isArray(obj.monitors))
            obj.monitors.forEach(m => applyMonitor(m));
        else
            applyMonitor(obj);
    }

    // Accumulates lines until they form valid JSON, so this works whether
    // mmsg prints one frame per line or pretty-prints across several lines
    property string frameBuf: ""
    function feedLine(line) {
        if (line.length === 0)
            return;
        if (line.charAt(0) === "{")
            frameBuf = "";   // unindented "{" = start of a new frame
        frameBuf += line;

        let obj;
        try {
            obj = JSON.parse(frameBuf);
        } catch (e) {
            if (frameBuf.length > 262144)
                frameBuf = "";
            return;
        }
        frameBuf = "";
        applyFrame(obj);
    }

    Layout.preferredWidth: 32 * 9
    Layout.preferredHeight: 32

    // Processes
    Process {
        id: tagSwitchProc

        running: false
    }

    // Live updates (tags + layout)
    Process {
        id: monitorWatcher

        command: ["mmsg", "watch", "all-monitors"]
        running: true

        stdout: SplitParser {
            onRead: data => root.feedLine(data)
        }
    }

    // Initial state, in case the watch doesn't emit a snapshot on connect
    Process {
        id: initialState

        command: ["mmsg", "get", "all-monitors"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.applyFrame(JSON.parse(text));
                } catch (e) {
                    console.warn("mmsg get all-monitors: could not parse output", e);
                }
            }
        }
    }

    // Sliding background highlight
    Rectangle {
        id: activeIndicator

        width: 32
        height: 32
        radius: root.theme.radius
        color: root.theme.bgAlt
        anchors.verticalCenter: parent.verticalCenter
        // Position based on current tag (1-indexed)
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
                color: parent.isActive ? root.theme.aqua : (parent.isHovered ? root.theme.aqua : root.theme.muted)
                font.family: root.theme.fontFamily
                font.pixelSize: 20
                scale: parent.isActive ? 1.15 : (parent.isHovered ? 1.1 : 1)
                z: 1

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
                onClicked: root.switchTag(parent.tagNum)
            }
        }
    }
}
