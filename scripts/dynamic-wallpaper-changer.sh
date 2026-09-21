#!/usr/bin/env bash

mmsg watch all-tags | while read -r event; do

    # Use jq to parse the JSON and extract the index number where is_active is true
    VIEW=$(echo "$event" | jq '.all_tags[0].tags[] | select(.is_active == true) | .index' 2>/dev/null)

    # Trigger wallpaper change if a view index was successfully parsed
    if [ ! -z "$VIEW" ]; then
        case "$VIEW" in
        0) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        1) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        2) awww img "$HOME/wallpapers/wallpaper.webp" --transition-type none ;;
        3) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        4) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        5) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        6) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        7) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        8) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        9) awww img "$HOME/wallpapers/wallpaper.jpg" --transition-type none ;;
        esac
    fi
done
