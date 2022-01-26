#!/bin/bash

# download all dependencies of nmcli which configures networking
architectures=("aarch64")
echo -n "Enter architecture of target system, available options are: "
for architecture in "${architectures[@]}"; do
  echo -n "$architecture "
done
echo
read -r target_architecture

# check for vaild architecture
(( match = 1 ))
for architecture in "${architectures[@]}"; do
  if [[ $architecture == "$target_architecture" ]]; then
    (( match = 0 ))
    break
  fi
done
if [[ $match -eq 1 ]]; then
  echo "Not supported architecture"
  exit 1
fi

# specify a destination folder
while :; do
  read -rp "Enter position to place setup files: " target_dir
  if [[ ! -d $target_dir ]]; then
    echo "Target folder does not exist, try again"
  elif find "$target_dir" -mindepth 1 -maxdepth 1 | read -r; then
    echo "Target folder not empty, try again"
  else
    break
  fi 
done

# download file according to architecture
download_directory="$target_dir/resources/dependencies"
mkdir "$download_directory"
case "$target_architecture" in
  x86_64)
    echo "NOT supported for now, hopefully someday someone could do an experiment with those devices."
    exit 1
    ;;
  aarch64)
    wget -P "$download_directory" http://ports.ubuntu.com/pool/main/n/network-manager/network-manager_1.22.10-1ubuntu1_arm64.deb
    wget -P "$download_directory" http://ports.ubuntu.com/pool/main/b/bluez/libbluetooth3_5.53-0ubuntu3_arm64.deb
    wget -P "$download_directory" http://ports.ubuntu.com/pool/main/j/jansson/libjansson4_2.12-1build1_arm64.deb
    wget -P "$download_directory" http://ports.ubuntu.com/pool/main/m/modemmanager/libmm-glib0_1.12.8-1_arm64.deb
    wget -P "$download_directory" http://ports.ubuntu.com/pool/main/libn/libndp/libndp0_1.7-0ubuntu1_arm64.deb
    wget -P "$download_directory" http://ports.ubuntu.com/pool/main/n/network-manager/libnm0_1.22.10-1ubuntu1_arm64.deb
    wget -P "$download_directory" http://ports.ubuntu.com/pool/main/libt/libteam/libteamdctl0_1.30-1_arm64.deb
    ;;
  *)
    echo "NOT supported architecture"
    exit 1
    ;;
esac

# copy all resources over to target directory
cp -r ./resources "$target_dir"
mv "$target_dir/resources/setup.sh" "$target_dir/"
