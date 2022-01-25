#!/bin/bash
#shellcheck source=/dev/null
source ./utils.sh

# confirm script is run as root, root have EUID 0
if [[ $EUID == 0 ]]; then 
  echo "Script $(basename "$0") shuold not be run as root, please try again."
  exit 1
fi

sudo -k
read -rsp "Password: " password
if ! echo "$password" | sudo -S true &> /dev/null; then
  exit 1
fi
echo "√"

read -rp "Start installation in this folder? (y/N): " confirm 
if [[ $confirm != [yY] ]]; then
  echo "Aborting..."
  sudo -k
  exit 1
fi
# getting current directory
setup_root_dir=$(pwd)

# start script
echo "Setup start"

# list of all required packages 
bash_req_pkgs=("make" "cmake" "git" "libusb-1.0-0" "libusb-1.0-0-dev" "openocd" "python3" "python3-pip")
# if package does not exist, install it
for pkg in "${bash_req_pkgs[@]}"; do
  while ! echo "$password" | sudo -S apt-get -qq install "$pkg"; do
    : # do nothing
  done
done
echo "Required packages installed"

# list of all required python packages (not useful for now)
python_req_pkgs=("requests" "json")
# if package does not exist, install it
for pkg in "${python_req_pkgs[@]}"; do
  while ! echo -e "try: import $pkg\nexcept ImportError: exit(1)" | python3; do
    pip install "$pkg"
  done
done
echo "Required python packages installed"

# build stlink from source
if ! command -v st-info &> /dev/null; then
  cd "$setup_root_dir" || cd_error "$setup_root_dir" "$(basename "$0")" "$LINENO"
  # stlink tar and folder names
  stlink_tar_name=v1.6.1.tar.gz
  stlink_folder_name=stlink-1.6.1
  # make sure no perious created folders are destroyed, so find an
  # available name. Installing v1.6.1 because stlink v1.7.0 are not
  # usable by now
  if [[ -d $stlink_folder_name ]]; then
    echo "Folder $stlink_folder_name already exists, delete it to continue."
    sudo -k
    exit 1
  fi
  # remove possible downloaded file and download again
  rm -f "$stlink_tar_name"
  wget https://github.com/stlink-org/stlink/archive/refs/tags/v1.6.1.tar.gz -O "$stlink_tar_name"
  # unzip to folder
  mkdir "$stlink_folder_name"
  tar -xvf "$stlink_tar_name" -C "$stlink_folder_name" --strip-components 1
  cd "$stlink_folder_name" || cd_error "$stlink_folder_name" "$(basename "$0")" "$LINENO"
  echo "$password" | sudo -S make clean
  echo "$password" | sudo -S make install
  echo "$password" | sudo -S ldconfig
fi
echo "Stlink installed"

# setup arm-embedded toolchain
if ! command -v arm-none-eabi-gcc &> /dev/null; then
  cd "$setup_root_dir" || cd_error "$setup_root_dir" "$(basename "$0")" "$LINENO"
  # arm toolchain tar and folder names
  arm_toolchain_tar_name=gcc-arm-none-eabi-10.3-2021.10.tar.bz2
  arm_toolchain_folder_name=gcc-arm-none-eabi-10.3-2021.10
  # check if folder exists
  if [[ -d $arm_toolchain_folder_name ]]; then
    echo "Folder $arm_toolchain_folder_name already exists, delete it to continue."
    sudo -k
    exit 1
  fi
  rm -f "$arm_toolchain_tar_name"
  # different cpu architecture have different toolchain versions
  case $(uname -m) in
    x86_64)
      wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2 -O "$arm_toolchain_tar_name"
      ;;
    aarch64)
      wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-aarch64-linux.tar.bz2 -O "$arm_toolchain_tar_name"
      ;;
    *)
      echo "NOT supported architecture"
      exit 1
      ;;
  esac
  # unzip to folder
  mkdir "$arm_toolchain_folder_name"
  tar -xvf "$arm_toolchain_tar_name" -C "$arm_toolchain_folder_name" --strip-components 1
  cd "$arm_toolchain_folder_name" || cd_error "$arm_toolchain_folder_name" "$(basename "$0")" "$LINENO"
  # add to path
  echo "export PATH=$setup_root_dir/gcc-arm-none-eabi-10.3-2021.10/bin:\$PATH" >> ~/.bashrc
  source ~/.bashrc
fi
echo "Arm toolchain installed"

echo "Setup complete"

# stopping sudo session
sudo -k
