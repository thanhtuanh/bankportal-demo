#!/bin/bash
# Vereinfachtes lokales Deployment Script

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

echo "🏠 Bank Portal - Vereinfachtes Deployment"
echo "========================================="

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

if ! docker info >/dev/null 2>&1; then
    log_error "Docker ist nicht gestartet! Bitte starten Sie Docker Desktop."
    exit 1
fi

log_success "Environment OK"

# 2. Services stoppen
log_step "Stoppe bestehende Services..."
docker-compose down --remove-orphans > /dev/null 2>&1 || true
log_success "Services gestoppt"

# 3. Versuche GitHub Images zu verwenden
log_step "Verwende vorgefertigte Docker Images..."

log_info "📦 Lade Auth Service Image..."
if docker pull ghcr.io/thanhtuanh/bankportal-demo/auth-service:latest > /dev/null 2>&1; then
    docker tag ghcr.io/thanhtuanh/bankportal-demo/auth-service:latest bankportal-demo-auth-service:latest
    log_info "   ✅ Auth Service Image geladen"
else
    log_error "   ❌ Auth Service Image konnte nicht geladen werden"
    NEED_BUILD_AUTH=true
fi

log_info "💼 Lade Account Service Image..."
if docker pull ghcr.io/thanhtuanh/bankportal-demo/account-service:latest > /dev/null 2>&1; then
    docker tag ghcr.io/thanhtuanh/bankportal-demo/account-service:latest bankportal-demo-account-service:latest
    log_info "   ✅ Account Service Image geladen"
else
    log_error "   ❌ Account Service Image konnte nicht geladen werden"
    NEED_BUILD_ACCOUNT=true
fi

log_info "🌐 Lade Frontend Image..."
if docker pull ghcr.io/thanhtuanh/bankportal-demo/frontend:latest > /dev/null 2>&1; then
    docker tag ghcr.io/thanhtuanh/bankportal-demo/frontend:latest bankportal-demo-frontend:latest
    log_info "   ✅ Frontend Image geladen"
else
    log_error "   ❌ Frontend Image konnte nicht geladen werden"
    NEED_BUILD_FRONTEND=true
fi

# 4. Fallback: Lokales Bauen nur wenn nötig
if [ "$NEED_BUILD_AUTH" = true ] || [ "$NEED_BUILD_ACCOUNT" = true ] || [ "$NEED_BUILD_FRONTEND" = true ]; then
    log_info "⚠️  Einige Images konnten nicht geladen werden - lokales Bauen erforderlich"
    log_error "❌ Lokales Bauen ist derzeit wegen Java-Konfigurationsproblemen nicht möglich"
    log_info ""
    log_info "🔧 Lösungsvorschläge:"
    log_info "1. Internetverbindung prüfen für GitHub Container Registry"
    log_info "2. Docker Login: docker login ghcr.io"
    log_info "3. Java-Problem lösen für lokales Bauen"
    log_info ""
    log_info "📋 Manueller Image-Download:"
    log_info "docker pull ghcr.io/thanhtuanh/bankportal-demo/auth-service:latest"
    log_info "docker pull ghcr.io/thanhtuanh/bankportal-demo/account-service:latest"
    log_info "docker pull ghcr.io/thanhtuanh/bankportal-demo/frontend:latest"
    exit 1
else
    log_success "Alle Images erfolgreich geladen"
fi

# 5. Services starten
log_step "Starte Services..."
if docker-compose up -d > /tmp/compose.log 2>&1; then
    log_success "Services gestartet"
else
    log_error "Services konnten nicht gestartet werden!"
    cat /tmp/compose.log
    exit 1
fi

# Status anzeigen
echo ""
log_info "Service Status:"
docker-compose ps

# 6. Warten auf Services
log_step "Warte auf Services..."
log_info "Services starten... (maximal 60 Sekunden)"

for i in {1..12}; do
    echo -n "."
    sleep 5
done
echo ""

# 7. Health Checks
log_step "Führe Health Checks durch..."

RETRY_COUNT=0
MAX_RETRIES=12

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    AUTH_OK=false
    ACCOUNT_OK=false
    FRONTEND_OK=false
    
    if curl -s -f http://localhost:8081/actuator/health > /dev/null 2>&1; then
        AUTH_OK=true
    fi
    
    if curl -s -f http://localhost:8082/actuator/health > /dev/null 2>&1; then
        ACCOUNT_OK=true
    fi
    
    if curl -s -f http://localhost:4200 > /dev/null 2>&1; then
        FRONTEND_OK=true
    fi
    
    if $AUTH_OK && $ACCOUNT_OK && $FRONTEND_OK; then
        log_success "Alle Services sind bereit!"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    log_info "Warte auf Services... ($RETRY_COUNT/$MAX_RETRIES) [Auth:$AUTH_OK Account:$ACCOUNT_OK Frontend:$FRONTEND_OK]"
    sleep 10
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    log_error "Services sind nicht rechtzeitig gestartet!"
    echo ""
    log_info "Debug Informationen:"
    docker-compose ps
    docker-compose logs --tail=10
    exit 1
fi

# 8. Zusammenfassung
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
echo ""
echo "🎯 Nächste Schritte:"
echo "  1. Frontend im Browser öffnen: http://localhost:4200"
echo "  2. Benutzer registrieren und anmelden"
echo "  3. Konten erstellen und Transfers testen"