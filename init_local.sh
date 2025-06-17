#!/bin/bash
# Usage: ./init_local.sh <name> <national-user@host:port> <national-identity> <foreign-user> <foreign-port> <foreign-identity>

if [[ $# -ne 6 ]]; then
  echo "Usage: $0 <name> <national-user@host:port> <national-identity> <foreign-user> <foreign-port> <foreign-identity>"
  exit 1
fi

NAME=$1
NATIONAL_TARGET=$2
NATIONAL_KEY=$3
FOREIGN_USER=$4
FOREIGN_PORT=$5
FOREIGN_KEY=$6

CONFIG="$HOME/.ssh/config"

HOST=$(echo "$NATIONAL_TARGET" | cut -d'@' -f2 | cut -d':' -f1)
PORT=$(echo "$NATIONAL_TARGET" | cut -d':' -f2)

echo "[*] Adding SSH config entries to $CONFIG..."

mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch "$CONFIG" && chmod 600 "$CONFIG"

if ! grep -q "Host ${NAME}_national" "$CONFIG"; then
cat <<EOF >> "$CONFIG"

Host ${NAME}_national
  HostName $HOST
  Port $PORT
  User $(echo "$NATIONAL_TARGET" | cut -d'@' -f1)
  IdentityFile $NATIONAL_KEY
EOF
fi

if ! grep -q "Host $NAME" "$CONFIG"; then
cat <<EOF >> "$CONFIG"

Host $NAME
  HostName localhost
  Port $FOREIGN_PORT
  User $FOREIGN_USER
  ProxyJump ${NAME}_national
  IdentityFile $FOREIGN_KEY
EOF
fi

echo "[*] Done. You can now connect using:"
echo "    ssh $NAME"
echo "    ssh $NAME -D 1080  # for SOCKS5 proxy"
