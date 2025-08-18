#!/bin/bash
set -ex

MONITORING_STACK_DIR="/opt/monitoring"
COMPOSE_FILE="$MONITORING_STACK_DIR/docker-compose.yml"

COMPOSE_CMD="docker compose"

# Simple output functions
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
