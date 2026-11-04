#!/bin/bash
set -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
apt-get install pmacct -y
cd /etc/pmacct/
mv pmacctd.conf pmacctd.conf.bak
wget https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/pmacctd.conf 
echo "3e85e5ca687eaaae7f865e107d53a8b5bd62d9f427af95693823f23fed84988c  pmacctd.conf" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
cd /usr/local/bin/
wget https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/netopsec.py
echo "f36908a0186c9afcf3f2a74ab64ba139bb8231a9cb96aaf9d4761200d1c9324b  netopsec.py" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
chmod +x netopsec.py
systemctl restart pmacctd
cd