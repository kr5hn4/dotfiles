import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: scope

    property var modelData
    required property color colBg
    required property color colFg
    required property string fontFamily
    // Notification queue
    property var notificationQueue: []
    property bool isShowingNotification: false
    // Current notification state
    property string deviceInfo: ""
    property bool isPlugIn: true
    // Device cache for unplug detection
    property var deviceCache: ({
    })

    function cacheDevice(path, info) {
        var cache = scope.deviceCache;
        cache[path] = info;
        scope.deviceCache = cache;
    }

    function getCachedDevice(path) {
        return scope.deviceCache[path] || "Unknown Device";
    }

    function removeCachedDevice(path) {
        var cache = scope.deviceCache;
        delete cache[path];
        scope.deviceCache = cache;
    }

    // Queue notification
    function queueNotification(info, isPlug) {
        var queue = scope.notificationQueue;
        queue.push({
            "info": info,
            "isPlug": isPlug
        });
        scope.notificationQueue = queue;
        if (!scope.isShowingNotification)
            showNextNotification();

    }

    // Show next notification from queue
    function showNextNotification() {
        if (scope.notificationQueue.length === 0) {
            scope.isShowingNotification = false;
            return ;
        }
        var queue = scope.notificationQueue;
        var next = queue.shift();
        scope.notificationQueue = queue;
        scope.deviceInfo = next.info;
        scope.isPlugIn = next.isPlug;
        scope.isShowingNotification = true;
        // Play sound
        soundProcess.running = true;
        hideTimer.restart();
    }

    // Auto-hide timer
    Timer {
        id: hideTimer

        interval: 3000
        repeat: false
        onTriggered: {
            scope.isShowingNotification = false;
            // Show next in queue after 200ms
            Qt.callLater(() => {
                showNextTimer.start();
            });
        }
    }

    // Delay before showing next notification
    Timer {
        id: showNextTimer

        interval: 200
        repeat: false
        onTriggered: scope.showNextNotification()
    }

    // Sound effect process
    Process {
        id: soundProcess

        command: ["paplay", "/usr/share/sounds/freedesktop/stereo/device-added.oga"]
        running: false
    }

    // USB event monitoring
    Process {
        id: usbMonitor

        property string action: ""
        property string devPath: ""
        property string vendor: ""
        property string model: ""

        command: ["sh", "-c", "udevadm monitor --udev --property --subsystem-match=usb/usb_device"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                // New event starts
                if (data.includes("UDEV")) {
                    usbMonitor.action = "";
                    usbMonitor.devPath = "";
                    usbMonitor.vendor = "";
                    usbMonitor.model = "";
                }
                // Get action
                const actionMatch = data.match(/ACTION=(.+)/);
                if (actionMatch)
                    usbMonitor.action = actionMatch[1].trim();

                // Get device path
                const pathMatch = data.match(/DEVPATH=(.+)/);
                if (pathMatch)
                    usbMonitor.devPath = pathMatch[1].trim();

                // Collect properties
                const vendorMatch = data.match(/ID_VENDOR=(.+)/);
                if (vendorMatch)
                    usbMonitor.vendor = vendorMatch[1].trim().replace(/_/g, " ");

                const modelMatch = data.match(/ID_MODEL=(.+)/);
                if (modelMatch)
                    usbMonitor.model = modelMatch[1].trim().replace(/_/g, " ");

                // Handle ADD events
                if (usbMonitor.action === "add" && usbMonitor.vendor && usbMonitor.model && usbMonitor.devPath) {
                    const info = usbMonitor.vendor + " " + usbMonitor.model;
                    // Cache for unplug
                    scope.cacheDevice(usbMonitor.devPath, info);
                    // Queue notification
                    scope.queueNotification(info, true);
                    // Reset
                    usbMonitor.action = "";
                }
                // Handle REMOVE events
                if (usbMonitor.action === "remove" && usbMonitor.devPath)
                    removeDebounce.restart();

            }
        }

    }

    // Debounce for remove events
    Timer {
        id: removeDebounce

        interval: 100
        repeat: false
        onTriggered: {
            if (usbMonitor.devPath) {
                const info = scope.getCachedDevice(usbMonitor.devPath);
                // Queue notification
                scope.queueNotification(info, false);
                scope.removeCachedDevice(usbMonitor.devPath);
                usbMonitor.action = "";
                usbMonitor.devPath = "";
            }
        }
    }

    PanelWindow {
        id: notification

        screen: scope.modelData
        width: 350
        height: 80
        visible: scope.isShowingNotification
        color: "transparent"
        mask: null
        exclusiveZone: -1

        // Top-right position
        anchors {
            top: true
            right: true
        }

        margins {
            top: 50
            right: 20
        }

        Rectangle {
            id: notifRect

            anchors.fill: parent
            color: scope.colBg
            radius: 12
            opacity: 0.95
            // Border with color based on action
            border.width: 2
            border.color: scope.isPlugIn ? "#b8bb26" : "#fb4934"

            Row {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                // Icon
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: scope.isPlugIn ? "󰚪" : "󰚌"
                    color: scope.isPlugIn ? "#b8bb26" : "#fb4934"
                    font.family: scope.fontFamily
                    font.pixelSize: 32
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    width: parent.width - 60

                    Text {
                        text: scope.isPlugIn ? "USB Connected" : "USB Disconnected"
                        color: scope.colFg
                        font.family: scope.fontFamily
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        text: scope.deviceInfo
                        color: scope.colFg
                        font.family: scope.fontFamily
                        font.pixelSize: 12
                        opacity: 0.8
                        width: parent.width
                        elide: Text.ElideRight
                    }

                }

            }

            // Click to dismiss
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    scope.isShowingNotification = false;
                    hideTimer.stop();
                    showNextTimer.start();
                }
            }

            // Slide-in animation
            transform: Translate {
                id: slideTransform

                x: scope.isShowingNotification ? 0 : 400

                Behavior on x {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

}
