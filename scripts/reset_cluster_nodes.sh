#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

CONFIG_FILE="$PROJECT_DIR/Dev/config_dev.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_FILE="$PROJECT_DIR/Master/config.yaml"
fi
if [ ! -f "$CONFIG_FILE" ]; then
    CONFIG_FILE="$PROJECT_DIR/deploy/config.yaml.example"
fi

echo "=========================================================="
echo "   JS-Ping Cluster Nodes DB Reset Utility                 "
echo "=========================================================="

# Parse DB parameters from config.yaml
DB_HOST=$(grep -A 10 "database:" "$CONFIG_FILE" | grep "host:" | head -n 1 | awk '{print $2}' | tr -d '\r\n"')
DB_PORT=$(grep -A 10 "database:" "$CONFIG_FILE" | grep "port:" | head -n 1 | awk '{print $2}' | tr -d '\r\n"')
DB_USER=$(grep -A 10 "database:" "$CONFIG_FILE" | grep "user:" | head -n 1 | awk '{print $2}' | tr -d '\r\n"')
DB_PASS=$(grep -A 10 "database:" "$CONFIG_FILE" | grep "password:" | head -n 1 | awk '{print $2}' | tr -d '\r\n"')
DB_NAME=$(grep -A 10 "database:" "$CONFIG_FILE" | grep "dbname:" | head -n 1 | awk '{print $2}' | tr -d '\r\n"')

DB_HOST=${DB_HOST:-"127.0.0.1"}
DB_PORT=${DB_PORT:-"3306"}
DB_USER=${DB_USER:-"root"}
DB_NAME=${DB_NAME:-"myinfo"}

echo "[1/2] Connecting to MySQL (${DB_HOST}:${DB_PORT}, DB: ${DB_NAME}, User: ${DB_USER})..."

SQL_SCRIPT="$SCRIPT_DIR/reset_cluster_nodes.sql"

if command -v mysql &> /dev/null; then
    MYSQL_PWD="$DB_PASS" mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" "$DB_NAME" < "$SQL_SCRIPT"
    echo "[2/2] SUCCESS: All cluster nodes & target leases have been reset!"
    echo "=========================================================="
else
    echo "[!] Warning: mysql CLI client is not installed on host."
    echo "    Please run the following SQL manually in your DB client:"
    echo "----------------------------------------------------------"
    cat "$SQL_SCRIPT"
    echo "----------------------------------------------------------"
fi
