#!/bin/bash

# get the ips to scan
ips=$(ip a | grep "inet " | grep -oE "[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}/[0-9]+")

# find out if a desired target exists
tmpfile=$(mktemp temp.XXXXXX)
while IFS=: read -r ip_entry; do 
  if [[ ! "$ip_entry" =~ 127.0.0.1* ]]; then
    sudo nmap -sn "$ip_entry" -oX "$tmpfile" &> /dev/null
    python3 xml_process.py "$tmpfile" known_hosts
  fi
done <<< "$ips"
rm -f "$tmpfile"

