#!/bin/bash

# Kill all Eaglercraft-related processes

# Kill tmux session
tmux has-session -t server 2>/dev/null && tmux kill-session -t server

# Kill Cuberite and Bungee Java processes
pkill -9 java 2>/dev/null

# Kill the Eaglercraft Relay specifically
pkill -f "EaglerSPRelay.jar" 2>/dev/null

# Kill Cloudflared tunnels
pkill -9 cloudflared 2>/dev/null

# Optional: stop Caddy if running
if pgrep caddy >/dev/null 2>&1; then
    caddy stop >/dev/null 2>&1
fi

echo "All Eaglercraft server processes terminated."
