#!/bin/bash
set -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
apt-get install pmacct -y
cd /etc/pmacct/
mv pmacctd.conf pmacctd.conf.bak
wget -O /etc/pmacct/pmacctd.conf https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/pmacctd.conf 
echo "17dff56dc6375fa41213f67329044b2d8c4e55b84897369e1729ddbf3c721ac6  pmacctd.conf" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
iface=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
sed -i "s/changeInterfaceHere/$iface/g" pmacctd.conf 
cd /usr/local/bin/
wget -O /usr/local/bin/netopsec.py https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/netopsec.py
echo "99d830a4b9963ae5e6470704d981464a8934f3eab9d4176c93a43b27be3bd42c  netopsec.py" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
sed -i "s/changeTokenHere/$1/g" netopsec.py 
chmod +x netopsec.py
systemctl restart pmacctd
cd