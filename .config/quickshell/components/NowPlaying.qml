import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Row {
    id: root

    required property var theme

    // Which player to show: the first one that's playing,
    // otherwise the first one that's paused, otherwise none.
    readonly property var player: {
        const list = Mpris.players.values;
        let paused = null;
        for (let i = 0; i < list.length; i++) {
            const p = list[i];
            if (p.playbackState === MprisPlaybackState.Playing)
                return p;
            if (paused === null && p.playbackState === MprisPlaybackState.Paused)
                paused = p;
        }
        return paused;
    }

    // Same property names as before, so the UI below is unchanged
    readonly property string status: player ? (player.playbackState === MprisPlaybackState.Playing ? "Playing" : "Paused") : ""
    readonly property string trackInfo: {
        if (!player)
            return "";
        const title = player.trackTitle;
        const artist = player.trackArtist;
        return artist ? artist + " - " + title : title;
    }
    // Seconds. 0 when the player doesn't report a length (e.g. live streams)
    readonly property real trackLength: (player && player.lengthSupported) ? player.length : 0
    // Seconds. Refreshed by the timer below via positionChanged()
    readonly property real trackPosition: player ? player.position : 0
    readonly property bool isActive: player !== null

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        const hrs = Math.floor(s / 3600);
        const mins = Math.floor((s % 3600) / 60);
        const secs = s % 60;
        const pad = n => (n < 10 ? "0" : "") + n;
        return hrs > 0 ? hrs + ":" + pad(mins) + ":" + pad(secs) : mins + ":" + pad(secs);
    }

    spacing: 0
    visible: isActive

    // Quickshell doesn't update `position` on its own while playing,
    // so nudge it while something is actually playing.
    Timer {
        interval: 500
        repeat: true
        running: root.status === "Playing"
        onTriggered: {
            if (root.player)
                root.player.positionChanged();
        }
    }

    Rectangle {
        width: 400
        // width: nowPlayingRow.width + 24
        height: 24
        radius: root.theme.radius
        color: root.theme.bgAlt
        anchors.verticalCenter: parent.verticalCenter

        Row {
            id: nowPlayingRow
            anchors.centerIn: parent
            spacing: 12

            Text {
                id: statusIcon
                text: root.status === "Playing" ? "▶" : "⏸"
                color: root.status === "Playing" ? root.theme.green : root.theme.yellow
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.trackInfo
                color: root.theme.fg
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                anchors.verticalCenter: parent.verticalCenter
                width: 225
                maximumLineCount: 1
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
            }

            Text {
                text: root.trackLength > 0 ? root.formatTime(root.trackPosition) + " / " + root.formatTime(root.trackLength) : root.formatTime(root.trackPosition)
                color: root.theme.aqua
                font.family: root.theme.fontFamily
                font.pixelSize: root.theme.fontSize - 2
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
