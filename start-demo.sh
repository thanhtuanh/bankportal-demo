#!/usr/bin/env bash
# 🏦 Bank Portal - Demo Startup Script (immer: clean + build)

set -Eeuo pipefail

# Farben
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${BLUE}\n🏦 ======================================\n   BANK PORTAL - DEMO STARTUP\n   (immer CLEAN + BUILD)\n======================================${NC}\n"

# Compose-Command ermitteln
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo -e "${RED}❌ Weder 'docker compose' noch 'docker-compose' gefunden.${NC}"; exit 1
fi

# Docker verfügbar?
if ! docker info >/dev/null 2>&1; then
  echo -e "${RED}❌ Docker ist nicht gestartet!${NC}\n${YELLOW}Bitte Docker starten und erneut versuchen.${NC}"; exit 1
fi
echo -e "${GREEN}✅ Docker ist verfügbar${NC}"

# .env minimal anlegen (falls fehlt)
if [ ! -f ".env" ]; then
  echo -e "${YELLOW}ℹ️  .env fehlt – Standardwerte werden angelegt${NC}"
  cat > .env <<'EOF'
POSTGRES_PASSWORD=admin
JWT_SECRET=mysecretkeymysecretkeymysecretkey123456
SPRING_PROFILES_ACTIVE=development
CORS_ALLOWED_ORIGINS=http://localhost:4200
EOF
fi

# ⚠️ Clean: Container + Volumes löschen, System aufräumen
echo -e "${YELLOW}🧹 Clean: stoppe & lösche Container/Volumes… (Daten gehen verloren)${NC}"
$COMPOSE down -v --remove-orphans >/dev/null 2>&1 || true
docker system prune -f >/dev/null 2>&1 || true

# Build & Start (Multi-stage Build über Compose)
echo -e "${BLUE}\n🚀 Baue & starte Services (Compose BUILD)…${NC}"
if $COMPOSE up -d --build; then
  echo -e "${GREEN}✅ Services erfolgreich gebaut & gestartet${NC}"
else
  echo -e "${RED}❌ Fehler beim Starten der Services${NC}\n${YELLOW}💡 Logs: $COMPOSE logs${NC}"
  exit 1
fi

echo -e "\n${YELLOW}⏳ Warte auf Services...${NC}"

wait_for_service() {
  local name="$1" url="$2" attempts=60 delay=3 i=1
  echo -e "${CYAN}   Warte auf ${name}...${NC}"
  while [ $i -le $attempts ]; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo -e "${GREEN}   ✅ ${name} ist bereit!${NC}"; return 0
    fi
    if (( i % 10 == 0 )); then
      echo -e "${YELLOW}   ⏳ Versuch ${i}/${attempts}…${NC}"
    fi
    sleep $delay; ((i++))
  done
  echo -e "${RED}   ❌ ${name} konnte nicht gestartet werden${NC}"
  echo -e "${YELLOW}   💡 Logs prüfen: $COMPOSE logs ${name}${NC}"
  return 1
}

AUTH_READY=false; ACCOUNT_READY=false; FRONTEND_READY=false
wait_for_service "auth-service"    "http://localhost:8081/api/health" && AUTH_READY=true
wait_for_service "account-service" "http://localhost:8082/api/health" && ACCOUNT_READY=true
wait_for_service "frontend"        "http://localhost:4200"            && FRONTEND_READY=true

echo ""
if $AUTH_READY && $ACCOUNT_READY && $FRONTEND_READY; then
  echo -e "${GREEN}🎉 ======================================\n   BANK PORTAL DEMO IST BEREIT!\n======================================${NC}\n"
  echo -e "${PURPLE}📊 Service URLs:${NC}
${CYAN}   🌐 Frontend:        http://localhost:4200
   🔐 Auth Service:    http://localhost:8081
   💼 Account Service: http://localhost:8082${NC}\n"
  echo -e "${PURPLE}📚 API Doku:${NC}
${CYAN}   🔐 Auth Swagger:    http://localhost:8081/swagger-ui/index.html
   💼 Account Swagger: http://localhost:8082/swagger-ui/index.html${NC}\n"
else
  echo -e "${YELLOW}⚠️  Einige Services sind nicht bereit. Status:${NC}
   Auth:    $([ $AUTH_READY = true ] && echo ✅ || echo ❌)
   Account: $([ $ACCOUNT_READY = true ] && echo ✅ || echo ❌)
   Frontend:$([ $FRONTEND_READY = true ] && echo ✅ || echo ❌)\n"
  echo -e "${YELLOW}🛠 Tipps:${NC}
${CYAN}   • Logs: $COMPOSE logs -f
   • Einzelservice: $COMPOSE logs -f account-service
   • Neustart: $COMPOSE restart${NC}"
  exit 1
fi
