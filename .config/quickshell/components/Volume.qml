import QtQuick

Rectangle {
    id: root

    required property var theme
    required property var volume // The Volume Module
    property bool isHovered: false

    width: volText.width + 16
    height: 24
    radius: theme.radius
    color: theme.bgAlt
    anchors.verticalCenter: parent.verticalCenter
    scale: isHovered ? 1.05 : 1

    Text {
        id: volText

        anchors.centerIn: parent
        text: (root.volume.volumeMuted ? "󰖁" : " ") + " " + root.volume.volumeLevel + "%"
        color: theme.green
        font.family: theme.fontFamily
        font.pixelSize: theme.fontSize - 2
        font.bold: true
    }

    MouseArea {
        // Don't immediately hide - let overlay handle it
        id: volumeMouseArea

        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: false
        onEntered: {
            parent.isHovered = true;
            root.volume.showVolumeOverlay = true;
        }
        onExited: {
            parent.isHovered = false;
        }
        onWheel: (wheel) => {
            const change = wheel.angleDelta.y > 0 ? "5%+" : "5%-";
            root.volume.setVolume(change);
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 100
        }

    }

}
