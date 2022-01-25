# Remote flash

## Introduction

This repo have scripts that intends to construct a wireless server for stm32 devices.

## How to use these scripts

### Prerequisite

- A little computer (usually single boarded computer) with wireless adapter
  - Make sure the device is with an ARM processor, otherwise you have to search for packages for installing `network-manager` and download them. See `preparation.sh` for more details.
  - When writing this readme, a Raspberry Pi 4B is used
- A screen that can display the output of the SBC
- A fresh Ubuntu Server install (or any other os with bash)
  - Desktop versions can also be used but they generally need more space to set up
  - When writing this readme, Ubuntu Server 20.04 LTS is used
- A USB drive
  - Capacity should be at least 4MB (may subject to change)
- Host computer have access to internet
- A regular WIFI that does not require a login page
  - Desktop version can do this but is not suggested
  - A mobile hot-spot from host computer is enough

### Setup

1. run `preparation.sh` under `/scripts` folder of this repo. Now only ARM processors are supported (I am too lazy to include x86-64 ones).

    - The script should prompt you to enter the position to place the setup files, copy the path to your USB drive (or one folder inside it) and paste in the command line. The script will search for packages that contains tools to let us connect to internet through WIFI in command line and download them to your USB drive.

2. After everything is downloaded, two scripts will also be copied over to the specified folder in the last step, `env_setup.sh` and `network_setup.sh`. Unplug the USB drive from your host computer, and plug into the SBC.

3. After login on SBC, first mount the USB drive through the command line using `mount`. Upon successful connection, USB device will appear in `/dev` folder.

    - USB devices usually have name `sdX#` where X is a single character and # is a number. For example, `/dev/sda1` is the most common name for that USB drive after a fresh installation.
    - After finding that device, use `sudo mount <device> <mount-point>` to mount the device onto one folder on your local filesystem. E.g. `sudo mount /dev/sda1 /mnt`.

4. Now you have successfully mounted the USB, you could see all the files that copied into it on the host computer. `cd` into your chosen mount point, first execute `network_setup.sh` to setup network connection.

    - The script will install the `.deb` files downloaded on the host machine, and after that, it would prompt you to connect to a network. It will list all the wireless network it can find and ask you to input the desired SSID and password of a network for it to connect.
    - It will try to ping ubuntu apt repo found in your `/etc/apt/sources.list` and ask you to put in credentials until a successful connection is made.

5. With internet connection established, find or create a folder you want to place all dependency in. `cd` into that folder and run `env_setup.sh` to install necessary packages, repositories and tools.

    - Copy this script over could be done using command `cp ./env_setup.sh <destination-folder>` in the directory where `env_setup.sh` resides. `destination-folder` should be a location on local file system.
    - After copy the `env_setup.sh` over, you can unmount the USB drive using command `sudo umount <mount-point>` and remove the drive from USB port.

### Debugging Through WIFI

- TODO

## Known issues

- When connecting to network, it depends on the type of SBC you have, some may not sense and connect to 5GHz WIFIs, make host/router operate on 2.4GHz instead.
- If any of the script fails, just run it again. Almost all the fail cases are handled.
