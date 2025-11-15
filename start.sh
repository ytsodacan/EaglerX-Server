#!/bin/bash

# Eaglercraft Full Launcher - tmux sessions

unset DISPLAY

# --------------------------
# 1. Start Cloudflared tunnels
# --------------------------
tmux new-session -d -s tunnels "bash -c './tunnel.sh; exec bash'"
echo "Cloudflared tunnels running in tmux session 'tunnels'."

# --------------------------
# 2. Start Cuberite server
# --------------------------
tmux new-session -d -s cuberite "bash -c 'cd ./Cuberite && chmod +x Cuberite && ./Cuberite; exec bash'"
echo "Cuberite server running in tmux session 'cuberite'."

# --------------------------
# 3. Start Eaglercraft Relay
# --------------------------
tmux new-session -d -s relay "bash -c 'java -jar ./EaglerSPRelay.jar --debug; exec bash'"
echo "Eaglercraft relay running in tmux session 'relay'."

# --------------------------
# 4. Start Bungee/Waterfall
# --------------------------
tmux new-session -d -s bungee "bash -c 'cd ./Bungee && java -Xmx128M -Xms128M -jar bungee.jar; exec bash'"
echo "Bungee/Waterfall running in tmux session 'bungee'."

# --------------------------
# Summary
# --------------------------
echo ""
echo "All services started in tmux sessions:"
echo "  tunnels  -> Cloudflared tunnels"
echo "  cuberite -> Cuberite server"
echo "  relay    -> Eaglercraft relay"
echo "  bungee   -> Bungee/Waterfall"
echo ""
echo "Attach to any session with: tmux attach -t <session_name>"
