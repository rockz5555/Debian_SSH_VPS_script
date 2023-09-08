#!/bin/bash

# Update and upgrade system packages
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y pkg-config libssl-dev libnspr4-dev libnss3-dev

# Create and edit the systemd service file
cat <<EOL | sudo tee /etc/systemd/system/badvpn.service
[Unit]
Description=BadVPN Service
After=network.target

[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 0.0.0.0:7300
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Enable and start the BadVPN service
sudo systemctl enable badvpn.service
sudo systemctl start badvpn.service

echo "BadVPN service is now enabled and started."
