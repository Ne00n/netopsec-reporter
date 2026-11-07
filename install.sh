#!/bin/bash
set -e
if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 1 ; fi
apt-get install pmacct -y
cd /etc/pmacct/
mv pmacctd.conf pmacctd.conf.bak
wget -O /etc/pmacct/pmacctd.conf https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/pmacctd.conf 
echo "46b67fbb0602acdd6e0515f5a4b0ee45903462e370b00633f0e67cdfbdfd5a78  pmacctd.conf" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
iface=$(ip route get 1.1.1.1 | awk '{for(i=1;i<=NF;i++) if($i=="dev") {print $(i+1); exit}}')
sed -i "s/changeInterfaceHere/$iface/g" pmacctd.conf 
cd /usr/local/bin/
wget -O /usr/local/bin/netopsec.py https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/netopsec.py
echo "6dbe71a022d5862522623c6a13aa482383d2040590943ab95f5cd156d23957fc  netopsec.py" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
sed -i "s/changeTokenHere/$1/g" netopsec.py 
chmod +x netopsec.py
#drop permissions for pmacctd
getent group pmacct >/dev/null || groupadd -r pmacct
id pmacct >/dev/null 2>&1 || useradd -r -g pmacct -M -d /var/lib/pmacct -s /usr/sbin/nologin pmacct
chown -R pmacct:pmacct /var/lib/pmacct/
wget -O /etc/systemd/system/pmacctd.service https://raw.githubusercontent.com/Ne00n/netopsec-reporter/refs/heads/master/pmacctd.service
echo "1b2ccf400228701763246f31a0d1130bd0d73d244b52065b2bb94ce46fa0c35d  /etc/systemd/system/pmacctd.service" | sha256sum -c --status - || { echo "Checksum mismatch, aborting." >&2; exit 1; }
systemctl stop pmacctd
systemctl daemon-reload
systemctl start pmacctd
cd