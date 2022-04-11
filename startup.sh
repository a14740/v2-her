#!/bin/sh

cat << EOF > /etc/xray/config.json
{
    "policy": {
        "levels": {
            "0": {
                "handshake": 5,
                "connIdle": 300,
                "uplinkOnly": 2,
                "downlinkOnly": 5,
                "statsUserUplink": false,
                "statsUserDownlink": false,
                "bufferSize": 10240
            }
        },
        "system": {
            "statsInboundUplink": false,
            "statsInboundDownlink": false,
            "statsOutboundUplink": false,
            "statsOutboundDownlink": false
        }
    },
    "inbounds": [
        {
            "listen": "0.0.0.0",
            "port": $PORT,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID"
                    }
                ],
                 "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none", 
                "wsSettings": {
                "path": "/hls/cctphd.m3u8"             
                }
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

# Run V2Ray
if [[ $TUNNEL_TOKEN ]]; then
echo 'has tunnel token, run cloudflared tunnel'
/usr/bin/v2ray -config /etc/v2ray/config.json & /root/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN
else
/usr/bin/xray -config /etc/xray/config.json
fi

