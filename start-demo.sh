#!/bin/bash

# 🏦 Bank Portal - Demo Startup Script
# 🎯 Ein-Klick Demo ohne .env Konfiguration erforderlich

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "🏦 ======================================"
echo "   BANK PORTAL - DEMO STARTUP"
echo "   Modern Banking Platform Demo"
echo "======================================${NC}"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker ist nicht gestartet!${NC}"
    echo -e "${YELLOW}Bitte starten Sie Docker Desktop und versuchen Sie es erneut.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker ist verfügbar${NC}"

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose ist nicht installiert!${NC}"
    echo -e "${YELLOW}Bitte installieren Sie Docker Compose und versuchen Sie es erneut.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker Compose ist verfügbar${NC}"
echo ""

# Stop any existing containers
echo -e "${YELLOW}🛑 Stoppe existierende Container...${NC}"
docker-compose down --remove-orphans > /dev/null 2>&1 || true

# Clean up old volumes if requested
if [[ "$1" == "--clean" ]]; then
    echo -e "${YELLOW}🧹 Bereinige alte Volumes...${NC}"
    docker-compose down -v > /dev/null 2>&1 || true
    docker system prune -f > /dev/null 2>&1 || true
fi

echo ""
echo -e "${BLUE}🚀 Starte Bank Portal Demo...${NC}"
echo -e "${CYAN}   Dies kann beim ersten Start einige Minuten dauern${NC}"
echo -e "${CYAN}   (Docker Images werden heruntergeladen und gebaut)${NC}"
echo ""

# Start services
docker-compose up -d --build

echo ""
echo -e "${YELLOW}⏳ Warte auf Services...${NC}"

# Wait for services to be healthy
wait_for_service() {
    local service_name=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    echo -e "${CYAN}   Warte auf $service_name...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}   ✅ $service_name ist bereit!${NC}"
            return 0
        fi
        
        echo -e "${YELLOW}   ⏳ Versuch $attempt/$max_attempts...${NC}"
        sleep 5
        ((attempt++))
    done
    
    echo -e "${RED}   ❌ $service_name konnte nicht gestartet werden${NC}"
    return 1
}

# Wait for all services
echo ""
wait_for_service "Auth Service" "http://localhost:8081/api/health"
wait_for_service "Account Service" "http://localhost:8082/api/health"
wait_for_service "Frontend" "http://localhost:4200"

echo ""
echo -e "${GREEN}🎉 ======================================"
echo "   BANK PORTAL DEMO IST BEREIT!"
echo "======================================${NC}"
echo ""
echo -e "${PURPLE}📊 Service URLs:${NC}"
echo -e "${CYAN}   🌐 Frontend:        http://localhost:4200${NC}"
echo -e "${CYAN}   🔐 Auth Service:    http://localhost:8081${NC}"
echo -e "${CYAN}   💼 Account Service: http://localhost:8082${NC}"
echo ""
echo -e "${PURPLE}📚 API Dokumentation:${NC}"
echo -e "${CYAN}   🔐 Auth Swagger:    http://localhost:8081/swagger-ui/index.html${NC}"
echo -e "${CYAN}   💼 Account Swagger: http://localhost:8082/swagger-ui/index.html${NC}"
echo ""
echo -e "${PURPLE}🧪 Demo-Daten:${NC}"
echo -e "${CYAN}   Username: demo${NC}"
echo -e "${CYAN}   Password: demo123${NC}"
echo ""
echo -e "${YELLOW}💡 Tipps:${NC}"
echo -e "${CYAN}   • Registrieren Sie einen neuen Benutzer über das Frontend${NC}"
echo -e "${CYAN}   • Testen Sie die APIs über die Swagger UI${NC}"
echo -e "${CYAN}   • Logs anzeigen: docker-compose logs -f${NC}"
echo -e "${CYAN}   • Demo stoppen: docker-compose down${NC}"
echo ""
echo -e "${GREEN}🚀 Viel Spaß mit dem Bank Portal Demo!${NC}"

# Optionally open browser
if command -v open &> /dev/null; then
    echo -e "${YELLOW}🌐 Öffne Frontend im Browser...${NC}"
    sleep 2
    open http://localhost:4200
elif command -v xdg-open &> /dev/null; then
    echo -e "${YELLOW}🌐 Öffne Frontend im Browser...${NC}"
    sleep 2
    xdg-open http://localhost:4200
fi
