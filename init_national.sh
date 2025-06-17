#!/bin/bash
# Usage: ./init_national.sh <port1> [port2] [port3]...

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <port1> [port2] ..."
  exit 1
fi

echo "[*] Installing OpenSSH server if missing..."
sudo apt update
sudo apt install -y openssh-server

echo "[*] Configuring SSH to listen on: $*"
sudo sed -i '/^Port /d' /etc/ssh/sshd_config
for PORT in "$@"; do
  echo "Port $PORT" | sudo tee -a /etc/ssh/sshd_config
done

echo "[*] Enabling GatewayPorts..."
sudo sed -i '/^#*GatewayPorts /d' /etc/ssh/sshd_config
echo "GatewayPorts yes" | sudo tee -a /etc/ssh/sshd_config

echo "[*] Restarting sshd..."
sudo systemctl restart sshd
