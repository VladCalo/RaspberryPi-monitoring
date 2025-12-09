# Raspberry Pi 5 Monitoring Stack

Lightweight Prometheus + Grafana monitoring for Raspberry Pi.

## Quick Start

```bash
sudo bash provision.sh
```

Stack gets installed to `/opt/monitoring` and runs as a systemd service.

## Services

- Prometheus (9090) - metrics & alerting
- Alertmanager (9093) - alert management
- Grafana (3000) - dashboards (admin/admin)
- Node Exporter (9100) - system metrics

## Alerts

**Performance**:

- CPU: warning 90%, critical 95%
- Memory: warning 85%, critical 95%
- Load: warning 80%, critical 120% of cores

**System Health**:

- Root filesystem: warning 20% free, critical 10%
- CPU temp: warning 70°C, critical 80°C
- NVMe temp: warning 70°C, critical 80°C

View alerts at `http://<pi-ip>:9090/alerts` or `http://<pi-ip>:9093`

## What's Monitored

- CPU (usage, frequency, load averages)
- Memory (RAM, swap, buffers, cache)
- Disk (I/O, latency, throughput, filesystem usage)
- Network (traffic, errors, interface status)
- Hardware (temperatures, uptime)

## Management

```bash
cd /opt/monitoring
./manage.sh status|start|stop|restart|cleanup|help
```

## Resource Limits

- Prometheus: 256MB RAM, 50% CPU
- Alertmanager: 128MB RAM, 20% CPU
- Grafana: 256MB RAM, 30% CPU
- Node Exporter: 64MB RAM, 20% CPU

Total: ~704MB RAM max

## Config

- Scrape interval: 15s
- Data retention: 7 days
- Auto cleanup: daily at 2:00 AM (logs, old data, docker artifacts)

## Troubleshooting

```bash
sudo systemctl status monitoring.service
sudo journalctl -xeu monitoring.service
sudo netstat -tlnp | grep -E ':(3000|9090|9100)'
./manage.sh cleanup  # disk space issues
```

## Notes

- Designed for Pi 5, should work on Pi 4
- Docker required
- Auto-starts on boot via systemd
