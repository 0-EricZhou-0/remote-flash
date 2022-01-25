#!/bin/bash

architectures=("x86_64" "aarch64")
echo -n "Enter architecture of target system, available options are: "
for architecture in "${architectures[@]}"; do
  echo -n "$architecture "
done
echo
read -r architecture

case "$architecture" in
  x86_64)
    echo "AMD"
    echo "NOT supported for now, hopefully someday someone could do an experiment with those devices."
    exit 1
    ;;
  aarch64)
    echo "ARM"
    ;;
  *)
    echo "NOT supported architecture"
    exit 1
    ;;
esac

while :; do
  read -rp "Enter position to download: " target_dir
  if [[ ! -d $target_dir ]]; then
    echo "Target folder does not exist, try again"
  else
    break
  fi 
done

case "$architecture" in
  x86_64)
    echo "NOT supported for now, hopefully someday someone could do an experiment with those devices."
    exit 1
    ;;
  aarch64)
    wget -P "$target_dir" http://ports.ubuntu.com/pool/main/n/network-manager/network-manager_1.22.10-1ubuntu1_arm64.deb
    wget -P "$target_dir" http://ports.ubuntu.com/pool/main/b/bluez/libbluetooth3_5.53-0ubuntu3_arm64.deb
    wget -P "$target_dir" http://ports.ubuntu.com/pool/main/j/jansson/libjansson4_2.12-1build1_arm64.deb
    wget -P "$target_dir" http://ports.ubuntu.com/pool/main/m/modemmanager/libmm-glib0_1.12.8-1_arm64.deb
    wget -P "$target_dir" http://ports.ubuntu.com/pool/main/libn/libndp/libndp0_1.7-0ubuntu1_arm64.deb
    wget -P "$target_dir" http://ports.ubuntu.com/pool/main/n/network-manager/libnm0_1.22.10-1ubuntu1_arm64.deb
    wget -P "$target_dir" http://ports.ubuntu.com/pool/main/libt/libteam/libteamdctl0_1.30-1_arm64.deb
    ;;
  *)
    echo "NOT supported architecture"
    exit 1
    ;;
esac
