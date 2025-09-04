#!/usr/bin/env bash
# Bank Portal – vereinfachtes lokales Deployment (mit Image-Fallback & Healthchecks)

set -Eeuo pipefail

# Farben
GREEN='\033[0;32m'; RED='\033[0;31m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'

log_step()    { echo -e "${BLUE}[STEP]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_info()    { echo -e "${YELLOW}[INFO]${NC} $1"; }

echo "🏠 Bank Portal - Vereinfachtes Deployment"
echo "========================================="

# Geeignetes Compose-Command finden
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  log_error "Weder 'docker compose' noch 'docker-compose' gefunden."
  exit 1
fi

# 1) Environment prüfen
log_step "Prüfe Environment…"

if ! docker info >/dev/null 2>&1; then
  log_error "Docker ist nicht gestartet! Bitte Docker Desktop/Daemon starten."
  exit 1
fi

if [ ! -f ".env" ]; then
  log_info ".env nicht gefunden – Standard-Konfiguration wird erstellt…"
  cat > .env << 'EOF'
# Bank Portal Environment Configuration
POSTGRES_PASSWORD=admin
JWT_SECRET=mysecretkeymysecretkeymysecretkey123456
SPRING_PROFILES_ACTIVE=development
CORS_ALLOWED_ORIGINS=http://localhost:4200
EOF
  log_success ".env erstellt (Profile=development)"
fi

log_success "Environment OK"

# 2) Bestehende Services stoppen
log_step "Stoppe bestehende Services…"
${COMPOSE} down --remove-orphans >/dev/null 2>&1 || true
log_success "Services gestoppt"

# 3) Vorbereitete Images aus GHCR ziehen (optional)
log_step "Versuche, vorgefertigte Docker Images aus GHCR zu verwenden…"

NEED_BUILD_AUTH=false
NEED_BUILD_ACCOUNT=false
NEED_BUILD_FRONTEND=false

AUTH_IMG_REMOTE="ghcr.io/thanhtuanh/bankportal-demo/auth-service:latest"
ACC_IMG_REMOTE="ghcr.io/thanhtuanh/bankportal-demo/account-service:latest"
FE_IMG_REMOTE="ghcr.io/thanhtuanh/bankportal-demo/frontend:latest"

AUTH_IMG_LOCAL="bankportal-demo-auth-service:latest"
ACC_IMG_LOCAL="bankportal-demo-account-service:latest"
FE_IMG_LOCAL="bankportal-demo-frontend:latest"

pull_and_tag () {
  local remote="$1" localtag="$2" name="$3"
  log_info "📦 Lade $name Image…"
  if docker pull "$remote" >/dev/null 2>&1; then
    docker tag "$remote" "$localtag"
    log_info "   ✅ $name Image geladen: $localtag"
    return 0
  else
    log_error "   ❌ $name Image konnte nicht geladen werden"
    return 1
  fi
}

pull_and_tag "$AUTH_IMG_REMOTE" "$AUTH_IMG_LOCAL" "Auth Service"      || NEED_BUILD_AUTH=true
pull_and_tag "$ACC_IMG_REMOTE"  "$ACC_IMG_LOCAL"  "Account Service"   || NEED_BUILD_ACCOUNT=true
pull_and_tag "$FE_IMG_REMOTE"   "$FE_IMG_LOCAL"   "Frontend"          || NEED_BUILD_FRONTEND=true

# 4) Compose-Override schreiben, damit Images genutzt werden (kein Build)
OVERRIDE_FILE="docker-compose.override.images.yml"
USE_OVERRIDE=false

if [ "$NEED_BUILD_AUTH" = false ] && [ "$NEED_BUILD_ACCOUNT" = false ] && [ "$NEED_BUILD_FRONTEND" = false ]; then
  log_success "Alle Images erfolgreich geladen"
  log_step "Schreibe Compose-Override, um Images zu erzwingen…"
  cat > "$OVERRIDE_FILE" <<EOF
services:
  auth-service:
    image: ${AUTH_IMG_LOCAL}
    build: null
  account-service:
    image: ${ACC_IMG_LOCAL}
    build: null
  frontend:
    image: ${FE_IMG_LOCAL}
    build: null
EOF
  USE_OVERRIDE=true
else
  log_info "⚠️  Einige Images fehlen – es wird auf lokales Build per Compose zurückgegriffen."
  log_info "   Tipp: docker login ghcr.io  (falls privat/rate-limited)"
fi

# 5) Services starten
log_step "Starte Services…"
COMPOSE_FILES=(-f docker-compose.yml)
if [ "$USE_OVERRIDE" = true ]; then
  COMPOSE_FILES+=(-f "$OVERRIDE_FILE")
fi

# Build bei Bedarf erlauben; Logs zwischenspeichern
if ${COMPOSE} "${COMPOSE_FILES[@]}" up -d > /tmp/compose.log 2>&1; then
  log_success "Services gestartet"
else
  log_error "Services konnten nicht gestartet werden!"
  cat /tmp/compose.log
  exit 1
fi

# Status
echo ""
log_info "Service Status:"
${COMPOSE} "${COMPOSE_FILES[@]}" ps

# 6) Warten auf Services (max ~120s)
log_step "Warte auf Services…"
MAX_WAIT_SEC=120
SLEEP_STEP=5
WAITED=0

printf "%s" "Starten"
while [ $WAITED -lt $MAX_WAIT_SEC ]; do
  printf "."
  sleep $SLEEP_STEP
  WAITED=$((WAITED + SLEEP_STEP))
done
echo ""

# 7) Health Checks (richtige URLs!)
log_step "Führe Health Checks durch…"

check_url () {
  local url="$1"
  curl -sSf "$url" >/dev/null 2>&1
}

RETRIES=12
for i in $(seq 1 $RETRIES); do
  AUTH_OK=false; ACCOUNT_OK=false; FRONTEND_OK=false

  # ACHTUNG: /api/health in deinen Services
  check_url "http://localhost:8081/api/health" && AUTH_OK=true
  check_url "http://localhost:8082/api/health" && ACCOUNT_OK=true
  check_url "http://localhost:4200"            && FRONTEND_OK=true

  if $AUTH_OK && $ACCOUNT_OK && $FRONTEND_OK; then
    log_success "Alle Services sind bereit!"
    break
  fi

  log_info "Warte auf Services… ($i/$RETRIES) [Auth:$AUTH_OK Account:$ACCOUNT_OK Frontend:$FRONTEND_OK]"
  sleep 5
done

if ! ($AUTH_OK && $ACCOUNT_OK && $FRONTEND_OK); then
  log_error "Services sind nicht rechtzeitig bereit!"
  echo ""
  log_info "Debug Informationen:"
  ${COMPOSE} "${COMPOSE_FILES[@]}" ps
  ${COMPOSE} "${COMPOSE_FILES[@]}" logs --tail=50
  exit 1
fi

# 8) Zusammenfassung
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
echo "  ${COMPOSE} ${COMPOSE_FILES[*]} logs -f"
echo "  ${COMPOSE} ${COMPOSE_FILES[*]} ps"
echo "  ${COMPOSE} ${COMPOSE_FILES[*]} down"
echo ""
echo "🎯 Nächste Schritte:"
echo "  1. Frontend im Browser öffnen: http://localhost:4200"
echo "  2. Benutzer registrieren und anmelden"
echo "  3. Konten erstellen und Transfers testen"
