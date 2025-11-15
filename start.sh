#!/bin/bash

# Eaglercraft Server Launcher - headless, no auto-restart

unset DISPLAY

# Kill previous tmux session, Java, and Cloudflared processes
tmux has-session -t server 2>/dev/null && tmux kill-session -t server
pkill -9 java 2>/dev/null
pkill -9 cloudflared 2>/dev/null

# Enable tmux mouse support silently
echo "set -g mouse on" > ~/.tmux.conf

# Start Caddy
if [ -d "./Caddy" ]; then
  (cd ./Caddy && caddy stop >/dev/null 2>&1 && nohup caddy start --config ./Caddyfile >/dev/null 2>&1 &) 
fi

# Start Cuberite
if [ -d "./Cuberite" ]; then
  (cd ./Cuberite && chmod +x Cuberite && nohup ./Cuberite >/dev/null 2>&1 &) 
fi

# Start Bungee/Waterfall
if [ -d "./Bungee" ]; then
  (cd ./Bungee && nohup java -Xmx128M -Xms128M -jar bungee.jar >/dev/null 2>&1 &) 
fi

# Start Cloudflared tunnels
cloudflared_tunnel_tokens=(
  "eyJhIjoiZjBhOTg0MWYyYmVlZmIyOWUzNmJhOTg4ODBiMmM1NDAiLCJ0IjoiZTBkMDg4MDQtOWY3NS00YmE4LWE1MjgtZjRmODgyOGQwMDc4IiwicyI6Ik1tVTFOREExTXpBdFlqYzNaUzAwWXpsbUxUa3lOemN0WkdZelptVmlNMlkyTURaaCJ9"
  "eyJhIjoiZjBhOTg0MWYyYmVlZmIyOWUzNmJhOTg4ODBiMmM1NDAiLCJ0IjoiNTQ0ZjE5ZWMtMmM4MC00OWIyLWIwNDYtNDczNTkxODdiMmRjIiwicyI6Ik9EQTFaams0T0RFdFlqTmlNaTAwTWpobExUaG1Zamd0TWpGbE56SmpNVGRpTlRoaiJ9"
)

for token in "${cloudflared_tunnel_tokens[@]}"; do
  nohup cloudflared tunnel run --token "$token" >/dev/null 2>&1 &
done

# Start Eaglercraft Relay
nohup java -jar EaglerSPRelay.jar --debug >/dev/null 2>&1 &

echo "All services started in background. No auto-restart."
