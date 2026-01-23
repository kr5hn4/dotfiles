#!/bin/bash

###############################################################################
# Screen Recorder Toggle (Wayland)
#
# Starts or stops a screen recording using wf-recorder and slurp
# If already recording, it stops the current recording.
###############################################################################

LOCK_FILE="/tmp/.recording_lock"
OVERLAY_FILE="/tmp/overlay_region"
VIDEO_DIR="$HOME/screen-recordings/"

mkdir -p "$VIDEO_DIR"

cleanup() {
    rm -f "$LOCK_FILE"
    rm -f "$OVERLAY_FILE"  # Remove overlay on stop
}
trap cleanup EXIT INT TERM

# If already recording, stop it
if pgrep -x wf-recorder > /dev/null; then
    pkill -INT wf-recorder
    exit 0
fi

# Select area with slurp
GEOMETRY=$(slurp 2>&1)
if [ $? -ne 0 ] || [ -z "$GEOMETRY" ]; then
    notify-send "Recording" "Cancelled" -u low
    exit 1
fi

# Create lock file and write overlay region
touch "$LOCK_FILE"
echo "$GEOMETRY" > "$OVERLAY_FILE"

# Start recording
wf-recorder -g "$GEOMETRY" -f "$VIDEO_DIR/recording_$(date '+%Y%m%d_%H%M%S').mp4"
