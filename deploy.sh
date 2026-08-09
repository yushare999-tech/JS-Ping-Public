#!/bin/bash
# ==============================================================================
#   JS-Ping Node Deployment Helper Script
#   - Check if config.yaml exists to prevent Docker directory-mount issues.
#   - Generate template config.yaml if missing.
#   - Run docker compose up -d to pull GHCR image and start containers.
# ==============================================================================

# Get current script directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

CONFIG_FILE="config.yaml"
CONFIG_EXISTS=true

echo "=========================================================="
echo "   JS-Ping Cluster Node Deployment Helper"
echo "=========================================================="

# 1. Check if config.yaml exists
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_EXISTS=false
    echo "[Info] config.yaml not found. Generating default blank template..."
    
    # Write default config content into config.yaml to prevent Docker from creating a directory
    cat << 'EOF' > "$CONFIG_FILE"
server:
  node_id: ""
  zone: external
  listen_port: 8080
  ip_address: ""

database:
  host: ""
  port: 3306
  user: ""
  password: ""
  dbname: ""
  charset: utf8mb4
  max_open_conns: 25
  max_idle_conns: 5
  conn_max_lifetime: 5m0s

security:
  allowed_ips:
    - 127.0.0.1
    - ::1
    - localhost
    - 10.0.0.0/8
    - 172.16.0.0/12
    - 192.168.0.0/16

telegram:
  bot_token: ""
  chat_id: ""
EOF
    echo "✅ Generated $CONFIG_FILE successfully."
else
    echo "✅ Found existing $CONFIG_FILE."
fi

# 2. Run docker compose up -d to start the containers
echo "[Info] Launching JS-Ping Docker Containers..."
docker compose up -d
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Failed to run docker compose!"
    exit 1
fi

# 3. Print deployment guides
echo "=========================================================="
echo "🎉 SUCCESS: JS-Ping Cluster Node is now running!"
echo "   Dashboard Web Address: http://localhost:8080"
echo "=========================================================="
if [ "$CONFIG_EXISTS" = false ]; then
    echo "[안내] 데이터베이스가 아직 비어있으므로,"
    echo "       대시보드 최초 접속 시 'MySQL 설정 마법사'로 이동합니다."
    echo "       화면 지침에 따라 데이터베이스 연결을 완성해 주세요."
    echo "=========================================================="
fi
