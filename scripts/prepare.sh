#!/bin/bash

architectures=("x86_64" "aarch64")
echo "Select architecture of target system, available options are:"
for architecture in "${architectures[@]}"; do
  echo -n "$architecture  "
done
echo
read -r architecture
case "$architecture" in
  x86_64)
    postfix=amd64
    ;;
  aarch64)
    postfix=arm64
    ;;
  *)
    echo "NOT supported architecture"
    exit 1
    ;;
esac

echo "Enter position to download"
mkdir packages
wget -P ./packages http://ports.ubuntu.com/pool/main/n/network-manager/network-manager_1.22.10-1ubuntu1_"$postfix".deb
wget -P ./packages http://ports.ubuntu.com/pool/main/b/bluez/libbluetooth3_5.53-0ubuntu3_"$postfix".deb
wget -P ./packages http://ports.ubuntu.com/pool/main/j/jansson/libjansson4_2.12-1build1_"$postfix".deb
wget -P ./packages http://ports.ubuntu.com/pool/main/m/modemmanager/libmm-glib0_1.12.8-1_"$postfix".deb
wget -P ./packages http://ports.ubuntu.com/pool/main/libn/libndp/libndp0_1.7-0ubuntu1_"$postfix".deb
wget -P ./packages http://ports.ubuntu.com/pool/main/n/network-manager/libnm0_1.22.10-1ubuntu1_"$postfix".deb
wget -P ./packages http://ports.ubuntu.com/pool/main/libt/libteam/libteamdctl0_1.30-1_"$postfix".deb
