# WireGuard Setup Script with Kill Switch

## Overview

This script automates the installation and configuration of WireGuard VPN with an integrated kill switch on Debian-based Linux systems. The kill switch prevents traffic leakage by blocking all non-VPN connections if the VPN disconnects unexpectedly, ensuring your privacy and security.

## Features

- Automatically installs WireGuard, resolvconf, and UFW (Uncomplicated Firewall)
- Configures WireGuard with your provided configuration
- Implements a robust kill switch that blocks all non-VPN traffic if the VPN disconnects
- Preserves local network access (192.168.0.0/24)

## Requirements

- Debian-based Linux distribution (Ubuntu, Debian, etc.)
- Root privileges
- A valid WireGuard configuration from your VPN provider

## Installation

1. Download the script:
   ```bash 
    curl https://raw.githubusercontent.com/HydroshieldMKII/wireguard-setup/main/wireguard-setup.sh -o wireguard-setup.sh
   ```

2. Make the script executable:
   ```bash
   chmod +x wireguard-setup.sh
   ```

3. Run the script with root privileges:
   ```bash
   sudo ./wireguard-setup.sh
   ```

4. When prompted, paste your WireGuard configuration. After pasting, press Ctrl+D to finish.

5. The script will add the kill switch configuration and start the WireGuard service.

## How the Kill Switch Works

The kill switch uses iptables rules to:
1. Block all outgoing traffic that isn't routed through the WireGuard interface
2. Allow local network access (192.168.0.0/24)
3. Automatically clean up the rules when WireGuard is properly shut down

This prevents your real IP address from being exposed if the VPN connection drops unexpectedly.

## Usage

After installation, you can use the following commands:

- Check WireGuard connection status:
  ```bash
  sudo wg show
  ```

- Test the connection:
  ```bash
  ping -I wg 8.8.8.8
  ```

- Restart the VPN service:
  ```bash
  sudo systemctl restart wg-quick@wg
  ```

- Start or stop the VPN (including kill switch):
  ```bash
  sudo systemctl start wg-quick@wg
  sudo systemctl stop wg-quick@wg
  ```

## Customization

- Edit the `/etc/wireguard/wg.conf` file to modify your WireGuard configuration
- If your local network is not 192.168.0.0/24, modify the appropriate lines in the configuration

## Disclaimer

This script is provided as-is with no warranty. Use at your own risk.
