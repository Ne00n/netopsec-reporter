#!/bin/bash
set -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
apt-get install pmacct -y
cd /etc/pmacct/
mv pmacctd.conf pmacctd.conf.bak
wget https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/pmacctd.conf 
echo "e013b38e501dae228aaa782c2630c0337b369699a4d9831660db2360a2c7e3cd  pmacctd.conf" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
iface=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
sed -i "s/changeInterfaceHere/$iface/g" pmacctd.conf 
cd /usr/local/bin/
wget https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/netopsec.py
echo "f36908a0186c9afcf3f2a74ab64ba139bb8231a9cb96aaf9d4761200d1c9324b  netopsec.py" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
chmod +x netopsec.py
systemctl restart pmacctd
cd