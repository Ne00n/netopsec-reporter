#!/bin/bash
set -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
apt-get install pmacct -y
cd /etc/pmacct/
mv pmacctd.conf pmacctd.conf.bak
wget https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/pmacctd.conf 
echo "2804c8b3182f55681f03089573bc08f95ad6a71a65bb6150e27a2312afe423f4  pmacctd.conf" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
iface=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
sed -i "s/changeInterfaceHere/$iface/g" pmacctd.conf 
cd /usr/local/bin/
wget https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/netopsec.py
echo "6e3d445becaa5cfa0b2317bbd8fb2f4c20c307031ec6c6344b671057405a43a2  netopsec.py" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
sed -i "s/changeTokenHere/$1/g" netopsec.py 
chmod +x netopsec.py
systemctl restart pmacctd
cd