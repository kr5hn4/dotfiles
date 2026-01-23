#!/usr/bin/env bash

###############################################################################
# Screenshot Launcher
#
# Take a screenshot with chosen aspect ratio (16:9, 9:16, 1:1)
###############################################################################

SCREENSHOT_DIR="$HOME/screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Show Fuzzel menu with heredoc
choice=$(fuzzel --dmenu <<EOF
16:9
9:16
1:1
EOF
)

# Exit if nothing selected
[ -z "$choice" ] && exit 0

# Aspect ratio mapping
case "$choice" in
    "16:9") aspect="16:9" ;;
    "9:16") aspect="9:16" ;;
    "1:1")  aspect="1:1" ;;
    *) exit 1 ;;
esac

# Take screenshot
grim -g "$(slurp -a "$aspect")" "$SCREENSHOT_DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
