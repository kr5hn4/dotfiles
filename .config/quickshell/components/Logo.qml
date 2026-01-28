import QtQuick
import Quickshell

Text {
    id: root2

    required property var theme

    text: "󰣇"
    color: theme.archLogoColor
    font.pixelSize: 32
}
