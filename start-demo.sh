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

# Check if Maven is available
if ! command -v mvn &> /dev/null; then
    echo -e "${YELLOW}⚠️  Maven ist nicht installiert - verwende Docker für Build${NC}"
    USE_DOCKER_BUILD=true
else
    echo -e "${GREEN}✅ Maven ist verfügbar${NC}"
    USE_DOCKER_BUILD=false
fi

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

# Build backend services
if [[ "$USE_DOCKER_BUILD" == "false" ]]; then
    echo -e "${BLUE}🔨 Baue Backend Services mit Maven...${NC}"
    
    # Build Auth Service
    echo -e "${CYAN}   📦 Baue Auth Service...${NC}"
    cd auth-service
    if mvn clean package -DskipTests;  then
        echo -e "${GREEN}   ✅ Auth Service erfolgreich gebaut${NC}"
    else
        echo -e "${RED}   ❌ Auth Service Build fehlgeschlagen${NC}"
        echo -e "${YELLOW}   🔄 Verwende Docker Build als Fallback...${NC}"
        USE_DOCKER_BUILD=true
    fi
    cd ..
    
    # Build Account Service (only if Maven build succeeded)
    if [[ "$USE_DOCKER_BUILD" == "false" ]]; then
        echo -e "${CYAN}   📦 Baue Account Service...${NC}"
        cd account-service
        if mvn clean package -DskipTests; then
            echo -e "${GREEN}   ✅ Account Service erfolgreich gebaut${NC}"
        else
            echo -e "${RED}   ❌ Account Service Build fehlgeschlagen${NC}"
            echo -e "${YELLOW}   🔄 Verwende Docker Build als Fallback...${NC}"
            USE_DOCKER_BUILD=true
        fi
        cd ..
    fi
fi

# Start services
echo ""
echo -e "${BLUE}🚀 Starte Bank Portal Demo...${NC}"

if [[ "$USE_DOCKER_BUILD" == "true" ]]; then
    echo -e "${CYAN}   🐳 Verwende Docker Multi-Stage Build...${NC}"
    echo -e "${CYAN}   Dies kann beim ersten Start länger dauern${NC}"
    echo -e "${CYAN}   (Maven Dependencies werden heruntergeladen)${NC}"
else
    echo -e "${CYAN}   ⚡ Verwende vorgebaute JAR-Dateien...${NC}"
    echo -e "${CYAN}   Dies sollte schneller gehen${NC}"
fi

echo ""

# Start services with build
if docker-compose up -d --build; then
    echo -e "${GREEN}✅ Services erfolgreich gestartet${NC}"
else
    echo -e "${RED}❌ Fehler beim Starten der Services${NC}"
    echo -e "${YELLOW}💡 Versuchen Sie: docker-compose logs${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}⏳ Warte auf Services...${NC}"

# Wait for services to be healthy
wait_for_service() {
    local service_name=$1
    local url=$2
    local max_attempts=60  # Increased for Docker builds
    local attempt=1
    
    echo -e "${CYAN}   Warte auf $service_name...${NC}"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}   ✅ $service_name ist bereit!${NC}"
            return 0
        fi
        
        if [ $((attempt % 10)) -eq 0 ]; then
            echo -e "${YELLOW}   ⏳ Versuch $attempt/$max_attempts (Services starten noch...)${NC}"
        fi
        sleep 3
        ((attempt++))
    done
    
    echo -e "${RED}   ❌ $service_name konnte nicht gestartet werden${NC}"
    echo -e "${YELLOW}   💡 Prüfen Sie die Logs: docker-compose logs $service_name${NC}"
    return 1
}

# Wait for all services
echo ""
if wait_for_service "Auth Service" "http://localhost:8081/api/health"; then
    AUTH_READY=true
else
    AUTH_READY=false
fi

if wait_for_service "Account Service" "http://localhost:8082/api/health"; then
    ACCOUNT_READY=true
else
    ACCOUNT_READY=false
fi

if wait_for_service "Frontend" "http://localhost:4200"; then
    FRONTEND_READY=true
else
    FRONTEND_READY=false
fi

echo ""

# Show results
if [[ "$AUTH_READY" == "true" && "$ACCOUNT_READY" == "true" && "$FRONTEND_READY" == "true" ]]; then
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
    
else
    echo -e "${YELLOW}⚠️  ======================================"
    echo "   DEMO TEILWEISE GESTARTET"
    echo "======================================${NC}"
    
    echo ""
    echo -e "${YELLOW}📊 Service Status:${NC}"
    if [[ "$AUTH_READY" == "true" ]]; then
        echo -e "${GREEN}   ✅ Auth Service: http://localhost:8081${NC}"
    else
        echo -e "${RED}   ❌ Auth Service: Nicht verfügbar${NC}"
    fi
    
    if [[ "$ACCOUNT_READY" == "true" ]]; then
        echo -e "${GREEN}   ✅ Account Service: http://localhost:8082${NC}"
    else
        echo -e "${RED}   ❌ Account Service: Nicht verfügbar${NC}"
    fi
    
    if [[ "$FRONTEND_READY" == "true" ]]; then
        echo -e "${GREEN}   ✅ Frontend: http://localhost:4200${NC}"
    else
        echo -e "${RED}   ❌ Frontend: Nicht verfügbar${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}🛠️  Troubleshooting:${NC}"
    echo -e "${CYAN}   • Logs prüfen: docker-compose logs${NC}"
    echo -e "${CYAN}   • Services neu starten: docker-compose restart${NC}"
    echo -e "${CYAN}   • Vollständiger Neustart: docker-compose down && ./start-demo.sh${NC}"
fi

echo ""
echo -e "${YELLOW}💡 Tipps:${NC}"
echo -e "${CYAN}   • Logs anzeigen: docker-compose logs -f${NC}"
echo -e "${CYAN}   • Demo stoppen: docker-compose down${NC}"
echo -e "${CYAN}   • Neustart mit Clean: ./start-demo.sh --clean${NC}"
