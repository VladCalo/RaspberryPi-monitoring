#!/bin/bash

set -ex

MONITORING_STACK_DIR="/opt/monitoring"
mkdir -p "$MONITORING_STACK_DIR"
rsync -av --exclude=".git" --exclude="provision.sh" --exclude="README.md" . "$MONITORING_STACK_DIR"

cp -f "$MONITORING_STACK_DIR/systemd/monitoring.service" "/etc/systemd/system/monitoring.service"
rm -rf "$MONITORING_STACK_DIR/systemd"
chmod +x "$MONITORING_STACK_DIR/manage.sh"

systemctl daemon-reload
systemctl enable monitoring.service
systemctl start monitoring.service