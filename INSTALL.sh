#!/bin/bash
# SSHoney Installer Script
# Works locally with rootless Docker and in CI with pre-installed Docker

set -e

# -------------------------
# Configuration
# -------------------------
USER_NAME="$USER"
INSTALL_DIR="$(pwd)"
SERVICE_FILE="/etc/systemd/system/sshoney.service"

echo "[*] Starting SSHoney installation..."

# -------------------------
# 1. Install Docker rootless (skip in GitHub Actions)
# -------------------------
if [ -n "$GITHUB_ACTIONS" ]; then
    echo "[*] GitHub Actions detected, skipping rootless Docker install"
else
    if ! command -v docker &> /dev/null; then
        echo "[*] Docker not found. Installing Docker rootless..."

        # Remove conflicting packages if any
        sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

        # Install prerequisites
        sudo apt-get update
        sudo apt-get install -y curl uidmap dbus-user-session

        # Install rootless Docker
        curl -fsSL https://get.docker.com/rootless | sh
        export PATH=$HOME/bin:$PATH

        echo "[+] Docker rootless installed."
    else
        echo "[+] Docker detected"

        # Check if Docker is rootless
        DOCKER_ROOTLESS=$(docker info --format '{{.SecurityOptions}}' | grep rootless || true)
        if [ -z "$DOCKER_ROOTLESS" ]; then
            echo "[*] Docker found but not rootless. Skipping rootless installation for local setup."
        else
            echo "[+] Docker is already rootless."
        fi
    fi
fi

# -------------------------
# 2. Verify Docker works
# -------------------------
docker info

# -------------------------
# 3. Build SSHoney Docker image
# -------------------------
echo "[*] Building SSHoney Docker image..."
docker build -t ssh-honeypot-image "$INSTALL_DIR"

# -------------------------
# 4. Create session logs folder
# -------------------------
mkdir -p "$INSTALL_DIR/session-logs"
echo "[+] Session logs folder created at $INSTALL_DIR/session-logs"

# -------------------------
# 5. Create systemd service
# -------------------------
echo "[*] Creating systemd service file..."
sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=SSHoney Ephemeral SSH Honeypot
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=$USER_NAME
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 $INSTALL_DIR/sshoney_service.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# -------------------------
# 6. Enable and start service
# -------------------------
echo "[*] Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "[*] Enabling SSHoney service..."
sudo systemctl enable sshoney

echo "[*] Starting SSHoney service..."
sudo systemctl start sshoney

echo "[+] SSHoney installed and running!"
echo "[+] Logs will be stored in $INSTALL_DIR/session-logs"
echo "[+] Service listens on port 2222"
