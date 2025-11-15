#!/bin/bash

# Kill all tmux sessions forcefully
for session in $(tmux ls 2>/dev/null | awk -F: '{print $1}'); do
    tmux kill-session -t "$session" 2>/dev/null
done

# Kill any remaining tmux processes just in case
pkill -9 tmux 2>/dev/null

# Kill all Java processes (Cuberite, Bungee, Relay)
pkill -9 java 2>/dev/null

# Kill Cloudflared tunnels
pkill -9 cloudflared 2>/dev/null

# Stop Caddy if running
if pgrep caddy >/dev/null 2>&1; then
    caddy stop >/dev/null 2>&1
fi

echo "All Eaglercraft tmux sessions and related processes terminated."
