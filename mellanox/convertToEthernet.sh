#!/usr/bin/env bash

header_info() {
  clear
  cat <<"EOF"

 █████ █████  █████  █████████  █████
░███░ ░░███  ░░███  ███░░░░░███░░░███
░███   ░███   ░███ ░███    ░░░   ░███
░███   ░███   ░███ ░░█████████   ░███
░███   ░███   ░███  ░░░░░░░░███  ░███
░███   ░███   ░███  ███    ░███  ░███
░█████ ░░████████  ░░█████████  █████
░░░░░   ░░░░░░░░    ░░░░░░░░░  ░░░░░ 

EOF
}

# Function to echo and execute commands within the same line of code. To reduce line count and maintain readability. 
run_cmd() {
    echo "$@"
    eval "$@"
}

echo "This helper script is for converting the Mellanox CX-3 network card from the default Infiniband to Ethernet mode."
echo "This script assumes that you are running this on Proxmox VE version 8 or newer."

# Create a temporary directory for the script.
run_cmd mkdir temp
run_cmd cd temp

# Install needed packages.
run_cmd "apt update && apt install \
  gcc \
  make \
  dkms \
  proxmox-headers-$(uname -r)"

#Download the 4.22.1-417-LTS - Linux - DEB - x64 firmware tools
run_cmd wget https://www.mellanox.com/downloads/MFT/mft-4.22.1-417-x86_64-deb.tgz

#Extract the file and cd to directory
run_cmd tar -xvzf ./mft-4.22.1-417-x86_64-deb.tgz
run_cmd cd mft-4.22.1-417-x86_64-deb.tgz

# Make the install script executable and run it.
run_cmd chmod +x ./install.sh
run_cmd ./install.sh

# Start the mst service
run_cmd mst start

# Check for the status of mst. Can the system see the card? 
# This will need to be tweaked later to have the system know that it's there vs. needing the user to visually check the output.
run_cmd mst status

# Set the values to switch the cards from type 1 to type 2 (aka ethernet mode).
run_cmd mlxconfig -d /dev/mst/mt4099_pciconf0 set LINK_TYPE_P1=2 LINK_TYPE_P2=2

# Check for success and ask the user to reboot the system.
echo "The script has successfully completed. Would you like to reboot now? "
