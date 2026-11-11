#!/bin/sh
# Writes the Xray config from environment variables, then starts Xray.
#   UUID     (required) your client id
#   WS_PATH  (optional) secret WebSocket path, e.g. /k3j9x7q2m5  (default /ws)
#   PORT     (set by Render) port to listen on
set -eu
: "${UUID:?Set the UUID environment variable}"
WS_PATH="${WS_PATH:-/ws}"
PORT="${PORT:-10000}"
CONFIG="${CONFIG:-/tmp/config.json}"
cat > "$CONFIG" <<CFG
{
  "log": { "loglevel": "warning" },
  "routing": {
    "rules": [
      { "type": "field",
        "ip": ["127.0.0.0/8","10.0.0.0/8","172.16.0.0/12","192.168.0.0/16","169.254.0.0/16","100.64.0.0/10","::1/128","fc00::/7","fe80::/10"],
        "outboundTag": "block" }
    ]
  },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": { "clients": [ { "id": "${UUID}" } ], "decryption": "none" },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "${WS_PATH}" } }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "block" }
  ]
}
CFG
exec xray run -config "$CONFIG"
