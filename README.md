# Raspberry Pi 5 Lightweight Monitoring Stack

A minimal monitoring solution designed specifically for Raspberry Pi 5 with **low system load** and **minimal resource usage**. This stack provides basic system monitoring without overwhelming your Pi's limited resources.

## 🚀 Quick Start

```bash
# Clone the repository
git clone <REPO>
cd RaspberryPi-monitoring

# Run the provisioning script (IMPORTANT: use sudo!)
sudo bash provision.sh
```

**⚠️  IMPORTANT:** Always use `sudo` when running the provision script. The monitoring stack needs to create system directories and configure systemd services. Monitoring stack configuration files will be moved to **/opt/monitoring**

## 🏗️ Architecture Overview

This is a **3-service monitoring stack** that runs as a managed systemd service:

- **Prometheus** (Port 9090) - Metrics collection and storage
- **Grafana** (Port 3000) - Dashboard visualization  
- **Node Exporter** (Port 9100) - System metrics collection

## 📊 What Gets Monitored

### **System Performance**
- **CPU usage** - All CPU modes (user, system, idle, iowait, irq, softirq, steal, guest)
- **CPU frequency** - Current, min, max scaling frequencies
- **Load averages** - 1, 5, and 15-minute load averages
- **CPU count** - Number of CPU cores

### **Memory & Storage**
- **RAM usage** - Total, free, used, cached, buffers, swap
- **Memory breakdown** - Active/inactive, anon/file, slab, page tables
- **Huge pages** - Free, reserved, surplus, total
- **Virtual memory** - Vmalloc usage, direct mapping
- **Disk I/O** - Read/write operations, bytes, time, queue depth
- **Disk performance** - IOPS, latency, throughput, discard operations

### **Network & Connectivity**
- **Network traffic** - Receive/transmit bytes, packets, errors
- **Network performance** - Speed, utilization, MTU, carrier status
- **Network interfaces** - Up/down status, drops, collisions, compression

### **System Health**
- **Filesystem usage** - Mount points, space, inodes
- **Process metrics** - Running processes, context switches
- **System info** - Uptime, boot time, OS version, kernel info
- **Hardware** - Temperature sensors, power consumption (if available)

### **Advanced Metrics**
- **Memory pressure** - Reclaimable, unevictable, mlocked memory
- **I/O patterns** - Read/write merging, flush requests, discard operations
- **Network quality** - Error rates, drop rates, collision detection

## ⚡ Performance Optimizations

The stack is configured for **minimal resource usage**:

- **Scrape intervals**: 15 seconds (reduced from default)
- **Data retention**: 7 days (prevents disk bloat)
- **Resource limits**: Strict CPU/RAM limits per container
- **Log rotation**: Automatic cleanup of old logs
- **Metric filtering**: Only essential metrics collected

## 🔧 Management Commands

```bash
# Check stack status
cd /opt/monitoring

./manage.sh status

# Start the monitoring stack
./manage.sh start

# Stop the monitoring stack  
./manage.sh stop

# Restart the stack
./manage.sh restart

# Clean up old logs and data (manual)
./manage.sh cleanup

# Show help
./manage.sh help
```

## 🕐 Automatic Cleanup

A **cron job runs daily at 2:00 AM** to:
- Delete logs older than 7 days
- Clean up old Prometheus data
- Remove old Docker artifacts
- Prevent root filesystem bloat

## 🌐 Accessing the Services

After startup, you can access:

- **Grafana Dashboards**: http://your-pi-ip:3000
  - Username: `admin`
  - Password: `admin`
  
- **Prometheus**: http://your-pi-ip:9090
  
- **Node Exporter Metrics**: http://your-pi-ip:9100/metrics

## 🐳 Docker Details

- **Prometheus**: 256MB RAM limit, 50% CPU limit
- **Grafana**: 256MB RAM limit, 30% CPU limit  
- **Node Exporter**: 64MB RAM limit, 20% CPU limit
- **Total stack**: ~576MB RAM max, minimal CPU impact

## 🔍 Troubleshooting

**Service won't start?**
```bash
# Check service status
sudo systemctl status monitoring.service

# Check logs
sudo journalctl -u monitoring.service -f
```

**Ports already in use?**
```bash
# Check what's using the ports
sudo netstat -tlnp | grep -E ':(3000|9090|9100)'
```

**Disk space issues?**
```bash
# Run manual cleanup
./manage.sh cleanup

# Check disk usage
df -h /
```

## 📝 Notes

- This stack is designed for **Raspberry Pi 5** but should work on Pi 4
- **Docker is required** - make sure it's installed and running
- The stack automatically starts on boot via systemd
- All data is stored locally on your Pi's storage
- Designed for **home/homelab use** with minimal resource overhead
