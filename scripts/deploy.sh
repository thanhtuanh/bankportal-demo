#!/bin/bash

# deploy.sh - Bankportal Kubernetes Deployment Script

set -e

echo "🚀 Bankportal Kubernetes Deployment gestartet..."

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funktionen
print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Überprüfung der Voraussetzungen
check_prerequisites() {
    print_step "Überprüfung der Voraussetzungen..."
    
    # Kubectl prüfen
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl ist nicht installiert"
        exit 1
    fi
    
    # Docker prüfen
    if ! command -v docker &> /dev/null; then
        print_error "Docker ist nicht installiert"
        exit 1
    fi
    
    # Cluster-Verbindung prüfen
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Keine Verbindung zum Kubernetes Cluster"
        exit 1
    fi
    
    print_step "✅ Alle Voraussetzungen erfüllt"
}

# Docker Images bauen
build_images() {
    print_step "Docker Images werden gebaut..."
    
    # Auth Service
    print_step "Auth Service Image bauen..."
    cd auth-service
    mvn clean package -DskipTests
    docker build -t bankportal/auth-service:latest .
    cd ..
    
    # Account Service
    print_step "Account Service Image bauen..."
    cd account-service
    mvn clean package -DskipTests
    docker build -t bankportal/account-service:latest .
    cd ..
    
    # Frontend
    print_step "Frontend Image bauen..."
    cd frontend
    npm install
    npm run build --prod
    docker build -t bankportal/frontend:latest .
    cd ..
    
    print_step "✅ Alle Images erfolgreich gebaut"
}

# Kubernetes Manifeste anwenden
deploy_kubernetes() {
    print_step "Kubernetes Manifeste werden angewendet..."
    
    # Namespace erstellen
    kubectl apply -f k8s/namespace.yaml
    
    # Secrets und ConfigMaps
    kubectl apply -f k8s/secrets.yaml
    
    # Datenbanken
    kubectl apply -f k8s/postgres-auth.yaml
    kubectl apply -f k8s/postgres-account.yaml
    
    # Warten bis Datenbanken bereit sind
    print_step "Warten auf Datenbanken..."
    kubectl wait --for=condition=ready pod -l app=postgres-auth -n bankportal --timeout=300s
    kubectl wait --for=condition=ready pod -l app=postgres-account -n bankportal --timeout=300s
    
    # Services
    kubectl apply -f k8s/auth-service.yaml
    kubectl apply -f k8s/account-service.yaml
    
    # Warten bis Services bereit sind
    print_step "Warten auf Services..."
    kubectl wait --for=condition=ready pod -l app=auth-service -n bankportal --timeout=300s
    kubectl wait --for=condition=ready pod -l app=account-service -n bankportal --timeout=300s
    
    # Frontend
    kubectl apply -f k8s/frontend.yaml
    kubectl wait --for=condition=ready pod -l app=frontend -n bankportal --timeout=300s
    
    # Ingress (optional)
    if [[ "$1" == "--with-ingress" ]]; then
        print_step "Ingress wird konfiguriert..."
        kubectl apply -f k8s/ingress.yaml
    fi
    
    print_step "✅ Deployment erfolgreich abgeschlossen"
}

# Status anzeigen
show_status() {
    print_step "Deployment Status:"
    
    echo ""
    echo "📊 Pods:"
    kubectl get pods -n bankportal
    
    echo ""
    echo "🔧 Services:"
    kubectl get svc -n bankportal
    
    echo ""
    echo "📈 HPA Status:"
    kubectl get hpa -n bankportal
    
    echo ""
    echo "🌐 Ingress (falls konfiguriert):"
    kubectl get ingress -n bankportal 2>/dev/null || echo "Kein Ingress konfiguriert"
    
    echo ""
    print_step "🎉 Bankportal ist bereit!"
    echo "Frontend: http://localhost:8080 (bei Port-Forward)"
    echo "Auth API: http://localhost:8081/api/auth"
    echo "Account API: http://localhost:8082/api/accounts"
    echo ""
    echo "Port-Forward für lokalen Zugriff:"
    echo "kubectl port-forward svc/frontend-service 8080:80 -n bankportal"
}

# Cleanup Funktion
cleanup() {
    print_step "Cleanup wird durchgeführt..."
    kubectl delete namespace bankportal --ignore-not-found=true
    print_step "✅ Cleanup abgeschlossen"
}

# Hauptfunktion
main() {
    case "$1" in
        "deploy")
            check_prerequisites
            build_images
            deploy_kubernetes "$2"
            show_status
            ;;
        "build")
            check_prerequisites
            build_images
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup
            ;;
        *)
            echo "Usage: $0 {deploy|build|status|cleanup}"
            echo ""
            echo "Commands:"
            echo "  deploy [--with-ingress]  - Vollständiges Deployment"
            echo "  build                    - Nur Docker Images bauen"
            echo "  status                   - Status anzeigen"
            echo "  cleanup                  - Alles löschen"
            echo ""
            echo "Examples:"
            echo "  $0 deploy                # Deployment ohne Ingress"
            echo "  $0