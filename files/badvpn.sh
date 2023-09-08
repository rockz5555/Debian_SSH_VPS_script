#!/bin/bash

# Define the installation path
INSTALL_PATH="/opt/badvpn"

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Install dependencies
apt-get update
apt-get install -y pkg-config libssl-dev libnspr4-dev libnss3-dev git build-essential cmake

# Clone BadVPN from GitHub
git clone https://github.com/ambrop72/badvpn.git "$INSTALL_PATH"
cd "$INSTALL_PATH"

# Build and install BadVPN
mkdir build
cd build
cmake ..
make
make install

# Create a symlink to the badvpn-tun2socks binary in /usr/local/bin
ln -s "$INSTALL_PATH/build/badvpn-tun2socks" /usr/local/bin/badvpn-tun2socks

# Create a systemd service unit file for BadVPN
cat <<EOF > /etc/systemd/system/badvpn.service
[Unit]
Description=BadVPN TUN2SOCKS service
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_PATH/build/badvpn-tun2socks
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable the BadVPN service to start at boot and start it
systemctl enable badvpn.service
systemctl start badvpn.service

clear

echo "BadVPN has been installed to $INSTALL_PATH and set up to run at boot."
echo "You can start it manually using: $INSTALL_PATH/build/badvpn-tun2socks"
