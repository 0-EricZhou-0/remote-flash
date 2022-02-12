#!/bin/bash

# finding an address to ping in source.list of apt
file="/etc/apt/sources.list"
while IFS=: read -r line; do
  if [[ "$line" =~ ^[^\#].*http ]]; then 
    # not really a good way to parse urls, but I cannot think
    # of any other methods :(
    IFS=" " read -r -a temp <<< "$line"
    IFS="/" read -r -a temp <<< "${temp[1]}"
    test_url="${temp[2]}"
    break
  fi
done < $file

echo "Testing on $test_url"

# test condition by pinging a url in source.list of apt
test_connection() {
  # only once in 10 times would be sufficient to say
  # we have a connection ;)
  ((count = 10))
  while [[ $count -ne 0 ]] ; do
    ping -c 1 "$test_url"
    if ! $? ; then
      return 0
    else
      ((count = count - 1))
      sleep 1
    fi
  done
  return 1
}

# turn on wifi
nmcli radio wifi on
prompt=1;
while :; do
  # if test succeed, then we have internet connection
  if test_connection; then
    break
  fi
  clear
  # large prompt only show once
  if [[ prompt -eq 1 ]]; then
    echo "Internet not usable, wifi networks will be listed."
    echo "After read through the list, press <q> to continue."
    echo "Then you will be prompted for SSID and password"
    read -rp "Continue... <Enter>"
    (( prompt = 0 ))
  else
    read -rp "Try again... <Enter>"
  fi
  # list all wifi and prompt user for ssid and password
  nmcli device wifi rescan
  nmcli device wifi list
  read -rp "SSID: " ssid
  read -rp "password: " pwd
  # try to connect to that wifi
  nmcli device wifi connect "$ssid" password "$pwd"
done

echo "Internet connection established."

