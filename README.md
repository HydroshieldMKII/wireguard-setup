# WireGuard Setup Script with Kill Switch

## Overview

Automates WireGuard VPN installation and config, with a kill switch to block all non-VPN traffic if disconnected—while preserving local access (192.168.0.0/24).

## Features

- Installs WireGuard, `resolvconf`, and `iptables`
- Applies your WireGuard config
- Enables kill switch to prevent leaks on VPN drop
- Maintains LAN access

## Requirements

- Debian-based distro (e.g., Ubuntu, Debian)
- Root access
- Valid WireGuard config

## Installation

```bash 
curl -O https://raw.githubusercontent.com/HydroshieldMKII/wireguard-setup/main/wireguard-setup.sh
chmod +x wireguard-setup.sh
sudo ./wireguard-setup.sh
```

Paste your WireGuard config when prompted, then press `Ctrl+D`.

## Kill Switch Details

The script sets iptables rules to:

1. Block non-WireGuard traffic
2. Allow LAN access (`192.168.0.0/24`)
3. Auto-remove rules on VPN shutdown

### Test It

1. Remove VPN IP:
   ```bash
   ip a del 10.2.0.2/32 dev wg
   ```
2. Ping an external IP:
   ```bash
   ping -c 4 1.1.1.1
   ```

To restore the connection:
```bash
sudo systemctl restart wg-quick@wg
```

## Usage

- Check VPN status:
  ```bash
  sudo wg show
  ```

- Test connection:
  ```bash
  ping -I wg 8.8.8.8
  ```

- Check public IP:
  ```bash
  curl ip.me
  ```

- Start/stop VPN:
  ```bash
  sudo wg-quick up wg
  sudo wg-quick down wg
  ```

## Customization

- Modify `/etc/wireguard/wg.conf` for config changes
- Adjust LAN subnet if not `192.168.0.0/24`

## Disclaimer

Use at your own risk. No warranty provided.
