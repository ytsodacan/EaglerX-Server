#!/bin/bash

# Cloudflared Tunnel Launcher - headless

# Kill any existing Cloudflared processes first
pkill -9 cloudflared 2>/dev/null

# List of tunnel tokens
cloudflared_tunnel_tokens=(
  "eyJhIjoiZjBhOTg0MWYyYmVlZmIyOWUzNmJhOTg4ODBiMmM1NDAiLCJ0IjoiZTBkMDg4MDQtOWY3NS00YmE4LWE1MjgtZjRmODgyOGQwMDc4IiwicyI6Ik1tVTFOREExTXpBdFlqYzNaUzAwWXpsbUxUa3lOemN0WkdZelptVmlNMlkyTURaaCJ9"
  "eyJhIjoiZjBhOTg0MWYyYmVlZmIyOWUzNmJhOTg4ODBiMmM1NDAiLCJ0IjoiNTQ0ZjE5ZWMtMmM4MC00OWIyLWIwNDYtNDczNTkxODdiMmRjIiwicyI6Ik9EQTFaams0T0RFdFlqTmlNaTAwTWpobExUaG1Zamd0TWpGbE56SmpNVGRpTlRoaiJ9"
)

# Start tunnels in the background
for token in "${cloudflared_tunnel_tokens[@]}"; do
  nohup cloudflared tunnel run --token "$token" >/dev/null 2>&1 &
done

echo "All Cloudflared tunnels started in the background."
