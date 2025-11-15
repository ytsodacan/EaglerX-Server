#!/bin/bash

# Start Cuberite headless in background

cd ./Cuberite
chmod +x Cuberite
nohup ./Cuberite >/dev/null 2>&1 &
echo "Cuberite server started in background."
