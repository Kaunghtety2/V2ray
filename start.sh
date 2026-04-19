#!/bin/bash

# ============================================================
# VLESS + WebSocket + TLS — Railway Auto-Start Script
# ============================================================

PORT=${PORT:-8080}
WS_PATH=${WS_PATH:-"/vless"}

# UUID: env variable မပါရင် auto-generate လုပ်မယ်
if [ -z "$VLESS_UUID" ]; then
    VLESS_UUID=$(cat /proc/sys/kernel/random/uuid)
    echo "============================================"
    echo "  AUTO-GENERATED UUID (သိမ်းထားပါ!)"
    echo "  UUID: $VLESS_UUID"
    echo "============================================"
else
    echo "============================================"
    echo "  USING ENV UUID: $VLESS_UUID"
    echo "============================================"
fi

echo "  PORT   : $PORT"
echo "  WS PATH: $WS_PATH"
echo "============================================"

# config.json generate လုပ်မယ်
cat > /etc/xray/config.json <<EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log"
  },
  "inbounds": [
    {
      "port": ${PORT},
      "listen": "0.0.0.0",
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${VLESS_UUID}",
            "level": 0,
            "email": "user@vless.local"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "${WS_PATH}",
          "headers": {}
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct",
      "settings": {
        "domainStrategy": "UseIPv4"
      }
    },
    {
      "protocol": "blackhole",
      "tag": "blocked",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": ["geoip:private"],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF

echo "Config generated. Starting Xray..."
exec xray run -c /etc/xray/config.json
