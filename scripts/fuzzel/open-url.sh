#!/usr/bin/env bash

###########################################
# URL Launcher with Fuzzel
#
# Opens websites using short commands:
#   gh:<user>        → GitHub profile
#   gh:<user>/<repo> → GitHub repo
#   yt:<query>       → YouTube search
#   r:<subreddit>    → Subreddit
#
###########################################

CHOICES=$(cat <<'EOF'
gh:<user>        Open GitHub profile
gh:<user>/<repo> Open GitHub repo
yt:<query>       YouTube search
r:<subreddit>    Open subreddit
EOF
)

# Launch Fuzzel for user input, preloaded with help
INPUT=$(echo "$CHOICES" | fuzzel --dmenu --prompt "Open: ")

# Exit if nothing selected
[[ -z "$INPUT" ]] && exit 0

# Extract only the command part (strip trailing description)
INPUT="${INPUT%%[[:space:]]*}"

# Process input
case "$INPUT" in
  gh:*)
    TARGET="${INPUT#gh:}"
    xdg-open "https://github.com/$TARGET"
    ;;
  yt:*)
    QUERY="${INPUT#yt:}"
    xdg-open "https://www.youtube.com/results?search_query=$(printf '%s' "$QUERY" | sed 's/ /+/g')"
    ;;
  r:*)
    SUB="${INPUT#r:}"
    xdg-open "https://reddit.com/r/$SUB"
    ;;
  *)
    notify-send "Unknown input: $INPUT"
    ;;
esac
