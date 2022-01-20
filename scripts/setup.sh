read -p "Start installation in this folder? (y/N): " confirm 
if [[ $confirm != [yY] ]]; then
  echo "Aborting..."
  exit 1
fi

# starting sudo session
sudo echo "Setup start"

# list of all required packages 
bash_req_pkgs=("make" "cmake" "git" "libusb-1.0-0" "libusb-1.0-0-dev" "openocd" "python3" "python3-pip")
# if package does not exist, install it
for pkg in ${bash_req_pkgs[@]}; do
  while ! sudo apt-get -qq install $pkg; do
    : # do nothing
  done
done
echo "Required packages installed"

# list of all required python packages
#not useful for now
python_req_pkgs=("requests" "json")
# if package does not exist, install it
for pkg in ${python_req_pkgs[@]}; do
  while ! echo -e "try: import $pkg\nexcept ImportError: exit(1)" | python3; do
    pip install $pkg
  done
done
echo "Required python packages installed"

current_dir=$(pwd)

# build stlink from source
if ! command -v st-info &> /dev/null; then
  cd $current_dir
  # make sure no perious created folders are destroyed, so find an
  # available name. Installing v1.6.1 because stlink v1.7.0 are not
  # usable by now
  if [ -d stlink-1.6.1 ]; then
    suffix=0
    test_dir="stlink-1.6.1-$suffix"
    while [ -d $test_dir ]; do
      suffix=$((suffix + 1))
      test_dir="stlink-1.6.1-$suffix"
    done
  fi
  rm -f v1.6.1.tar.gz
  wget https://github.com/stlink-org/stlink/archive/refs/tags/v1.6.1.tar.gz
  mkdir "stlink-1.6.1-$suffix"
  tar -xvf v1.6.1.tar.gz -C "stlink-1.6.1-$suffix" --strip-components 1
  cd "stlink-1.6.1-$suffix"
  sudo make clean
  sudo make install
  sudo ldconfig
fi
echo "Stlink installed"

# install arm-embedded toolchain
if ! grep -q "gcc-arm-none-eabi-10.3-2021.10/bin" ~/.bashrc; then
  cd $current_dir
  # different cpu architecture have different toolchain versions
  cpu_architecture=$(uname -m)
  case $cpu_architecture in
    x86_64)
      wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
      tar -xvf gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
      ;;
    aarch64)
      wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-aarch64-linux.tar.bz2
      tar -xvf gcc-arm-none-eabi-10.3-2021.10-aarch64-linux.tar.bz2
      ;;
    *)
      echo "NOT supported architecture"
      exit 1
      ;;
  esac
  # add to path
  echo "export PATH=~/stm32/gcc-arm-none-eabi-10.3-2021.10/bin:\$PATH" >> ~/.bashrc
  source ~/.bashrc
fi
echo "Arm toolchain installed"

echo "Setup complete"
# stopping sudo session
# stopsudo
