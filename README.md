# 🔁 Reverse SSH Tunnel Toolkit

A flexible shell-based toolkit for setting up reverse SSH tunnels through a foreign server.  

---

## 📁 Scripts Overview

### 1. `init_national.sh`
Prepare your **national server** to accept SSH connections on multiple ports.

```bash
./init_national.sh <port1> [port2] [port3] ...
```

This:
- Installs and configures OpenSSH
- Adds the given ports to `sshd_config`
- Enables `GatewayPorts` for proper reverse forwarding

---

### 2. `run_foreign.sh`
Run a reverse SSH tunnel manually (good for use in GitHub Codespaces, Colab, etc.).

```bash
./run_foreign.sh <local-ssh-port> <national-user@national-host[:ports+]> <identity-file> <reverse-tunnel-port>
```

Attempts to connect to the national server through the given SSH ports and expose the foreign SSH server on the national one.

---

### 3. `init_foreign.sh`
Sets up a persistent reverse SSH tunnel on the **foreign server** using a `systemd` service.

```bash
./init_foreign.sh <local-ssh-port> <national-user@national-host[:ports+]> <identity-file> <reverse-tunnel-port>
```

This automates the reverse tunnel and survives reboots using `systemd`.

---

### 4. `init_local.sh`
Adds SSH configuration on your **local machine** so you can easily:

- Access the foreign server via the national jump host
- Start a local SOCKS5 proxy (`ssh <name> -D 1080`)

```bash
./init_local.sh <name> <national-user@host:port> <national-identity> <foreign-user> <foreign-port> <foreign-identity>
```

This adds two SSH config entries:
- `name_national`: config for national jump host
- `name`: config for connecting to the foreign server via `ProxyJump`

---

## 🛠️ Full Setup Workflow (From Scratch)

### 1. 🔐 Create SSH key pairs

> **Important:**  
> This toolkit **does not** generate or install SSH keys for you.
> You must generate desired SSH keys with commands below:

On your **local machine**, generate two sets of keys:

```bash
# For local → national
ssh-keygen -t ed25519 -f ~/.ssh/national_key

# For local → foreign connection (via national)
ssh-keygen -t ed25519 -f ~/.ssh/foreign_key
```

- Copy `national_key.pub` to `~/.ssh/authorized_keys` on the **national server**
- Copy `foreign_key.pub` to `~/.ssh/authorized_keys` on the **foreign server**

On your **foreign machine**, generate one set of keys:

```bash
# For foreign → national reverse tunnel
ssh-keygen -t ed25519 -f ~/.ssh/tunnel_key
```

- Then, append `tunnel_key.pub` to end of `~/.ssh/authorized_keys` on the **national server**

---

### 2. 🏛️ Prepare the national server

SSH into the national server, and run:

```bash
git clone https://github.com/ahmz1833/Reverse-Shell.git
cd Reverse-Shell
./init_national.sh 22 1404 2222 10293
```

This ensures SSH is available on all desired ports and supports reverse tunnels.

---

### 3. 🌍 Set up the foreign server

First, Connect to your foreign server and clone the repository:

```bash
git clone https://github.com/ahmz1833/Reverse-Shell.git
cd Reverse-Shell
```

#### Option A: Temporary (for Codespaces/Colab):

```bash
./run_foreign.sh 2222 ubuntu@185.2.3.117:22,1404,10293,2222 ~/.ssh/tunnel_key 2200
```

#### Option B: Persistent (using `systemd`):

```bash
./init_foreign.sh 2222 ubuntu@185.2.3.117:22,1404,10293,2222 ~/.ssh/tunnel_key 2200
```

---

### 4. 💻 Configure your local machine

```bash
git clone https://github.com/ahmz1833/Reverse-Shell.git
cd Reverse-Shell
./init_local.sh vpn ubuntu@185.2.3.117:2222 ~/.ssh/national_key ubuntu 2200 ~/.ssh/foreign_key
```

This creates SSH config entries so you can connect easily:

```bash
ssh vpn           # connect to foreign server via national server
ssh vpn -D 1080   # SOCKS5 proxy available at localhost:1080
```

Then, configure your browser or apps to use:
```
SOCKS5 proxy: 127.0.0.1
Port: 1080
```

---

## ⚠️ Disclaimer

- Use responsibly.  
- Make sure you're compliant with local laws and network policies.

---

## 📄 License

MIT License – free to use and modify.
