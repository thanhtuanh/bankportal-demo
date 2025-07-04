#!/bin/bash

# scripts/setup-local.sh - Lokales Setup mit PostgreSQL 15

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Header
echo "🏦 Bankportal Demo - Lokales Setup"
echo "=================================="
echo ""

# Voraussetzungen prüfen
check_prerequisites() {
    print_step "Überprüfung der Voraussetzungen..."
    
    # Docker prüfen
    if ! command -v docker &> /dev/null; then
        print_error "Docker ist nicht installiert. Bitte installiere Docker Desktop."
        exit 1
    fi
    
    # Docker Compose prüfen
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose ist nicht installiert."
        exit 1
    fi
    
    # Node.js prüfen (für Frontend Development)
    if ! command -v node &> /dev/null; then
        print_warning "Node.js ist nicht installiert. Frontend Development wird nicht verfügbar sein."
    else
        NODE_VERSION=$(node --version)
        print_info "Node.js Version: $NODE_VERSION"
    fi
    
    # Java prüfen (für Backend Development)
    if ! command -v java &> /dev/null; then
        print_warning "Java ist nicht installiert. Backend Development wird nicht verfügbar sein."
    else
        JAVA_VERSION=$(java -version 2>&1 | head -n 1)
        print_info "Java Version: $JAVA_VERSION"
    fi
    
    # Maven prüfen
    if ! command -v mvn &> /dev/null; then
        print_warning "Maven ist nicht installiert. Backend Build wird nicht verfügbar sein."
    else
        MVN_VERSION=$(mvn --version | head -n 1)
        print_info "Maven Version: $MVN_VERSION"
    fi
    
    print_step "✅ Voraussetzungen geprüft"
}

# Cleanup alte Container
cleanup_containers() {
    print_step "Cleanup alter Container..."
    
    # Stoppe und entferne Container falls sie existieren
    docker-compose down --remove-orphans 2>/dev/null || true
    
    # Entferne alte PostgreSQL Container falls sie einzeln laufen
    docker stop postgres-auth postgres-account 2>/dev/null || true
    docker rm postgres-auth postgres-account 2>/dev/null || true
    
    print_step "✅ Cleanup abgeschlossen"
}

# PostgreSQL Datenbanken einzeln starten (für Development ohne Docker Compose)
setup_databases_standalone() {
    print_step "PostgreSQL 15 Datenbanken werden gestartet..."
    
    # Auth Database
    print_info "Starte Auth Database (postgres-auth)..."
    docker run -d \
        --name postgres-auth \
        -e POSTGRES_DB=authdb \
        -e POSTGRES_USER=admin \
        -e POSTGRES_PASSWORD=admin \
        -p 5432:5432 \
        -v postgres_auth_data:/var/lib/postgresql/data \
        postgres:15
    
    # Account Database  
    print_info "Starte Account Database (postgres-account)..."
    docker run -d \
        --name postgres-account \
        -e POSTGRES_DB=accountdb \
        -e POSTGRES_USER=admin \
        -e POSTGRES_PASSWORD=admin \
        -p 5433:5432 \
        -v postgres_account_data:/var/lib/postgresql/data \
        postgres:15
    
    # Warte bis Datenbanken bereit sind
    print_step "Warte auf Datenbankverbindungen..."
    sleep 10
    
    # Test Verbindungen
    for i in {1..30}; do
        if docker exec postgres-auth pg_isready -U admin -d authdb >/dev/null 2>&1; then
            print_step "✅ Auth Database ist bereit"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "Auth Database ist nicht erreichbar"
            exit 1
        fi
        sleep 2
    done
    
    for i in {1..30}; do
        if docker exec postgres-account pg_isready -U admin -d accountdb >/dev/null 2>&1; then
            print_step "✅ Account Database ist bereit"
            break
        fi
        if [ $i -eq 30 ]; then
            print_error "Account Database ist nicht erreichbar"
            exit 1
        fi
        sleep 2
    done
}

# Docker Compose Setup
setup_with_compose() {
    print_step "Setup mit Docker Compose..."
    
    # Stelle sicher dass docker-compose.yml existiert
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml nicht gefunden!"
        exit 1
    fi
    
    # Starte alle Services
    print_info "Starte alle Services mit Docker Compose..."
    docker-compose up -d
    
    # Warte auf Services
    print_step "Warte auf Services..."
    sleep 15
    
    # Prüfe Service Status
    print_info "Service Status:"
    docker-compose ps
}

# Backend Services bauen (optional)
build_backend_services() {
    if command -v mvn &> /dev/null; then
        print_step "Backend Services werden gebaut..."
        
        # Auth Service
        if [ -d "auth-service" ]; then
            print_info "Baue Auth Service..."
            cd auth-service
            mvn clean package -DskipTests
            cd ..
        fi
        
        # Account Service
        if [ -d "account-service" ]; then
            print_info "Baue Account Service..."
            cd account-service
            mvn clean package -DskipTests
            cd ..
        fi
        
        print_step "✅ Backend Services gebaut"
    else
        print_warning "Maven nicht verfügbar - überspringe Backend Build"
    fi
}

# Frontend Setup (optional)
setup_frontend() {
    if command -v npm &> /dev/null && [ -d "frontend" ]; then
        print_step "Frontend Setup..."
        cd frontend
        
        print_info "Installiere NPM Dependencies..."
        npm install
        
        print_info "Frontend ist bereit für Development"
        print_info "Starte Frontend mit: cd frontend && ng serve"
        cd ..
    else
        print_warning "Node.js/npm nicht verfügbar oder Frontend Ordner nicht gefunden"
    fi
}

# Health Checks
run_health_checks() {
    print_step "Health Checks werden ausgeführt..."
    
    # Prüfe PostgreSQL Verbindungen
    if docker exec postgres-auth pg_isready -U admin -d authdb >/dev/null 2>&1; then
        print_step "✅ Auth Database: Gesund"
    else
        print_error "❌ Auth Database: Nicht erreichbar"
    fi
    
    if docker exec postgres-account pg_isready -U admin -d accountdb >/dev/null 2>&1; then
        print_step "✅ Account Database: Gesund"
    else
        print_error "❌ Account Database: Nicht erreichbar"
    fi
    
    # Prüfe Backend Services (falls mit Docker Compose)
    if docker-compose ps | grep -q "Up"; then
        print_info "Docker Compose Services laufen"
        
        # Warte kurz und prüfe Health Endpoints
        sleep 5
        
        if curl -f http://localhost:8081/actuator/health >/dev/null 2>&1; then
            print_step "✅ Auth Service: Gesund (http://localhost:8081)"
        else
            print_warning "⚠️  Auth Service: Noch nicht bereit oder nicht gestartet"
        fi
        
        if curl -f http://localhost:8082/actuator/health >/dev/null 2>&1; then
            print_step "✅ Account Service: Gesund (http://localhost:8082)"
        else
            print_warning "⚠️  Account Service: Noch nicht bereit oder nicht gestartet"
        fi
    fi
}

# Status anzeigen
show_status() {
    echo ""
    print_step "=== SETUP ABGESCHLOSSEN ==="
    echo ""
    print_info "🗄️  Datenbanken:"
    print_info "   Auth DB:    postgresql://admin:admin@localhost:5432/authdb"
    print_info "   Account DB: postgresql://admin:admin@localhost:5433/accountdb"
    echo ""
    print_info "🚀 Services:"
    print_info "   Auth Service:    http://localhost:8081"
    print_info "   Account Service: http://localhost:8082"
    print_info "   Frontend:        http://localhost:4200 (nach 'ng serve')"
    echo ""
    print_info "📝 Nützliche Befehle:"
    print_info "   docker-compose logs -f                 # Logs anzeigen"
    print_info "   docker-compose ps                      # Status prüfen"
    print_info "   docker-compose down                    # Services stoppen"
    print_info "   docker-compose up -d                   # Services neu starten"
    echo ""
    print_info "🧪 API Tests:"
    print_info "   curl http://localhost:8081/actuator/health"
    print_info "   curl http://localhost:8082/actuator/health"
    echo ""
}

# Hauptfunktion
main() {
    case "$1" in
        "compose")
            check_prerequisites
            cleanup_containers
            build_backend_services
            setup_with_compose
            run_health_checks
            show_status
            ;;
        "standalone")
            check_prerequisites
            cleanup_containers
            setup_databases_standalone
            build_backend_services
            setup_frontend
            run_health_checks
            show_status
            ;;
        "cleanup")
            cleanup_containers
            print_step "✅ Cleanup abgeschlossen"
            ;;
        *)
            echo "Usage: $0 {compose|standalone|cleanup}"
            echo ""
            echo "Optionen:"
            echo "  compose    - Vollständiges Setup mit Docker Compose"
            echo "  standalone - Nur Datenbanken, Services manuell starten"
            echo "  cleanup    - Alle Container stoppen und entfernen"
            echo ""
            echo "Beispiele:"
            echo "  $0 compose    # Empfohlen für komplettes lokales Setup"
            echo "  $0 standalone # Für Development mit manuellen Service-Starts"
            echo "  $0 cleanup    # Alles zurücksetzen"
            exit 1
            ;;
    esac
}

# Script ausführen
main "$@"