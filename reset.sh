#!/bin/bash
# ==============================================================================
#   🏓 JS-Ping Official One-Touch Public Reset/Uninstall Script
#   GitHub Repository: https://github.com/yushare999-tech/JS-Ping-Public
#
#   Features:
#     - Complete Deep Reset (Removes JS-Ping containers & config files)
#     - Optional/Full purge of Docker engine, Docker Compose & bash-completion
#     - Restores system to Minimal Fresh OS state for testing clean setup
# ==============================================================================

set -e

echo "=========================================================="
echo "   🏓 JS-Ping Cluster Node Deep Reset & Purge Helper"
echo "=========================================================="

# 1. Stop and remove JS-Ping containers & stacks
echo "[1/5] Stopping JS-Ping docker containers..."
if command -v docker &> /dev/null; then
    docker rm -f js-ping-node 2>/dev/null || true
    docker compose down --volumes --remove-orphans 2>/dev/null || docker-compose down 2>/dev/null || true
fi

# 2. Remove JS-Ping configuration files
echo "[2/5] Removing JS-Ping configuration files..."
rm -f docker-compose.yml config.yaml .env 2>/dev/null || true
rm -f ~/docker-compose.yml ~/config.yaml ~/.env 2>/dev/null || true

# 3. Clean up Docker netns and unmount
echo "[3/5] Cleaning up Docker namespaces and unmounting..."
if command -v systemctl &> /dev/null; then
    sudo umount -f -l /var/run/docker/netns/* 2>/dev/null || true
    sudo umount -f -l /var/lib/docker/overlay2/* 2>/dev/null || true
    sudo systemctl stop docker docker.socket containerd 2>/dev/null || true
fi

# 4. Deep Purge Docker Engine & bash-completion packages (Return to Minimal OS)
echo "[4/5] Purging Docker Engine & bash-completion packages..."
if command -v apt-get &> /dev/null; then
    sudo apt-get purge -y docker.io docker-ce docker-ce-cli containerd.io docker-compose-plugin bash-completion 2>/dev/null || true
    sudo apt-get autoremove -y 2>/dev/null || true
elif command -v dnf &> /dev/null; then
    sudo dnf remove -y docker docker-ce docker-ce-cli containerd.io docker-compose-plugin bash-completion 2>/dev/null || true
elif command -v yum &> /dev/null; then
    sudo yum remove -y docker docker-ce docker-ce-cli containerd.io docker-compose-plugin bash-completion 2>/dev/null || true
fi

# 5. Remove Docker binaries, configs, systemd limits & docker group
echo "[5/5] Removing residual Docker binaries and data directories..."
sudo rm -rf /etc/docker /var/lib/docker /var/run/docker* /var/run/containerd* 2>/dev/null || true
sudo rm -f /usr/local/bin/docker-compose /usr/libexec/docker/cli-plugins/docker-compose 2>/dev/null || true

# Remove user from docker group
TARGET_USER="${SUDO_USER:-$USER}"
if [ -n "$TARGET_USER" ]; then
    sudo gpasswd -d "$TARGET_USER" docker 2>/dev/null || true
fi
sudo groupdel docker 2>/dev/null || true

if command -v systemctl &> /dev/null; then
    sudo systemctl reset-failed 2>/dev/null || true
fi

echo "=========================================================="
echo "🎉 SUCCESS: System is now completely purged to FRESH MINIMAL OS state!"
echo "   (Docker & bash-completion packages fully uninstalled)"
echo "   You can now test fresh deployment via: "
echo "   curl -sSL https://raw.githubusercontent.com/yushare999-tech/JS-Ping-Public/main/deploy.sh | bash"
echo "=========================================================="
