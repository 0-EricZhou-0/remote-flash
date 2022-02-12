#!/bin/bash

# confirm script is run as root, root have EUID 0
if [[ $EUID == 0 ]]; then 
  echo "Script $(basename "$0") shuold not be run as root, please try again."
  exit 1
fi

sudo -k
# get user password
read -rsp "[sudo] password for $USER: " sudo_password
if ! echo "$sudo_password" | sudo -S true &> /dev/null; then
  exit 1
fi
echo "√"

# try install all *.deb files under /dependencies directory if no nmcli tool
if ! command -v nmcli &> /dev/null; then
  echo "$sudo_password" | sudo -S dpkg --force-depends -i ./dependencies/*.deb
fi

# setup root-hotspot configuration file
# delete previous set REMOTE-FLASH connections
ls -la /etc/NetworkManager/system-connections/*REMOTE_FLASH* &> /dev/null
if ! $?; then
  echo "$sudo_password" | sudo -S nmcli connection reload
  # create a default WIFI for the system to try to access
  echo "$sudo_password" | sudo -S nmcli connection add save yes type wifi con-name REMOTE_FLASH ssid REMOTE_FLASH wifi-sec.key-mgmt WPA-PSK wifi-sec.psk 12345678 autoconnect yes
fi

# output all mac address found, hint user to find entry corresponding to any wlan interface
echo "Identify a MAC address that related to wlan (e.g. wlan0, wlp109s0, etc.) below, then add the mac address to file known_host file on host machine."
tail -n /sys/class/net/*/address

# stopping sudo session
sudo -k

sh resources/network_setup.sh
sh resources/env_setup.sh
