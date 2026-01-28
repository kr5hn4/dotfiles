import QtQuick
import Quickshell
import "components" as Components
import "overlays" as Overlays

ShellRoot {
    id: root

    // =========================
    // Theme & System
    // =========================
    property var theme

    theme: Components.Theme {
    }

    // Logic Modules
    property var volume

    volume: Components.VolumeEventListener {
    }

    // =========================
    // Panel
    // =========================
    Variants {
        model: Quickshell.screens

        Components.TopPanel {
            screen: modelData
            theme: root.theme
            volumeModule: root.volume
        }

    }

    // =========================
    // Overlays
    // =========================
    Components.NotificationServer {
    }

    // Volume slider overlay
    Variants {
        model: Quickshell.screens

        Overlays.VolumeSliderOverlay {
            // The SystemContext watches for changes, but we can trigger if needed.

            screen: modelData
            // Pass Theme Props
            colBg: root.theme.bg
            colBgAlt: root.theme.bgAlt
            colFg: root.theme.fg
            colGreen: root.theme.green
            colAqua: root.theme.aqua
            radius: root.theme.radius
            fontFamily: root.theme.fontFamily
            fontSize: root.theme.fontSize
            // State
            volumeLevel: root.volume.volumeLevel
            showOverlay: root.volume.showVolumeOverlay
            onHideRequested: {
                root.volume.showVolumeOverlay = false;
            }
            onVolumeChanged: {
            }
        }

    }

    // Generic Circular Progress Bar - Volume
    Variants {
        model: Quickshell.screens

        Overlays.GenericCircularProgressBar {
            property var modelData

            osdType: "volume"
            colBg: root.theme.bg
            colAccent: root.theme.green
            colFg: root.theme.fg
            fontFamily: root.theme.fontFamily
        }

    }

    Variants {
        model: Quickshell.screens

        Overlays.USBDeviceDetection {
            property var modelData

            colBg: root.theme.bg
            colFg: root.theme.fg
            fontFamily: root.theme.fontFamily
        }

    }

    Variants {
        model: Quickshell.screens

        Overlays.ScreenRegionOverlay {
            borderColor: root.theme.red
            borderWidth: 3
        }

    }

}
