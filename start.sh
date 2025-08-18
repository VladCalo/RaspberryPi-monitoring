#!/bin/bash

# Simple script to manage the Pi monitoring stack

set -e

COMPOSE_FILE="docker-compose.yml"
PROJECT_NAME="raspberry-pi-monitoring"

# Figure out which compose command to use
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "[ERROR] Neither docker-compose nor docker compose found. Install Docker first."
    exit 1
fi

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

# Start the monitoring stack
start_stack() {
    info "Starting the monitoring stack..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d
    success "Stack is running!"
    
    echo
    info "You can now access:"
    echo "  Grafana:     http://$(hostname -I | awk '{print $1}'):3000 (admin/admin)"
    echo "  Prometheus:  http://$(hostname -I | awk '{print $1}'):9090"
    echo "  Node Exporter: http://$(hostname -I | awk '{print $1}'):9100/metrics"
}

# Stop the monitoring stack
stop_stack() {
    info "Stopping the monitoring stack..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" down
    success "Stack stopped!"
}

# Restart the monitoring stack
restart_stack() {
    info "Restarting the monitoring stack..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" restart
    success "Stack restarted!"
}

# Show logs
show_logs() {
    local service=${1:-""}
    if [ -n "$service" ]; then
        info "Showing logs for $service..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" logs -f "$service"
    else
        info "Showing all logs..."
        $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" logs -f
    fi
}

# Update and restart
update_stack() {
    info "Updating images..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" pull
    info "Restarting with new images..."
    $COMPOSE_CMD -f "$COMPOSE_FILE" -p "$PROJECT_NAME" up -d
    success "Updated and restarted!"
}

# Show help
show_help() {
    echo "Pi Monitoring Stack Manager"
    echo
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  start     Start the stack"
    echo "  stop      Stop the stack"
    echo "  restart   Restart the stack"
    echo "  logs      Show logs (all or specific service)"
    echo "  update    Update images and restart"
    echo "  help      Show this help"
    echo
    echo "Examples:"
    echo "  $0 start                    # Start everything"
    echo "  $0 logs                     # Show all logs"
    echo "  $0 logs prometheus          # Show Prometheus logs"
}

# Main script
main() {
    check_docker
    
    case "${1:-help}" in
        start)
            start_stack
            ;;
        stop)
            stop_stack
            ;;
        restart)
            restart_stack
            ;;
        logs)
            show_logs "$2"
            ;;
        update)
            update_stack
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
