#!/bin/bash

SESSION_NAME="ghostty"

# 🪝 THE HOOK: Catch the signal sent when Ghostty closes, and kill the tmux session
trap "tmux kill-session -t $SESSION_NAME 2>/dev/null; exit" SIGHUP SIGINT SIGTERM

# Check if the session already exists
tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? -eq 0 ]; then
  # If the session exists, reattach to it
  tmux attach-session -t $SESSION_NAME
else
  # If the session doesn't exist, start a new one
  tmux new-session -s $SESSION_NAME -d
  tmux attach-session -t $SESSION_NAME
fi
