#!/bin/bash

# Function to generate a random MAC address
generate_mac() {
    echo "$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')"
}

# Function to generate a random IP address
generate_ip() {
    echo "$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1).$(shuf -i 1-254 -n 1)"
}

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Get the current MAC address
CURRENT_MAC=$(ip link show dev wlan0 | awk '/ether/ {print $2}')

# Generate a new random MAC address
NEW_MAC=$(generate_mac)

# Change the MAC address
ip link set dev wlan0 down
ip link set dev wlan0 address $NEW_MAC
ip link set dev wlan0 up

# Verify the new MAC address
NEW_MAC_VERIFY=$(ip link show dev wlan0 | awk '/ether/ {print $2}')

if [ "$NEW_MAC_VERIFY" == "$NEW_MAC" ]; then
    echo "MAC address changed from $CURRENT_MAC to $NEW_MAC"
else
    echo "MAC address change failed."
    exit 1
fi

# Get the current IP address
CURRENT_IP=$(ip addr show dev wlan0 | awk '/inet / {print $2}' | cut -d/ -f1)

# Generate a new random IP address
NEW_IP=$(generate_ip)

# Change the IP address
ip addr flush dev wlan0
ip addr add $NEW_IP/24 dev wlan0

# Verify the new IP address
NEW_IP_VERIFY=$(ip addr show dev wlan0 | awk '/inet / {print $2}' | cut -d/ -f1)

if [ "$NEW_IP_VERIFY" == "$NEW_IP" ]; then
    echo "IP address changed from $CURRENT_IP to $NEW_IP"
else
    echo "IP address change failed."
    exit 1
fi

# Make the system fully anonymous
echo "Setting up fully anonymous mode..."

# Disable IPv6
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1

# Disable logging
sysctl -w net.ipv4.conf.all.log_martians=0
sysctl -w net.ipv4.conf.default.log_martians=0

# Disable responding to ping requests
sysctl -w net.ipv4.icmp_echo_ignore_all=1

# Disable source routing
sysctl -w net.ipv4.conf.all.accept_source_route=0
sysctl -w net.ipv4.conf.default.accept_source_route=0

# Disable redirects
sysctl -w net.ipv4.conf.all.accept_redirects=0
sysctl -w net.ipv4.conf.default.accept_redirects=0

# Disable secure redirects
sysctl -w net.ipv4.conf.all.secure_redirects=0
sysctl -w net.ipv4.conf.default.secure_redirects=0

echo "Fully anonymous mode enabled."
