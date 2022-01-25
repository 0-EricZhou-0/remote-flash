#!/bin/bash
sudo dpkg -i ./*

nmcli device wifi rescan
nmcli device wifi list
read -rp "SSID: " ssid
read -rp "passeord: " pwd
nmcli device wifi connect "$ssid" password "$pwd"
