#!/usr/bin/env bash

set -euo pipefail

DEBUG=false

usage() {
	echo "Usage $0 [-d] <port1> [port2] [port3] ..."
	exit1
}

log_debug() {
	if 
		[ "DEBUG" = true ]; then
		echo "[DEBUG] $1"
	fi
}

check_port() {
	local PORT=$1

	log_debug "Checking port $PORT"

	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
		echo "Invalid port: $PORT"
		return 2
	fi

	LINE=$(sudo ss -tulnp 2>/dev/null | grep ":$PORT " || true)

	if [ -z "$LINE" ]; then
		echo "Port $PORT: FREE"
		return 0
	fi

	PID=$(echo "$LINE" | grep -oP 'pid=\K[0-9]+' | head -n1 | tr -d '\n')

	if [ -z "$PID" ]; then
		echo "Port $PORT: IN USE (PID unknown)"
		return 1
	fi

	PROC=$(ps -p "$PID" -o pid,user,comm --no-headers)

	echo "Port $PORT: IN USE"
	echo " $PROC"
	return 1

}

# ----- main -----

if [ $# = "-d" ]; then
	usage
fi

if [ $1 = "-d" ]; then
	DEBUG=true
	shift
fi

if [ $# -eq 0 ]; then
	usage
fi

EXIT_CODE=0

for PORT in "$@"; do
	if ! check_port "$PORT"; then 
		EXIT_CODE=1
	fi
done

exit $EXIT_CODE