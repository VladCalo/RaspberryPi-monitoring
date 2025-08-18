#!/bin/bash
set -e

DEBUG=0
MONITORING_STACK_DIR="/opt/monitoring"

if [[ "$DEBUG" == "1" ]]; then
    COMPOSE_FILE="docker-compose.yml"
else
    COMPOSE_FILE="$MONITORING_STACK_DIR/docker-compose.yml"
fi

COMPOSE_CMD="docker compose"

info() {
    echo "[INFO] $1"
}

success() {
    echo "[OK] $1"
}

error() {
    echo "[ERROR] $1"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        error "Docker isn't running. Start it first."
        exit 1
    fi
}

stack_status() {
    info "Checking the status of the monitoring stack..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" ps
}

start_stack() {
    info "Starting the monitoring stack..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" up -d
    success "Stack is running!"
    
    echo
    info "You can now access:"
    echo "  Grafana:     http://$(hostname -I | awk '{print $1}'):3000 (admin/admin)"
    echo "  Prometheus:  http://$(hostname -I | awk '{print $1}'):9090"
    echo "  Node Exporter: http://$(hostname -I | awk '{print $1}'):9100/metrics"
}

stop_stack() {
    info "Stopping the monitoring stack..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" down
    success "Stack stopped!"
}

restart_stack() {
    info "Restarting the monitoring stack..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" restart
    success "Stack restarted!"
}

cleanup_old_data() {
    info "Cleaning up old logs and data (older than 7 days)..."
    
    # Clean up Docker container logs older than 7 days
    find /var/lib/docker/containers/*/logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    # Clean up any other monitoring logs older than 7 days
    find /opt/monitoring -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    # Clean up old Prometheus data (keep only last 7 days)
    docker exec prometheus find /prometheus -name "*.db" -mtime +7 -delete 2>/dev/null || true
    
    # Clean up old Grafana logs
    docker exec grafana find /var/log/grafana -name "*.log" -mtime +7 -delete 2>/dev/null || true
    
    # Force garbage collection in Prometheus
    docker exec prometheus wget --post-data='' http://localhost:9090/api/v1/admin/tsdb/clean_tombstones -O /dev/null 2>/dev/null || true
    
    # Clean up old Docker images and containers
    docker container prune -f --filter "until=168h" 2>/dev/null || true
    docker image prune -f --filter "until=168h" 2>/dev/null || true
    
    success "Cleanup completed!"
    echo
    info "Current disk usage:"
    df -h /
    echo
    info "Docker disk usage:"
    docker system df
}

# Show help
show_help() {
    echo "Pi Monitoring Stack Manager"
    echo
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  status    Show the status of the stack"
    echo "  start     Start the stack"
    echo "  stop      Stop the stack"
    echo "  restart   Restart the stack"
    echo "  cleanup   Clean up old logs and data (older than 7 days)"
    echo "  help      Show this help"
    echo
}

# Main script
main() {
    check_docker
    
    case "${1:-help}" in
        status)
            stack_status
            ;;
        start)
            start_stack
            ;;
        stop)
            stop_stack
            ;;
        restart)
            restart_stack
            ;;
        cleanup)
            cleanup_old_data
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

main "$@"
