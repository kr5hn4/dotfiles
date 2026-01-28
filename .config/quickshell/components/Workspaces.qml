import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    // Dependencies
    required property var theme
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

    function switchTag(tagNum) {
        tagSwitchProc.command = ["mmsg", "-s", "-t", tagNum.toString()];
        tagSwitchProc.running = true;
    }

    function parseLayoutMode(code) {
        return layoutModeMap[code] || "tile";
    }

    Layout.preferredWidth: 32 * 9
    Layout.preferredHeight: 32

    // Processes
    Process {
        id: tagSwitchProc

        command: ["mmsg", "-s", "-t", "1"]
        running: false
    }

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
                    const newMode = root.parseLayoutMode(parts[1]);
                    if (newMode !== root.layoutMode)
                        root.layoutMode = newMode;

                }
            }
        }

    }

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
                            root.currentTag = tagNum;

                    }
                }
            }
        }

    }

    // Initial state
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
                    root.currentTag = tag;

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

                root.layoutMode = root.parseLayoutMode(data.trim());
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
