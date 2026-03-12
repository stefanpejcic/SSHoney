#!/bin/bash
# SSHoney Installer Script
# Sets up ephemeral SSH honeypot service

# Configuration
USER_NAME="$USER" # rootless user
INSTALL_DIR="$(pwd)"
SERVICE_FILE="/etc/systemd/system/sshoney.service"

# 1. Build Docker image
echo "[*] Building Docker image..."
docker build -t ssh-honeypot-image "$INSTALL_DIR"

# 2. Create session logs folder
echo "[*] Creating session-logs folder..."
mkdir -p "$INSTALL_DIR/session-logs"

# 3. Create systemd service file
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

# 4. Reload systemd, enable and start service
echo "[*] Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "[*] Enabling SSHoney service..."
sudo systemctl enable sshoney

echo "[*] Starting SSHoney service..."
sudo systemctl start sshoney

echo "[+] SSHoney installed and running!"
echo "[+] Logs will be stored in $INSTALL_DIR/session-logs"
echo "[+] Service listens on port 2222"
