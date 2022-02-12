import xml.etree.ElementTree as ET
import sys, re

# sys.argv[0] XML file to be parsed
# sys.argv[1] known-host
root = ET.parse(sys.argv[1]).getroot()

# gather all possible targets
targets = {}
with open(sys.argv[2]) as file:
    for line in file:
        info = line.strip().split()
        if len(info) != 3:
            print(f"WARNING: Corrupted known_hosts, cannot resolve <{info}> for a MAC address follow by a user name, follow by a password, skipping entry", file=sys.stderr)
            continue
        mac = info[0]
        user = info[1]
        password = info[2]
        if re.search("^([0-9A-F]{2}:){5}[0-9A-F]{2}$", mac):
            targets[mac] = (user, password)
        else:
            print(f"WARNING: Corrupted known_hosts, cannot resolve <{mac}> for a MAC address, skipping entry", file=sys.stderr)
            continue

# gather all possible ips for corresponding mac address
possible_ip = []
for item in root.findall("host"):
    addresses = item.findall("address")
    if (len(addresses) < 2):
        continue
    addresses = [addr.get("addr") for addr in addresses]
    ip = addresses[0]
    mac = addresses[1].upper()
    if mac in targets:
        possible_ip.append((mac, targets[mac], ip))

# TODO: modify this
print(possible_ip)
