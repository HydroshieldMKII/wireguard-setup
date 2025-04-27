#!/bin/bash
# WireGuard Setup Script with Kill Switch
# This script installs WireGuard, resolvconf and add a kill switch to the WireGuard config

# Helper to check if command executed successfully
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1"
        exit 1
    fi
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Install required packages
echo "Installing WireGuard and resolvconf..."
apt update >/dev/null 2>&1
apt install -y wireguard resolvconf >/dev/null 2>&1
check_status "Failed to install required packages"

# Prompt for WireGuard configuration
echo "Setting up WireGuard configuration..."
mkdir -p /etc/wireguard >/dev/null 2>&1
echo "Enter your WireGuard configuration (press Ctrl+D when finished):"
cat > /tmp/wg.conf.tmp
check_status "Failed to create temporary WireGuard configuration"

# Add kill switch to the configuration
echo "Adding kill switch to WireGuard configuration..."
if ! grep -q '\[Interface\]' /tmp/wg.conf.tmp; then
    echo "Error: [Interface] section not found in WireGuard configuration"
    exit 1
fi

# Add kill-switch + local network access (192.168.0.0/24) to the configuration. See link for more details: https://www.ivpn.net/knowledgebase/linux/linux-wireguard-kill-switch/
sed '/\[Interface\]/a PostUp = iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT \&\& ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT \&\& iptables -I OUTPUT -d 192.168.0.0/24 -j ACCEPT \&\& iptables -I INPUT -s 192.168.0.0/24 -j ACCEPT\nPreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT \&\& ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT \&\& iptables -D OUTPUT -d 192.168.0.0/24 -j ACCEPT \&\& iptables -D INPUT -s 192.168.0.0/24 -j ACCEPT' /tmp/wg.conf.tmp > /etc/wireguard/wg.conf
chmod 600 /etc/wireguard/wg.conf >/dev/null 2>&1
check_status "Failed to create WireGuard configuration with kill switch"

# Enable and start the WireGuard service
echo "Enabling and starting WireGuard service..."
systemctl daemon-reload >/dev/null 2>&1
systemctl enable wg-quick@wg >/dev/null 2>&1
systemctl restart wg-quick@wg >/dev/null 2>&1 || echo "Error: Failed to start WireGuard service"
echo "===== Setup complete! ====="
echo "WireGuard with built-in kill switch has been configured."
echo "To check WireGuard connection: sudo wg show"
echo "To check connection status: ping -I wg 8.8.8.8"
echo "To restart the VPN: sudo systemctl restart wg-quick@wg"
# Clean up
rm -f /tmp/wg.conf.tmp >/dev/null 2>&1
exit 0