#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]; then
	echo "Warning: Not running as root. Some processes may not show PID."
fi

PORT=$1

if [ -z "$PORT" ]; then
	echo  "Usage: /.port_check.sh <port>"
	exit 1
fi

echo "==================================="
echo "Checking port $PORT..."
echo "==================================="

LINE=$(ss -tulnp | grep ":$PORT ")

if [ -z "$LINE" ]; then
	echo "Result: Port $PORT is NOT in use."
	exit 0
fi

echo "Port $PORT is IN USE."
echo

# Получаем PID
PID=$(echo "$LINE" | grep -oP 'pid=\K[0-9]+')

if [ -z "$PID" ]; then
	echo "Could not determine PID. Process may be root-owned or require sudo."
	exit 1
fi

#Получаем подробности процесса
PROC=$(ps -p "$PID" -o pid,user,comm)

echo "Process details:"
echo "$PROC"
echo


#Проверяем, управляется ли процесс systemd
SERVICE=$(systemctl list-units --type=service --all | grep -w "$PID")
if [ -z "$SERVICE" ]; then
	echo "This process does NOT appear to be managed by systemd."
else
	echo "This process may be managed by systemd."
fi

echo "===================================="
