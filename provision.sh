#!/bin/bash

set -ex

MONITORING_STACK_DIR="/opt/monitoring"
rm -rf "$MONITORING_STACK_DIR"
mkdir -p "$MONITORING_STACK_DIR"

# Create directories for Docker volumes
mkdir -p "$MONITORING_STACK_DIR/prometheus_data"
mkdir -p "$MONITORING_STACK_DIR/grafana_data"

# Create prometheus rules directory
mkdir -p "$MONITORING_STACK_DIR/prometheus/rules"

rsync -av --exclude=".git" --exclude="provision.sh" --exclude="README.md" . "$MONITORING_STACK_DIR"

cp -f "$MONITORING_STACK_DIR/systemd/monitoring.service" "/etc/systemd/system/monitoring.service"
rm -rf "$MONITORING_STACK_DIR/systemd"
chmod +x "$MONITORING_STACK_DIR/manage.sh"

# Set up automatic cleanup every day at 2 AM to prevent root filesystem bloat
# Only add if not already present
if ! sudo crontab -l 2>/dev/null | grep -q "manage.sh cleanup"; then
    (sudo crontab -l 2>/dev/null; echo "0 2 * * * /opt/monitoring/manage.sh cleanup > /dev/null 2>&1") | sudo crontab -
    echo "Cron job added for daily cleanup"
else
    echo "Cron job already exists, skipping"
fi

systemctl daemon-reload
systemctl enable monitoring.service
systemctl start monitoring.service