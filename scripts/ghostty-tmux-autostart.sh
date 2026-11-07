#!/usr/bin/env bash

SESSION_NAME="ghostty-$$"

# Clean up the tmux session when Ghostty closes
trap 'tmux kill-session -t "$SESSION_NAME" 2>/dev/null; exit' SIGHUP SIGINT SIGTERM

# Create a new session and attach
tmux new-session -s "$SESSION_NAME"
