#!/bin/bash
echo -e "

by

    MASTER-HACK


    "
# Function to check the operating system
check_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
    else
        OS=$(uname -s)
    fi
    echo $OS
}

# Check the operating system
OS=$(check_os)

# Run the appropriate script based on the operating system
case $OS in
    kali)
        echo "Running script for Kali Linux..."
        sudo ./kali_script.sh
        ;;
    ubuntu)
        echo "Running script for Ubuntu..."
        sudo ./ubuntu_script.sh
        ;;
    termux)
        echo "Running script for Termux..."
        sudo ./termux_script.sh
        ;;
    *)
        echo "Unsupported operating system."
        exit 1
        ;;
esac
