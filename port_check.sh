#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color


DEBUG=false
KILL=false

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

	#echo "DEBUG PORT=[$PORT]"

	if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
		echo -e "${YELLOW}Invalid port: $PORT${NC}"
		return 2
	fi

	LINE=$(sudo ss -tulnp 2>/dev/null | grep ":$PORT " || true)

	if [ -z "$LINE" ]; then
		echo -e "${GREEN}Port $PORT: FREE${NC}"
		return 0
	fi

	PID=$(echo "$LINE" | grep -oP 'pid=\K[0-9]+' | head -n1 | tr -d '\n')

	if [ -z "$PID" ]; then
		echo -e "${RED}Port $PORT: IN USE${NC} (PID unknown)"
		return 1
	fi

	if [ "$KILL" = true ]; then
		echo "Killing process $PID..."
		sudo kill "$PID"
	fi

	PROC=$(ps -p "$PID" -o pid,user,comm --no-headers)

	echo "Port $PORT: IN USE"
	echo " $PROC"
	return 1

}

main() {

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

	if [ "$1" = "--kill" ]; then
		KILL=true
		shift
	fi


	if [ "$KILL" = true ] && [ "$EUID" -ne 0 ]; then
		echo "You must run with sudo to use --kill"
		exit 1
	fi

	EXIT_CODE=0

	for PORT in "$@"; do
		if ! check_port "$PORT"; then 
			EXIT_CODE=1
		fi
	done

	exit $EXIT_CODE
}

main "$@"