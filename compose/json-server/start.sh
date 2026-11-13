#!/bin/sh
set -eu
if [ ! -f /data/db.json ]; then cp /app/initial-db.json /data/db.json; fi
exec json-server --watch /data/db.json --host 0.0.0.0 --port 3000
