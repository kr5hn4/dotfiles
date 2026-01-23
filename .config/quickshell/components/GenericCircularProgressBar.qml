import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: scope

    property var modelData
    required property string osdType // "volume", "brightness", "mic"
    required property color colBg
    required property color colAccent
    required property color colFg
    required property string fontFamily
    // Internal state
    property int value: 0
    // 0-100 percentage
    property real animatedValue: 0
    // Smoothly animated version
    property bool showOSD: false
    property bool isMuted: false

    // Get icon based on type and value
    function getIcon() {
        if (scope.osdType === "volume") {
            if (scope.isMuted || scope.value === 0)
                return "󰖁";

            if (scope.value < 33)
                return "";

            if (scope.value < 66)
                return "";

            return "";
        } else if (scope.osdType === "brightness") {
            if (scope.value < 33)
                return "󰃟";

            if (scope.value < 66)
                return "󰃠";

            return "󰃞";
        } else if (scope.osdType === "mic") {
            return scope.isMuted ? "󰍭" : "󰍬";
        }
        return "";
    }

    // Get color based on value
    function getProgressColor() {
        if (scope.osdType === "volume") {
            if (scope.value === 0 || scope.isMuted)
                return "#928374";

            // Red
            if (scope.value > 90)
                return "#fb4934";

            // Orange
            if (scope.value > 80)
                return "#fe8019";

        }
        return scope.colAccent;
    }

    // Update animatedValue when value changes
    onValueChanged: {
        // Clamp value to 0-100 range
        animatedValue = Math.max(0, Math.min(100, value));
    }

    // Auto-hide timer
    Timer {
        id: hideTimer

        interval: 1500
        repeat: false
        onTriggered: scope.showOSD = false
    }

    // Volume monitoring (PipeWire/PulseAudio)
    Process {
        id: volumeMonitor

        command: ["sh", "-c", "pactl subscribe | grep --line-buffered \"'change' on sink\""]
        running: scope.osdType === "volume"

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                volumeCheck.running = true;
            }
        }

    }

    // Get current volume value
    Process {
        id: volumeCheck

        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const match = data.match(/Volume:\s*([\d.]+)/);
                if (match) {
                    const newVolume = Math.min(100, Math.round(parseFloat(match[1]) * 100));
                    // Only show OSD if volume actually changed
                    if (newVolume !== scope.value) {
                        scope.value = newVolume;
                        scope.isMuted = data.includes("[MUTED]");
                        scope.showOSD = true;
                        hideTimer.restart();
                    }
                }
            }
        }

    }

    // Brightness monitoring
    Process {
        id: brightnessMonitor

        command: ["sh", "-c", "inotifywait -m -e modify /sys/class/backlight/*/brightness 2>/dev/null | while read; do cat /sys/class/backlight/*/brightness /sys/class/backlight/*/max_brightness 2>/dev/null | paste -sd ' '; done"]
        running: scope.osdType === "brightness"

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const parts = data.trim().split(/\s+/);
                if (parts.length >= 2) {
                    const current = parseInt(parts[0]);
                    const max = parseInt(parts[1]);
                    scope.value = Math.round(100 * current / max);
                    scope.showOSD = true;
                    hideTimer.restart();
                }
            }
        }

    }

    // Microphone monitoring
    Process {
        id: micMonitor

        command: ["sh", "-c", "pactl subscribe | grep --line-buffered \"'change' on source\""]
        running: scope.osdType === "mic"

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                micCheck.running = true;
            }
        }

    }

    // Get current mic state
    Process {
        id: micCheck

        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const match = data.match(/Volume:\s*([\d.]+)/);
                if (match)
                    scope.value = Math.round(parseFloat(match[1]) * 100);

                scope.isMuted = data.includes("[MUTED]");
                scope.showOSD = true;
                hideTimer.restart();
            }
        }

    }

    PanelWindow {
        id: osd

        WlrLayershell.layer: WlrLayer.Overlay
        screen: scope.modelData
        width: 200
        height: 200
        visible: scope.showOSD
        color: "transparent"
        mask: null
        exclusiveZone: -1

        // Center on screen using margins
        margins {
            left: (screen.width - width) / 2
            top: (screen.height - height) / 2
        }

        Rectangle {
            anchors.fill: parent
            color: scope.colBg
            radius: 100
            opacity: scope.showOSD ? 0.95 : 0

            // Circular progress ring using Canvas
            Item {
                id: progressRing

                anchors.centerIn: parent
                width: 160
                height: 160

                // Background circle
                Canvas {
                    id: bgCanvas

                    anchors.fill: parent
                    contextType: "2d"
                    renderStrategy: Canvas.Threaded
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        var centerX = width / 2;
                        var centerY = height / 2;
                        var radius = width / 2 - 8;
                        ctx.strokeStyle = "#3c3836";
                        ctx.lineWidth = 24;
                        ctx.lineCap = "round";
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                        ctx.stroke();
                    }
                    Component.onCompleted: requestPaint()
                }

                // Progress arc
                Canvas {
                    id: progressCanvas

                    property real progress: scope.animatedValue
                    property color arcColor: scope.getProgressColor()

                    anchors.fill: parent
                    contextType: "2d"
                    renderStrategy: Canvas.Threaded
                    onProgressChanged: requestPaint()
                    onArcColorChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.clearRect(0, 0, width, height);
                        console.log("Progress Canvas paint - width:", width, "height:", height, "progress:", progress);
                        if (progress > 0) {
                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = width / 2 - 8;
                            var startAngle = -Math.PI / 2; // Start at top
                            var endAngle = startAngle + (progress / 100) * 2 * Math.PI;
                            ctx.strokeStyle = arcColor;
                            ctx.lineWidth = 24;
                            ctx.lineCap = "round";
                            console.log("Progress lineWidth:", ctx.lineWidth);
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, endAngle);
                            ctx.stroke();
                        }
                    }
                }

            }

            // Percentage centered with animation
            Text {
                anchors.centerIn: parent
                text: Math.round(scope.animatedValue) + "%"
                color: scope.colFg
                font.family: scope.fontFamily
                font.pixelSize: 56
                font.bold: true
                scale: scope.showOSD ? 1 : 0.8

                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutBack
                    }

                }

            }

            // Icon below percentage
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.verticalCenter
                anchors.topMargin: 35
                text: scope.getIcon()
                color: scope.colFg
                font.family: scope.fontFamily
                font.pixelSize: 32
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }

            }

        }

    }

    // Smooth value animation
    Behavior on animatedValue {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }

    }

}
