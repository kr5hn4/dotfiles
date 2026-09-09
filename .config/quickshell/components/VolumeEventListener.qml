import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int volumeLevel: 0
    property bool volumeMuted: false
    property bool showVolumeOverlay: false
    property bool showVolumeOSD: false // Kept for compatibility if needed

    function setVolume(change) {
        volumeChangeProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", change];
        volumeChangeProc.running = true;
    }

    // =========================
    // Volume watcher
    // =========================
    Process {
        id: volumeMonitor

        // pw-mon streams audio state changes in real-time natively
        command: ["sh", "-c", "pw-mon | grep --line-buffered \"node\""]
        running: true

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    // Filter out empty lines or noise
                    return;

                // Whenever an audio event happens, trigger your volume checker
                volumeCheck.running = true;
            }
        }
    }

    Process {
        id: volumeCheck

        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;

                const match = data.match(/Volume:\s*([\d.]+)/);
                if (match)
                    root.volumeLevel = Math.round(parseFloat(match[1]) * 100);

                root.volumeMuted = data.includes("[MUTED]");
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

    // Actions
    Process {
        id: volumeChangeProc

        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%+"]
        running: false
    }

    // OSD auto-hide (if needed by other components)
    Timer {
        id: volumeOSDTimer

        interval: 1500
        repeat: false
        onTriggered: root.showVolumeOSD = false
    }
}
