#!/usr/bin/env python3
import ipaddress, json, os, re, urllib.request, subprocess, urllib.error

#setup
src = "/var/lib/pmacct/ports.json"
endpoint = "https://report.opsec.wang"
token = os.environ.get("netopsec_token", "changeTokenHere")
#pull interface
with open("/etc/pmacct/pmacctd.conf", 'r') as file: pmacct = file.read()
interface = re.findall(f"pcap_interface: (.*)\n",pmacct, re.MULTILINE)[0].rstrip()
interfaceRaw = subprocess.run(["ip", "-j", "addr", "show", interface], capture_output=True, text=True).stdout
interfaceJson = json.loads(interfaceRaw)[0]
#define local addresses
source = []
for row in interfaceJson['addr_info']:
    if row['scope'] == "global": source.append(row['local'])

out = subprocess.run(["ss", "-tulnpH"], capture_output=True, text=True).stdout
monitorPorts = [21,22,23,25,80,161,443,445,1433,2323,2375,3306,3389,5060,5432,5900,6379,8080,8443,9200,27017]
usedPorts = []
for line in out.splitlines():
    f = line.split()
    proto, local = f[0], f[4]
    usedPorts.append(int(local.rsplit(":", 1)[1]))

alreadyReported, whitelist, toReport = [], [], []
with open(src) as f:
    for line in f:
        line = line.strip()
        if not line: continue
        line = json.loads(line)
        #when we talk to someone aka we are the source, we whitelist the destination ip address, to avoid false bans
        if line['ip_src'] in source:
            whitelist.append(line['ip_dst'])
            continue
        #if a service is using the port we wanna monitor, ignore it
        if line['port_dst'] in usedPorts: continue
        #if the port isn't in monitoredPorts, ignore it
        if not line['port_dst'] in monitorPorts: continue
        #filter by source/subnet to avoid getting rate limited
        ip = ipaddress.ip_address(line['ip_src'])
        prefix = 24 if ip.version == 4 else 48
        subnet = ipaddress.ip_network(f"{ip}/{prefix}", strict=False)
        #if we already reported anything in this subnet, ignore it
        if str(subnet) in alreadyReported: continue
        #report
        toReport.append(line)
        alreadyReported.append(subnet)

for report in toReport:
    try:
        #if we talked to the ip/source before, skip it
        if report['ip_src'] in whitelist: continue
        print(report)
        req = urllib.request.Request(endpoint,data=json.dumps(report).encode(),
        headers={"Content-Type": "application/json","Authorization": f"Bearer {token}"},method="POST",)
        urllib.request.urlopen(req, timeout=15).close()
    except (ValueError, urllib.error.URLError) as e:
        print(f"Failed to report {line!r}: {e}")