#!/usr/bin/env python3
import json, os, urllib.request, subprocess, urllib.error

src = "/var/lib/pmacct/ports.json"
endpoint = "https://report.opsec.wang"
token = os.environ.get("netopsec_token", "changeTokenHere")

out = subprocess.run(["ss", "-tulnpH"], capture_output=True, text=True).stdout
usedPorts = []
for line in out.splitlines():
    f = line.split()
    proto, local = f[0], f[4]
    usedPorts.append(int(local.rsplit(":", 1)[1]))

alreadySend = []
with open(src) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            line = json.loads(line)
            if line['ip_src'] in alreadySend: continue
            if line['port_dst'] in usedPorts: continue
            if line['ip_proto'] == "icmp": continue
            req = urllib.request.Request(endpoint,data=json.dumps(line).encode(),
            headers={"Content-Type": "application/json","Authorization": f"Bearer {token}"},method="POST",)
            urllib.request.urlopen(req, timeout=15).close()
            alreadySend.append(line['ip_src'])
        except (ValueError, urllib.error.URLError) as e:
            print(f"Failed to report {line!r}: {e}")