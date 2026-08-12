#!/bin/bash
# ==============================================================================
#   🏓 JS-Ping Official One-Touch Public Deployment Script
#   GitHub Repository: https://github.com/yushare999-tech/JS-Ping-Public
#
#   Features:
#     - 100% Python-Independent (Go-native Docker Compose v2)
#     - Auto-installs Docker & Docker Compose v2 standalone binary on Minimal OS
#     - Auto-installs bash-completion (Docker Tab Completion)
#     - Auto-adds current user to 'docker' group for non-root docker usage
# ==============================================================================

set -e

# Target Repository Raw URL for downloading assets if pipe-executed
RAW_REPO_URL="https://raw.githubusercontent.com/yushare999-tech/JS-Ping-Public/main"

# Get current script directory
if [ -n "$BASH_SOURCE" ] && [ -f "$BASH_SOURCE" ]; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
    DIR="$(pwd)"
fi
if [ "$DIR" = "/" ] && [ -d "/home/kuri" ]; then
    DIR="/home/kuri"
fi
cd "$DIR"
export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-js-ping}"

echo "=========================================================="
echo "   🏓 JS-Ping Public Cluster Node Deployment Helper"
echo "   Release: Official Public GHCR Container"
echo "=========================================================="

# 1. Verify Docker installation & Auto-install Docker if missing (apt/yum/dnf + get.docker.com fallback)
if ! command -v docker &> /dev/null; then
    echo "[Info] Docker is not installed on this system."
    echo "[Info] Starting Native Package Manager Auto-Installation..."
    
    # Try native OS package manager first (apt-get / dnf / yum)
    if command -v apt-get &> /dev/null; then
        echo "[Info] Detected Ubuntu/Debian system. Installing docker.io & bash-completion..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y || true
        apt-get install -y docker.io bash-completion || true
    elif command -v dnf &> /dev/null; then
        echo "[Info] Detected RHEL/Fedora/Rocky system. Installing docker & bash-completion..."
        dnf install -y docker bash-completion || true
    elif command -v yum &> /dev/null; then
        echo "[Info] Detected CentOS/RHEL system. Installing docker & bash-completion..."
        yum install -y docker bash-completion || true
    fi

    # Fallback to official get.docker.com script if native package manager didn't set up docker
    if ! command -v docker &> /dev/null; then
        echo "[Info] Fallback: Attempting official get.docker.com script..."
        if command -v curl &> /dev/null; then
            curl -fsSL https://get.docker.com | sh || true
        elif command -v wget &> /dev/null; then
            wget -qO- https://get.docker.com | sh || true
        fi
    fi
    
    # Start and enable Docker service daemon
    systemctl start docker 2>/dev/null || service docker start 2>/dev/null || true
    systemctl enable docker 2>/dev/null || true
    
    if ! command -v docker &> /dev/null; then
        echo "❌ ERROR: Automatic Docker installation failed."
        echo "   Please install Docker manually using: apt-get install -y docker.io"
        exit 1
    fi
    echo "✅ Docker installed and service daemon started successfully!"
else
    # Install bash-completion if missing
    if command -v apt-get &> /dev/null; then
        dpkg -s bash-completion &>/dev/null || (apt-get update -y && apt-get install -y bash-completion) || true
    fi
fi

# 1.5. Auto-configure 'docker' group for non-root users & setup completion
TARGET_USER="${SUDO_USER:-$USER}"
if [ -n "$TARGET_USER" ] && [ "$TARGET_USER" != "root" ]; then
    echo "[Info] Configuring 'docker' group permission for user: $TARGET_USER ..."
    groupadd docker 2>/dev/null || true
    usermod -aG docker "$TARGET_USER" 2>/dev/null || true
    echo "✅ User '$TARGET_USER' added to 'docker' group (Take effect on next login)."
fi

# 2. Ensure Go-native Python-Independent Docker Compose v2 is installed
DOCKER_COMPOSE_CMD=""

if docker compose version &> /dev/null; then
    DOCKER_COMPOSE_CMD="docker compose"
fi

# If docker compose CLI plugin is missing or legacy Python v1 is found, install Go-native standalone Compose v2
if [ -z "$DOCKER_COMPOSE_CMD" ]; then
    echo "[Info] Installing Python-Independent Go-Native Docker Compose v2 Plugin..."
    
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  COMPOSE_ARCH="x86_64" ;;
        aarch64|arm64) COMPOSE_ARCH="aarch64" ;;
        *) COMPOSE_ARCH="x86_64" ;;
    esac

    # Destination directory for Docker CLI plugin
    PLUGIN_DIR="/usr/libexec/docker/cli-plugins"
    mkdir -p "$PLUGIN_DIR"
    mkdir -p "/usr/local/bin"

    COMPOSE_URL="https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-${COMPOSE_ARCH}"
    
    echo "[Info] Downloading Go-native binary from Github Releases ($COMPOSE_ARCH)..."
    if command -v curl &> /dev/null; then
        curl -sSL "$COMPOSE_URL" -o "$PLUGIN_DIR/docker-compose" || true
    elif command -v wget &> /dev/null; then
        wget -q "$COMPOSE_URL" -O "$PLUGIN_DIR/docker-compose" || true
    fi

    if [ -f "$PLUGIN_DIR/docker-compose" ]; then
        chmod +x "$PLUGIN_DIR/docker-compose"
        cp -f "$PLUGIN_DIR/docker-compose" "/usr/local/bin/docker-compose" 2>/dev/null || true
        chmod +x "/usr/local/bin/docker-compose" 2>/dev/null || true
    fi

    if docker compose version &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker compose"
    elif command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_CMD="docker-compose"
    fi
fi

if [ -z "$DOCKER_COMPOSE_CMD" ]; then
    echo "❌ ERROR: Failed to setup Go-native Docker Compose v2."
    echo "   Please run: apt-get install -y docker-compose-plugin"
    exit 1
fi

# Explicitly assign project name flag to ensure compose project name is never empty even under sudo/root
DOCKER_COMPOSE_CMD="$DOCKER_COMPOSE_CMD -p js-ping"

# Auto-fallback to sudo if current user cannot access docker.sock (e.g. freshly added to docker group before relogin)
if ! docker ps &>/dev/null; then
    if command -v sudo &>/dev/null; then
        DOCKER_COMPOSE_CMD="sudo $DOCKER_COMPOSE_CMD"
    fi
fi

echo "✅ Using Go-Native Docker Compose: $($DOCKER_COMPOSE_CMD version)"

# 3. Check and fetch docker-compose.yml if missing (e.g. running via curl pipe)
if [ ! -f "docker-compose.yml" ]; then
    echo "[Info] docker-compose.yml not found in current directory. Fetching from public repository..."
    if command -v curl &> /dev/null; then
        curl -sSL "$RAW_REPO_URL/docker-compose.yml" -o docker-compose.yml
    elif command -v wget &> /dev/null; then
        wget -q "$RAW_REPO_URL/docker-compose.yml" -o docker-compose.yml
    else
        echo "❌ ERROR: Neither curl nor wget found to download docker-compose.yml!"
        exit 1
    fi
    echo "✅ Downloaded docker-compose.yml successfully."
fi

# 4. Check if config.yaml exists. Generate default template if missing with auto-detected private IP
CONFIG_FILE="config.yaml"
CONFIG_EXISTS=true

if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_EXISTS=false
    echo "[Info] config.yaml not found. Detecting physical private NIC IP..."
    
    DETECTED_IP=$(ip -4 addr show 2>/dev/null | grep -vE '127\.0\.0\.1|docker|tailscale|veth|br-|cni|flannel|tun|ppp' | grep -oE 'inet (10\.[0-9]+\.[0-9]+\.[0-9]+|192\.168\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+)' | awk '{print $2}' | head -n 1 || true)
    if [ -z "$DETECTED_IP" ]; then
        DETECTED_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
    fi
    echo "[Info] Auto-detected Private IP: ${DETECTED_IP:-'None'}"

    cat << EOF > "$CONFIG_FILE"
server:
  node_id: "Node-${DETECTED_IP:-'Default'}"
  zone: "external"  # Options: internal, external
  listen_port: 8080
  ip_address: "${DETECTED_IP}"

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
    echo "✅ Generated $CONFIG_FILE with ip_address: '${DETECTED_IP}' successfully."
else
    echo "✅ Found existing $CONFIG_FILE."
fi

# 5. Write host real path & PING_VERSION to .env file for volume mapping
ENV_FILE=".env"
RAW_TARGET="${PING_VERSION:-${1:-latest}}"
if [ "$RAW_TARGET" != "latest" ]; then
    TARGET_VERSION=$(echo "$RAW_TARGET" | sed 's/^v//')
else
    TARGET_VERSION="latest"
fi
EFFECTIVE_HOST_PATH="${HOST_REAL_PATH:-$DIR}"
if [ "$EFFECTIVE_HOST_PATH" = "/" ] && [ -d "/home/kuri" ]; then
    EFFECTIVE_HOST_PATH="/home/kuri"
fi

cat <<EOF > "$ENV_FILE"
HOST_REAL_PATH=$EFFECTIVE_HOST_PATH
PING_VERSION=$TARGET_VERSION
EOF
echo "✅ Set HOST_REAL_PATH=$EFFECTIVE_HOST_PATH and PING_VERSION=$TARGET_VERSION in $ENV_FILE"

# 6. Pull specified container image and start service
echo "[Info] Pulling JS-Ping release image (Version: ${TARGET_VERSION})..."
$DOCKER_COMPOSE_CMD pull || true

# Remove conflicting existing container if any
sudo docker rm -f js-ping-node 2>/dev/null || docker rm -f js-ping-node 2>/dev/null || true

echo "[Info] Launching JS-Ping Docker Container..."
$DOCKER_COMPOSE_CMD up -d --remove-orphans

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Failed to start JS-Ping docker container!"
    exit 1
fi

# 7. Detect Host IP Address for display
HOST_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
if [ -z "$HOST_IP" ]; then
    HOST_IP="<Server-IP>"
fi

echo "=========================================================="
echo "🎉 SUCCESS: JS-Ping Cluster Node is now running!"
echo "   📌 Dashboard Web Address: http://${HOST_IP}:8080"
echo "=========================================================="
if [ "$CONFIG_EXISTS" = false ]; then
    echo "[안내] 데이터베이스 설정이 초기화 상태입니다."
    echo "       브라우저로 http://${HOST_IP}:8080 접속 시"
    echo "       'MySQL 웹 설정 마법사'가 자동으로 구동됩니다."
    echo "       화면의 지침에 따라 DB 연결을 완성해 주세요."
    echo "=========================================================="
fi
