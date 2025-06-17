#!/bin/bash
# Usage: ./init_foreign.sh <local-ssh-port> <national-user@host[:ports+]> <identity-file> <reverse-tunnel-port>

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 <local-ssh-port> <national-user@host[:ports+]> <identity-file> <reverse-tunnel-port>"
  exit 1
fi

LOCAL_PORT=$1
NATIONAL_TARGET=$2
IDENTITY_FILE=$3
REVERSE_PORT=$4
SCRIPT_PATH="$HOME/reverse-tunnel.sh"
SERVICE_NAME=reverse-tunnel.service

echo "[*] Writing $SCRIPT_PATH..."
cat <<EOF > "$SCRIPT_PATH"
#!/bin/bash
USER_AT_HOST="$NATIONAL_TARGET"
IDENTITY_FILE="$IDENTITY_FILE"
LOCAL_PORT="$LOCAL_PORT"
REVERSE_PORT="$REVERSE_PORT"

PORTS_RAW=\$(echo "\$USER_AT_HOST" | cut -s -d':' -f2)
USER_AT_HOST=\$(echo "\$USER_AT_HOST" | cut -d':' -f1)
IFS=',' read -ra PORTS <<< "\${PORTS_RAW:-22}"

for PORT in "\${PORTS[@]}"; do
  echo "[*] Trying SSH reverse tunnel to \$USER_AT_HOST on port \$PORT..."
  /usr/bin/autossh -M 0 -N -R \${REVERSE_PORT}:localhost:\${LOCAL_PORT} -i "\$IDENTITY_FILE" -p "\$PORT" -o ServerAliveInterval=30 -o ServerAliveCountMax=3 "\$USER_AT_HOST" && break
  echo "[!] Failed on port \$PORT, trying next..."
done
EOF

chmod +x "$SCRIPT_PATH"

echo "[*] Creating systemd service..."
sudo tee "/etc/systemd/system/$SERVICE_NAME" > /dev/null <<EOF
[Unit]
Description=Persistent Reverse SSH Tunnel
After=network.target

[Service]
ExecStart=$SCRIPT_PATH
Restart=always
RestartSec=10
User=$USER

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable --now "$SERVICE_NAME"
