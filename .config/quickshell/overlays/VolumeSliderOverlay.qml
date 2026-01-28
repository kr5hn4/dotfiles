import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: volumePanel

    // Properties that need to be passed in from parent
    required property color colBg
    required property color colBgAlt
    required property color colFg
    required property color colGreen
    required property color colAqua
    required property int radius
    required property string fontFamily
    required property int fontSize
    required property int volumeLevel
    required property bool showOverlay
    // Internal state
    property bool sliderHovered: false
    property bool sliderPressed: false

    // Signals to communicate back to parent
    signal hideRequested()
    signal volumeChanged()

    // Expose method to stop hide timer from parent
    function stopHideTimer() {
        hideTimer.stop();
    }

    function startHideTimer() {
        if (!sliderPressed && !sliderHovered)
            hideTimer.restart();

    }

    width: 200
    height: 60
    visible: showOverlay
    color: "transparent"
    exclusiveZone: -1

    anchors {
        top: true
        right: true
    }

    margins {
        top: 32
        right: 130
    }

    // Dedicated process for slider volume changes
    Process {
        id: sliderVolumeProc

        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "50%"]
        running: false
    }

    Timer {
        id: hideTimer

        interval: 400
        repeat: false
        onTriggered: volumePanel.hideRequested()
    }

    MouseArea {
        id: overlayMouseArea

        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        z: 0
        onEntered: {
            volumePanel.sliderHovered = true;
            hideTimer.stop();
        }
        onExited: {
            volumePanel.sliderHovered = false;
            if (!volumePanel.sliderPressed)
                hideTimer.restart();

        }
        onPressed: (mouse) => {
            return mouse.accepted = false;
        }
        onReleased: (mouse) => {
            return mouse.accepted = false;
        }
        onWheel: (wheel) => {
            return wheel.accepted = false;
        }
    }

    // Custom shape background with arrow and border
    Canvas {
        id: backgroundCanvas

        anchors.fill: parent
        z: 0
        // Animations
        opacity: volumePanel.showOverlay ? 1 : 0
        scale: volumePanel.showOverlay ? 1 : 0.8
        transformOrigin: Item.TopRight
        Component.onCompleted: requestPaint()
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var arrowWidth = 20;
            var arrowHeight = 10;
            var rectX = 0;
            var rectY = arrowHeight;
            var rectWidth = width;
            var rectHeight = height - arrowHeight;
            var rad = volumePanel.radius;
            var centerX = rectWidth / 2;
            // Draw filled shape
            ctx.fillStyle = volumePanel.colBg;
            ctx.beginPath();
            // Top-left corner
            ctx.moveTo(rectX + rad, rectY);
            // Top edge to arrow start
            ctx.lineTo(centerX - arrowWidth / 2, rectY);
            // Arrow point
            ctx.lineTo(centerX, rectY - arrowHeight);
            ctx.lineTo(centerX + arrowWidth / 2, rectY);
            // Continue top edge
            ctx.lineTo(rectX + rectWidth - rad, rectY);
            // Top-right corner
            ctx.arcTo(rectX + rectWidth, rectY, rectX + rectWidth, rectY + rad, rad);
            // Right edge
            ctx.lineTo(rectX + rectWidth, rectY + rectHeight - rad);
            // Bottom-right corner
            ctx.arcTo(rectX + rectWidth, rectY + rectHeight, rectX + rectWidth - rad, rectY + rectHeight, rad);
            // Bottom edge
            ctx.lineTo(rectX + rad, rectY + rectHeight);
            // Bottom-left corner
            ctx.arcTo(rectX, rectY + rectHeight, rectX, rectY + rectHeight - rad, rad);
            // Left edge
            ctx.lineTo(rectX, rectY + rad);
            // Top-left corner
            ctx.arcTo(rectX, rectY, rectX + rad, rectY, rad);
            ctx.closePath();
            ctx.fill();
            // Draw border
            ctx.strokeStyle = volumePanel.colBgAlt;
            ctx.lineWidth = 2;
            ctx.stroke();
        }

        Connections {
            function onShowOverlayChanged() {
                backgroundCanvas.requestPaint();
            }

            target: volumePanel
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }

        }

    }

    // Content on top
    Item {
        anchors.fill: parent
        anchors.topMargin: 10
        z: 1

        Column {
            // Text {
            //     text: "  " + volumePanel.volumeLevel + "%"
            //     color: volumePanel.colFg
            //     font.family: volumePanel.fontFamily
            //     font.pixelSize: volumePanel.fontSize - 2
            //     font.bold: true
            //     anchors.horizontalCenter: parent.horizontalCenter
            // }

            anchors.centerIn: parent
            spacing: 8
            width: parent.width - 20

            Slider {
                id: volumeSlider

                width: parent.width
                from: 0
                to: 100
                value: volumePanel.volumeLevel
                stepSize: 1
                onPressedChanged: {
                    volumePanel.sliderPressed = pressed;
                    if (pressed) {
                        hideTimer.stop();
                    } else {
                        if (!volumePanel.sliderHovered)
                            hideTimer.restart();

                    }
                }
                onMoved: {
                    sliderVolumeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", Math.round(value) + "%"];
                    sliderVolumeProc.running = true;
                    volumePanel.volumeChanged();
                }

                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 4
                    width: volumeSlider.availableWidth
                    height: 4
                    radius: 2
                    color: volumePanel.colBgAlt

                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        color: volumePanel.colGreen
                        radius: 2
                    }

                }

                handle: Rectangle {
                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    width: 16
                    height: 16
                    radius: 8
                    color: volumeSlider.pressed ? volumePanel.colAqua : volumePanel.colGreen
                    border.color: volumePanel.colFg
                    border.width: 2
                }

            }

        }

    }

    mask: Region {
        item: backgroundCanvas
    }

}
