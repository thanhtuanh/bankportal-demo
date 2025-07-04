#!/bin/bash
# Lokales Deployment Script

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

echo "🏠 Bank Portal - Lokales Deployment"
echo "==================================="

# 1. Environment prüfen
log_step "Prüfe Environment..."

if [ ! -f ".env" ]; then
    log_info ".env Datei nicht gefunden, erstelle Standard-Konfiguration..."
    cat > .env << EOF
# Bank Portal Environment Configuration
POSTGRES_PASSWORD=admin
JWT_SECRET=mysecretkeymysecretkeymysecretkey123456
SPRING_PROFILES_ACTIVE=dev
CORS_ALLOWED_ORIGINS=http://localhost:4200
EOF
    log_success ".env Datei erstellt"
fi

# Docker prüfen
if ! command -v docker &> /dev/null; then
    log_error "Docker ist nicht installiert!"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose ist nicht installiert!"
    exit 1
fi

log_success "Environment OK"

# 2. Services stoppen
log_step "Stoppe bestehende Services..."
docker-compose down --remove-orphans > /dev/null 2>&1 || true
log_success "Services gestoppt"

# 3. Images bauen
log_step "Baue Docker Images..."

# Prüfen ob Build-Script existiert
if [ -f "./scripts/deploy-prod.sh" ]; then
    ./scripts/deploy-prod.sh build > /dev/null 2>&1
    log_success "Images mit Production Script gebaut"
else
    # Fallback: Direkt bauen
    log_info "Baue Images direkt..."
    
    # Auth Service
    cd auth-service
    mvn clean package -DskipTests -q
    docker build -t bankportal-demo-auth-service:latest . > /dev/null
    cd ..
    
    # Account Service
    cd account-service
    mvn clean package -DskipTests -q
    docker build -t bankportal-demo-account-service:latest . > /dev/null
    cd ..
    
    # Frontend
    cd frontend
    npm ci > /dev/null 2>&1
    npm run build > /dev/null 2>&1
    docker build -t bankportal-demo-frontend:latest . > /dev/null
    cd ..
    
    log_success "Images direkt gebaut"
fi

# 4. Services starten
log_step "Starte Services..."
docker-compose up -d

# Status anzeigen
echo ""
log_info "Service Status:"
docker-compose ps

# 5. Warten auf Services
log_step "Warte auf Services..."
log_info "Services starten... (60 Sekunden warten)"

for i in {1..12}; do
    echo -n "."
    sleep 5
done
echo ""

# 6. Health Checks
log_step "Führe Health Checks durch..."

# Warten bis Services bereit sind
RETRY_COUNT=0
MAX_RETRIES=12

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s -f http://localhost:8082/actuator/health > /dev/null 2>&1; then
        log_success "Services sind bereit!"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    log_info "Warte auf Services... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 10
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log_error "Services sind nicht rechtzeitig gestartet!"
    echo ""
    echo "Debug Informationen:"
    docker-compose logs --tail=20
    exit 1
fi

# API Tests ausführen
if [ -f "./scripts/test-api.sh" ]; then
    log_step "Führe API Tests durch..."
    if ./scripts/test-api.sh; then
        log_success "API Tests erfolgreich"
    else
        log_error "API Tests fehlgeschlagen"
    fi
fi

# 7. Zusammenfassung
echo ""
log_success "✅ Lokales Deployment erfolgreich!"
echo ""
echo "🌐 Services verfügbar unter:"
echo "  ┌─────────────────────────────────────────┐"
echo "  │ Frontend:    http://localhost:4200      │"
echo "  │ Auth API:    http://localhost:8081      │"
echo "  │ Account API: http://localhost:8082      │"
echo "  └─────────────────────────────────────────┘"
echo ""
echo "📊 Nützliche Commands:"
echo "  docker-compose logs -f          # Logs anzeigen"
echo "  docker-compose ps               # Status anzeigen"
echo "  docker-compose down             # Services stoppen"
echo "  ./scripts/test-api.sh           # API Tests"
echo "  ./scripts/backup-system.sh      # Backup erstellen"
echo ""
echo "🎯 Nächste Schritte:"
echo "  1. Frontend im Browser öffnen: http://localhost:4200"
echo "  2. Benutzer registrieren und anmelden"
echo "  3. Konten erstellen und Transfers testen"
