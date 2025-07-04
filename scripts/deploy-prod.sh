#!/bin/bash
# Production Deployment Script für Bank Portal

set -e

echo "🚀 Bank Portal - Production Deployment"
echo "======================================"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funktionen
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Voraussetzungen prüfen
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose is not installed"
        exit 1
    fi
    
    if [ ! -f ".env.prod" ]; then
        log_warn ".env.prod file not found, using defaults"
        cp .env.prod.example .env.prod 2>/dev/null || true
    fi
    
    log_info "Prerequisites check passed ✅"
}

# Docker Images bauen
build_images() {
    log_info "Building Docker images..."
    
    # Auth Service
    log_info "Building Auth Service..."
    cd auth-service
    mvn clean package -DskipTests
    docker build -t bankportal-demo-auth-service:latest .
    cd ..
    
    # Account Service
    log_info "Building Account Service..."
    cd account-service
    mvn clean package -DskipTests
    docker build -t bankportal-demo-account-service:latest .
    cd ..
    
    # Frontend
    log_info "Building Frontend..."
    cd frontend
    npm ci
    npm run build
    docker build -t bankportal-demo-frontend:latest .
    cd ..
    
    log_info "Docker images built successfully ✅"
}

# Backup erstellen
create_backup() {
    if [ "$1" = "--backup" ]; then
        log_info "Creating database backup..."
        
        BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
        mkdir -p "$BACKUP_DIR"
        
        # PostgreSQL Backup
        docker-compose -f docker-compose.prod.yml exec -T postgres-auth pg_dump -U admin authdb > "$BACKUP_DIR/authdb_backup.sql" 2>/dev/null || log_warn "Auth DB backup failed"
        docker-compose -f docker-compose.prod.yml exec -T postgres-account pg_dump -U admin accountdb > "$BACKUP_DIR/accountdb_backup.sql" 2>/dev/null || log_warn "Account DB backup failed"
        
        log_info "Backup created in $BACKUP_DIR ✅"
    fi
}

# Deployment
deploy() {
    log_info "Starting production deployment..."
    
    # Stoppe alte Services
    log_info "Stopping existing services..."
    docker-compose -f docker-compose.prod.yml down --remove-orphans
    
    # Starte neue Services
    log_info "Starting new services..."
    docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
    
    # Warte auf Services
    log_info "Waiting for services to be ready..."
    sleep 30
    
    # Health Check
    log_info "Performing health checks..."
    
    # Auth Service
    if curl -f http://localhost:8081/actuator/health &>/dev/null; then
        log_info "Auth Service: ✅ Healthy"
    else
        log_error "Auth Service: ❌ Unhealthy"
    fi
    
    # Account Service
    if curl -f http://localhost:8082/actuator/health &>/dev/null; then
        log_info "Account Service: ✅ Healthy"
    else
        log_error "Account Service: ❌ Unhealthy"
    fi
    
    # Frontend
    if curl -f http://localhost/health &>/dev/null; then
        log_info "Frontend: ✅ Healthy"
    else
        log_error "Frontend: ❌ Unhealthy"
    fi
}

# Status anzeigen
show_status() {
    log_info "Deployment Status:"
    docker-compose -f docker-compose.prod.yml ps
    
    echo ""
    log_info "Application URLs:"
    echo "  Frontend:      http://localhost"
    echo "  Auth Service:  http://localhost:8081"
    echo "  Account Service: http://localhost:8082"
    echo ""
    log_info "Logs: docker-compose -f docker-compose.prod.yml logs -f"
}

# Main
main() {
    case "${1:-deploy}" in
        "build")
            check_prerequisites
            build_images
            ;;
        "deploy")
            check_prerequisites
            create_backup "$2"
            deploy
            show_status
            ;;
        "status")
            show_status
            ;;
        "logs")
            docker-compose -f docker-compose.prod.yml logs -f "${2:-}"
            ;;
        "stop")
            log_info "Stopping production services..."
            docker-compose -f docker-compose.prod.yml down
            ;;
        *)
            echo "Usage: $0 {build|deploy|status|logs|stop}"
            echo "  build   - Build Docker images"
            echo "  deploy  - Deploy to production (add --backup for DB backup)"
            echo "  status  - Show deployment status"
            echo "  logs    - Show logs (optional: service name)"
            echo "  stop    - Stop all services"
            exit 1
            ;;
    esac
}

main "$@"
