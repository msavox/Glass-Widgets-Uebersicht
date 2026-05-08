#!/bin/bash
#   ____ _                         __        ___     _            _
#  / ___| | __ _ ___ ___           \ \      / (_) __| | __ _  ___| |_ ___
# | |  _| |/ _` / __/ __|  _____    \ \ /\ / /| |/ _` |/ _` |/ _ \ __/ __|
# | |_| | | (_| \__ \__ \ |_____|    \ V  V / | | (_| | (_| |  __/ |_ \__ \
#  \____|_|\__,_|___/___/             \_/\_/  |_|\__,_|\__, |\___|\__|___/
#                                                      |___/
#
# Author:  Matteo Savoia
# Version: 1.1
# Release: 2026
# ---------------------------------------------------------------------------

INTERFACE=$(route get default 2>/dev/null | awk '/interface:/ {print $2}')
[ -z "$INTERFACE" ] && INTERFACE="en0"

# SSID detection — networksetup -getairportnetwork stopped returning the SSID
# on macOS 14+, so try ipconfig getsummary first (still works on Sequoia),
# then fall back to networksetup, then to a hardware-port label.
SSID=$(ipconfig getsummary "$INTERFACE" 2>/dev/null \
  | awk -F' : ' '/^[[:space:]]+SSID : / {print $2; exit}')

if [ -z "$SSID" ]; then
  SSID=$(networksetup -getairportnetwork "$INTERFACE" 2>/dev/null \
    | awk -F': ' '/Current Wi-Fi Network/ {print $2}')
fi

if [ -z "$SSID" ] || [[ "$SSID" == *"not associated"* ]] || [[ "$SSID" == *"Error"* ]]; then
  SSID=$(networksetup -listallhardwareports 2>/dev/null \
    | awk -v i="$INTERFACE" '/Hardware Port:/{p=$0} $0 ~ "Device: "i" *$" {sub(/Hardware Port: /,"",p); print p; exit}')
  [ -z "$SSID" ] && SSID="$INTERFACE"
fi

read -r IN1 OUT1 <<< $(netstat -ib -n -I "$INTERFACE" | awk 'NR>1 && $1==iface {print $7, $10; exit}' iface="$INTERFACE")
sleep 0.5
read -r IN2 OUT2 <<< $(netstat -ib -n -I "$INTERFACE" | awk 'NR>1 && $1==iface {print $7, $10; exit}' iface="$INTERFACE")
DIFF_IN=$(( (IN2 - IN1) * 2 ))   # bytes per second
DIFF_OUT=$(( (OUT2 - OUT1) * 2 ))
echo "${DIFF_IN}^${DIFF_OUT}^${SSID}"
