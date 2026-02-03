#!/bin/bash
# Mock systemctl for Docker testing
# This script simulates systemctl behavior without requiring a real systemd

# Parse command
COMMAND="$1"
SERVICE="$2"

case "$COMMAND" in
    daemon-reload)
        echo "[MOCK] systemctl daemon-reload"
        exit 0
        ;;
    enable)
        echo "[MOCK] Created symlink /etc/systemd/system/multi-user.target.wants/$SERVICE → /etc/systemd/system/$SERVICE"
        exit 0
        ;;
    disable)
        echo "[MOCK] Removed /etc/systemd/system/multi-user.target.wants/$SERVICE"
        exit 0
        ;;
    start)
        echo "[MOCK] Starting $SERVICE..."
        exit 0
        ;;
    stop)
        echo "[MOCK] Stopping $SERVICE..."
        exit 0
        ;;
    restart)
        echo "[MOCK] Restarting $SERVICE..."
        exit 0
        ;;
    status)
        # Simulate running service
        cat << EOF
● $SERVICE - FDM Monster - 3D Printer Farm Manager
     Loaded: loaded (/etc/systemd/system/$SERVICE; enabled; vendor preset: enabled)
     Active: active (running) since $(date)
   Main PID: 12345 (node)
      Tasks: 11 (limit: 4915)
     Memory: 50.0M
        CPU: 1.234s
     CGroup: /system.slice/$SERVICE
             └─12345 /usr/bin/node /path/to/app

$(date "+%b %d %H:%M:%S") hostname systemd[1]: Started FDM Monster - 3D Printer Farm Manager.
EOF
        exit 0
        ;;
    is-active)
        echo "active"
        exit 0
        ;;
    is-enabled)
        echo "enabled"
        exit 0
        ;;
    --version)
        echo "systemd 249 (249.11-0ubuntu3.17)"
        exit 0
        ;;
    *)
        echo "[MOCK] systemctl $*"
        exit 0
        ;;
esac
