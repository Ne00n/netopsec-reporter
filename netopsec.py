#!/usr/bin/env python3
import json, os, urllib.request, urllib.error

src = "/var/lib/pmacct/ports.json"
endpoint = "https://report.opsec.wang"
token = os.environ.get("netopsec_token", "changeTokenHere")

with open(src) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            req = urllib.request.Request(endpoint,data=json.dumps(json.loads(line)).encode(),
            headers={"Content-Type": "application/json","Authorization": f"Bearer {token}"},method="POST",)
            urllib.request.urlopen(req, timeout=15).close()
        except (ValueError, urllib.error.URLError) as e:
            print(f"Failed to report {line!r}: {e}")