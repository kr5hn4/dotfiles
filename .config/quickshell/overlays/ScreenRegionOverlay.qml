import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: scope

    property var modelData
    required property color borderColor
    required property int borderWidth
    // Overlay state
    property bool showOverlay: false
    property int overlayX: 0
    property int overlayY: 0
    property int overlayWidth: 0
    property int overlayHeight: 0

    // Monitor overlay region file - simple approach watching /tmp for our specific file
    Process {
        id: overlayMonitor

        command: ["sh", "-c", "inotifywait -m -e create,modify,delete /tmp/ 2>/dev/null | grep --line-buffered 'overlay_region'"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                regionCheck.running = true;
            }
        }

    }

    // Check overlay region file
    Process {
        id: regionCheck

        command: ["sh", "-c", "if [ -f /tmp/overlay_region ]; then cat /tmp/overlay_region; else echo 'FILE_NOT_FOUND'; fi"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (!data || data.trim() === "" || data.includes("FILE_NOT_FOUND")) {
                    scope.showOverlay = false;
                    return ;
                }
                // Parse geometry: "X,Y WxH" (e.g., "100,200 500x300")
                const match = data.trim().match(/(\d+),(\d+)\s+(\d+)x(\d+)/);
                if (match) {
                    scope.overlayX = parseInt(match[1]);
                    scope.overlayY = parseInt(match[2]);
                    scope.overlayWidth = parseInt(match[3]);
                    scope.overlayHeight = parseInt(match[4]);
                    scope.showOverlay = true;
                } else {
                    scope.showOverlay = false;
                }
            }
        }

    }

    // Initial check
    Timer {
        interval: 100
        running: true
        repeat: false
        onTriggered: regionCheck.running = true
    }

    // Overlay window - use Rectangle positioned absolutely
    PanelWindow {
        // Dimming effect - 4 rectangles around the selected region

        id: overlay

        screen: scope.modelData
        visible: scope.showOverlay && scope.overlayWidth > 0 && scope.overlayHeight > 0
        color: "transparent"
        mask: null
        exclusiveZone: -1

        // Cover entire screen
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        // Top bar (above selection)
        Rectangle {
            x: 0
            y: 0
            width: parent.width
            height: scope.overlayY
            color: "#000000"
            opacity: 0.5
        }

        // Bottom bar (below selection)
        Rectangle {
            x: 0
            y: scope.overlayY + scope.overlayHeight
            width: parent.width
            height: parent.height - (scope.overlayY + scope.overlayHeight)
            color: "#000000"
            opacity: 0.5
        }

        // Left bar (left of selection)
        Rectangle {
            x: 0
            y: scope.overlayY
            width: scope.overlayX
            height: scope.overlayHeight
            color: "#000000"
            opacity: 0.5
        }

        // Right bar (right of selection)
        Rectangle {
            x: scope.overlayX + scope.overlayWidth
            y: scope.overlayY
            width: parent.width - (scope.overlayX + scope.overlayWidth)
            height: scope.overlayHeight
            color: "#000000"
            opacity: 0.5
        }

        // Border around selected region
        Rectangle {
            x: scope.overlayX
            y: scope.overlayY
            width: scope.overlayWidth
            height: scope.overlayHeight
            color: "transparent"
            border.color: scope.borderColor
            border.width: scope.borderWidth
            radius: 0

            // Pulsing opacity animation
            SequentialAnimation on opacity {
                running: scope.showOverlay
                loops: Animation.Infinite

                NumberAnimation {
                    to: 0.5
                    duration: 1000
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    to: 1
                    duration: 1000
                    easing.type: Easing.InOutSine
                }

            }

        }

    }

}
