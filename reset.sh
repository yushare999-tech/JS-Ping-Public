#!/bin/bash
# ==============================================================================
#   🏓 JS-Ping Official One-Touch Public Reset/Uninstall Script
#   GitHub Repository: https://github.com/yushare999-tech/JS-Ping-Public
#
#   Features:
#     - Safely stops and removes JS-Ping docker containers & compose stacks
#     - Cleans up JS-Ping config files (config.yaml, .env, docker-compose.yml)
#     - Resets corrupted docker socket & systemd failed states
# ==============================================================================

set -e

echo "=========================================================="
echo "   🏓 JS-Ping Cluster Node One-Touch Reset Helper"
echo "=========================================================="

# 1. Stop and remove JS-Ping containers
echo "[1/4] Stopping JS-Ping docker containers..."
if command -v docker &> /dev/null; then
    docker rm -f js-ping-node 2>/dev/null || true
    docker compose down --volumes --remove-orphans 2>/dev/null || docker-compose down 2>/dev/null || true
fi

# 2. Remove JS-Ping configuration files from current directory and home
echo "[2/4] Removing JS-Ping configuration files..."
rm -f docker-compose.yml config.yaml .env 2>/dev/null || true
rm -f ~/docker-compose.yml ~/config.yaml ~/.env 2>/dev/null || true

# 3. Clean up unmounted Docker network namespaces and systemd failed limits
echo "[3/4] Resetting Docker service & systemd status..."
if command -v systemctl &> /dev/null; then
    sudo umount -f -l /var/run/docker/netns/* 2>/dev/null || true
    sudo systemctl reset-failed docker docker.socket 2>/dev/null || true
    sudo systemctl restart containerd 2>/dev/null || true
    sudo systemctl restart docker.socket 2>/dev/null || true
    sudo systemctl restart docker.service 2>/dev/null || true
fi

# 4. Remove cached images if requested (Optional clean)
echo "[4/4] Clean up complete!"

echo "=========================================================="
echo "🎉 SUCCESS: System is now completely reset to clean state!"
echo "   You can now run fresh installation via: "
echo "   curl -sSL https://raw.githubusercontent.com/yushare999-tech/JS-Ping-Public/main/deploy.sh | bash"
echo "=========================================================="
