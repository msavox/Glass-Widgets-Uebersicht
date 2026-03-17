#!/bin/bash
#   ____ _                         __        ___     _            _       
#  / ___| | __ _ ___ ___           \ \      / (_) __| | __ _  ___| |_ ___ 
# | |  _| |/ _` / __/ __|  _____    \ \ /\ / /| |/ _` |/ _` |/ _ \ __/ __|
# | |_| | | (_| \__ \__ \ |_____|    \ V  V / | | (_| | (_| |  __/ |_ \__ \
#  \____|_|\__,_|___/___/             \_/\_/  |_|\__,_|\__, |\___|\__|___/
#                                                      |___/              
#
# Author:  Matteo Savoia
# Version: 1.0
# Release: 2026
# ---------------------------------------------------------------------------

INTERFACE=$(route get default 2>/dev/null | grep interface | awk '{print $2}')
[ -z "$INTERFACE" ] && INTERFACE="en0"
SSID=$(networksetup -getairportnetwork "$INTERFACE" 2>/dev/null | cut -d ":" -f 2- | sed 's/^ //')
if [ -z "$SSID" ] || [[ "$SSID" == *"Error"* ]] || [[ "$SSID" == *"not associated"* ]]; then
    SSID=$(networksetup -listallhardwareports | grep -B 1 "$INTERFACE" | head -n 1 | cut -d ":" -f 2- | sed 's/^ //')
    [ -z "$SSID" ] && SSID="$INTERFACE"
fi
read -r IN1 OUT1 <<< $(netstat -ib -n -I "$INTERFACE" | grep -v Name | awk '{print $7, $10}' | head -n 1)
sleep 0.5
read -r IN2 OUT2 <<< $(netstat -ib -n -I "$INTERFACE" | grep -v Name | awk '{print $7, $10}' | head -n 1)
DIFF_IN=$((IN2 - IN1))
DIFF_OUT=$((OUT2 - OUT1))
echo "${DIFF_IN}^${DIFF_OUT}^${SSID}"
