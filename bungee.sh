#!/bin/bash

# Start Bungee/Waterfall and show logs in terminal

cd ./Bungee
echo "Starting Bungee/Waterfall. Logs will appear below:"
java -Xmx128M -Xms128M -jar bungee.jar
