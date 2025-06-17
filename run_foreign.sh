#!/bin/bash
# Usage: ./run_foreign.sh <foreign-local-ssh-port> <national-user@host[:port1,port2,...]> <identity-file> <reverse-tunnel-port>

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <foreign-local-ssh-port> <national-user@host[:port1,port2,...]> <identity-file> <reverse-tunnel-port>"
  exit 1
fi

FOREIGN_PORT=$1
NATIONAL_TARGET=$2
IDENTITY_FILE=$3
REVERSE_PORT=$4

USER_AT_HOST=$(echo "$NATIONAL_TARGET" | cut -d':' -f1)
PORTS_RAW=$(echo "$NATIONAL_TARGET" | cut -s -d':' -f2)
IFS=',' read -ra PORTS <<< "${PORTS_RAW:-22}"

for P in "${PORTS[@]}"; do
  echo "[*] Trying SSH reverse tunnel to $USER_AT_HOST on port $P..."
  ssh -i "$IDENTITY_FILE" -N -R "$REVERSE_PORT:localhost:$FOREIGN_PORT" -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -p "$P" "$USER_AT_HOST" && break
  echo "[!] Failed on port $P, trying next..."
done
