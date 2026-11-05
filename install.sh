#!/bin/bash
set -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
apt-get install pmacct -y
cd /etc/pmacct/
mv pmacctd.conf pmacctd.conf.bak
wget https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/pmacctd.conf 
echo "9e01ca52fb0f7acf667ff50a61ee591e59b68600864ba9efa2f5eac1a7af03bc  pmacctd.conf" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
iface=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
sed -i "s/changeInterfaceHere/$iface/g" pmacctd.conf 
cd /usr/local/bin/
wget https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/netopsec.py
echo "16470f706f6db7d58c82111b832c1dcab865b44705eabceeac5c0bd7b6c0e12f  netopsec.py" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
sed -i "s/changeTokenHere/$1/g" netopsec.py 
chmod +x netopsec.py
systemctl restart pmacctd
cd