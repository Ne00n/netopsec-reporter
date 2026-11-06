#!/usr/bin/env python3
import ipaddress, json, os, urllib.request, subprocess, urllib.error

src = "/var/lib/pmacct/ports.json"
endpoint = "https://report.opsec.wang"
token = os.environ.get("netopsec_token", "changeTokenHere")

out = subprocess.run(["ss", "-tulnpH"], capture_output=True, text=True).stdout
monitorPorts = [21,22,23,25,80,161,445,1433,2323,2375,3306,3389,5060,5432,5900,6379,8080,8443,9200,27017]
usedPorts = []
for line in out.splitlines():
    f = line.split()
    proto, local = f[0], f[4]
    usedPorts.append(int(local.rsplit(":", 1)[1]))

alreadySend = []
with open(src) as f:
    for line in f:
        line = line.strip()
        if not line: continue
        try:
            line = json.loads(line)
            ip = ipaddress.ip_address(line['ip_src'])
            prefix = 24 if ip.version == 4 else 48
            subnet = ipaddress.ip_network(f"{ip}/{prefix}", strict=False)
            if str(subnet) in alreadySend: continue
            if line['port_dst'] in usedPorts: continue
            if not line['port_dst'] in monitorPorts: continue
            req = urllib.request.Request(endpoint,data=json.dumps(line).encode(),
            headers={"Content-Type": "application/json","Authorization": f"Bearer {token}"},method="POST",)
            urllib.request.urlopen(req, timeout=15).close()
            alreadySend.append(subnet)
        except (ValueError, urllib.error.URLError) as e:
            print(f"Failed to report {line!r}: {e}")