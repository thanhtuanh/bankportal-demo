#!/bin/bash

# scripts/deploy-k8s.sh - Kubernetes Deployment mit PostgreSQL 15

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${GREEN}[K8S]${NC} $1"
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

# Parameter
ENVIRONMENT=${1:-development}
NAMESPACE="bankportal"

echo "🚀 Kubernetes Deployment für Bankportal"
echo "======================================="
echo "Environment: $ENVIRONMENT"
echo "Namespace: $NAMESPACE"
echo ""

# Überprüfung der Voraussetzungen
check_prerequisites() {
    print_step "Überprüfung der Voraussetzungen..."
    
    # Kubectl prüfen
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl ist nicht installiert"
        exit 1
    fi
    
    # Cluster-Verbindung prüfen
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Keine Verbindung zum Kubernetes Cluster"
        print_info "Stelle sicher, dass dein Cluster läuft und kubectl konfiguriert ist"
        exit 1
    fi
    
    # Kustomize prüfen (ist in kubectl ab v1.14 enthalten)
    if ! kubectl kustomize --help &> /dev/null; then
        print_error "Kustomize ist nicht verfügbar in kubectl"
        exit 1
    fi
    
    print_step "✅ Alle Voraussetzungen erfüllt"
    
    # Cluster Info anzeigen
    CLUSTER_INFO=$(kubectl cluster-info | head -1)
    print_info "Verbunden mit: $CLUSTER_INFO"
}

# Docker Images bauen
build_images() {
    print_step "Docker Images werden für PostgreSQL 15 Setup gebaut..."
    
    if [ ! -f "scripts/build-images.sh" ]; then
        print_error "build-images.sh Script nicht gefunden!"
        exit 1
    fi
    
    # Images bauen
    bash scripts/build-images.sh $ENVIRONMENT latest
    
    print_step "✅ Images erfolgreich gebaut"
}

# Namespace erstellen
create_namespace() {
    print_step "Namespace '$NAMESPACE' wird erstellt..."
    
    if kubectl get namespace $NAMESPACE &> /dev/null; then
        print_info "Namespace '$NAMESPACE' existiert bereits"
    else
        kubectl create namespace $NAMESPACE
        print_step "✅ Namespace '$NAMESPACE' erstellt"
    fi
    
    # Label setzen
    kubectl label namespace $NAMESPACE environment=$ENVIRONMENT --overwrite
}

# Secrets und ConfigMaps
deploy_configs() {
    print_step "Secrets und ConfigMaps werden deployed..."
    
    # Base64 Encoding für Secrets (für PostgreSQL 15)
    JWT_SECRET_B64=$(echo -n "mysecretkeymysecretkeymysecretkey123456" | base64)
    DB_USER_B64=$(echo -n "admin" | base64)
    DB_PASS_B64=$(echo -n "admin" | base64)
    
    # Secrets YAML erstellen
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: bankportal-secrets
  namespace: $NAMESPACE
type: Opaque
data:
  jwt-secret: $JWT_SECRET_B64
  db-username: $DB_USER_B64
  db-password: $DB_PASS_B64
EOF
    
    # ConfigMap für PostgreSQL 15
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: bankportal-config
  namespace: $NAMESPACE
data:
  AUTH_DB_URL: "jdbc:postgresql://postgres-auth-service:5432/authdb"
  ACCOUNT_DB_URL: "jdbc:postgresql://postgres-account-service:5432/accountdb"
  SPRING_PROFILES_ACTIVE: "$ENVIRONMENT"
  SERVER_PORT_AUTH: "8081"
  SERVER_PORT_ACCOUNT: "8082"
  JWT_EXPIRATION_MS: "86400000"
  POSTGRES_VERSION: "15"
EOF
    
    print_step "✅ Configs deployed"
}

# PostgreSQL 15 Deployments
deploy_databases() {
    print_step "PostgreSQL 15 Datenbanken werden deployed..."
    
    # PostgreSQL Auth Service
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-auth
  namespace: $NAMESPACE
  labels:
    app: postgres-auth
    version: "15"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-auth
  template:
    metadata:
      labels:
        app: postgres-auth
        version: "15"
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "authdb"
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: bankportal-secrets
              key: db-username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: bankportal-secrets
              key: db-password
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        volumeMounts:
        - name: postgres-auth-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - admin
            - -d
            - authdb
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - admin
            - -d
            - authdb
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: postgres-auth-storage
        persistentVolumeClaim:
          claimName: postgres-auth-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-auth-service
  namespace: $NAMESPACE
spec:
  selector:
    app: postgres-auth
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-auth-pvc
  namespace: $NAMESPACE
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: standard
EOF

    # PostgreSQL Account Service
    cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-account
  namespace: $NAMESPACE
  labels:
    app: postgres-account
    version: "15"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-account
  template:
    metadata:
      labels:
        app: postgres-account
        version: "15"
    spec:
      containers:
      - name: postgres
        image: postgres:15
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          value: "accountdb"
        - name: POSTGRES_USER
          valueFrom:
            secretKeyRef:
              name: bankportal-secrets
              key: db-username
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: bankportal-secrets
              key: db-password
        - name: PGDATA
          value: /var/lib/postgresql/data/pgdata
        volumeMounts:
        - name: postgres-account-storage
          mountPath: /var/lib/postgresql/data
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - admin
            - -d
            - accountdb
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          exec:
            command:
            - pg_isready
            - -U
            - admin
            - -d
            - accountdb
          initialDelaySeconds: 5
          periodSeconds: 5
      volumes:
      - name: postgres-account-storage
        persistentVolumeClaim:
          claimName: postgres-account-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-account-service
  namespace: $NAMESPACE
spec:
  selector:
    app: postgres-account
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-account-pvc
  namespace: $NAMESPACE
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: standard
EOF

    print_step "✅ PostgreSQL 15 Datenbanken deployed"
}

# Warten auf Datenbanken
wait_for_databases() {
    print_step "Warten auf PostgreSQL 15 Datenbanken..."
    
    # Auth Database
    print_info "Warten auf Auth Database..."
    kubectl wait --for=condition=ready pod -l app=postgres-auth -n $NAMESPACE --timeout=300s
    
    # Account Database
    print_info "Warten auf Account Database..."
    kubectl wait --for=condition=ready pod -l app=postgres-account -n $NAMESPACE --timeout=300s
    
    print_step "✅ Datenbanken sind bereit"
}

# Services deployen
deploy_services() {
    print_step "Application Services werden deployed..."
    
    # Prüfe ob Kustomize Overlays existieren
    if [ -d "k8s/overlays/$ENVIRONMENT" ]; then
        print_info "Verwende Kustomize Overlay für $ENVIRONMENT"
        kubectl apply -k k8s/overlays/$ENVIRONMENT
    elif [ -d "k8s/base" ]; then
        print_info "Verwende Kustomize Base Configuration"
        kubectl apply -k k8s/base
    else
        print_warning "Keine Kustomize Konfiguration gefunden, verwende einzelne Manifeste"
        # Fallback zu einzelnen Manifesten
        if [ -f "k8s/auth-service.yaml" ]; then
            kubectl apply -f k8s/auth-service.yaml
        fi
        if [ -f "k8s/account-service.yaml" ]; then
            kubectl apply -f k8s/account-service.yaml
        fi
        if [ -f "k8s/frontend.yaml" ]; then
            kubectl apply -f k8s/frontend.yaml
        fi
    fi
    
    print_step "✅ Services deployed"
}

# Warten auf Services
wait_for_services() {
    print_step "Warten auf Application Services..."
    
    # Auth Service
    if kubectl get deployment auth-service -n $NAMESPACE &> /dev/null; then
        print_info "Warten auf Auth Service..."
        kubectl wait --for=condition=available deployment/auth-service -n $NAMESPACE --timeout=300s
    fi
    
    # Account Service
    if kubectl get deployment account-service -n $NAMESPACE &> /dev/null; then
        print_info "Warten auf Account Service..."
        kubectl wait --for=condition=available deployment/account-service -n $NAMESPACE --timeout=300s
    fi
    
    # Frontend
    if kubectl get deployment frontend -n $NAMESPACE &> /dev/null; then
        print_info "Warten auf Frontend..."
        kubectl wait --for=condition=available deployment/frontend -n $NAMESPACE --timeout=300s
    fi
    
    print_step "✅ Alle Services sind bereit"
}

# Status anzeigen
show_status() {
    print_step "=== DEPLOYMENT STATUS ==="
    echo ""
    
    print_info "📊 Pods:"
    kubectl get pods -n $NAMESPACE -o wide
    echo ""
    
    print_info "🔧 Services:"
    kubectl get svc -n $NAMESPACE
    echo ""
    
    print_info "💾 Persistent Volumes:"
    kubectl get pvc -n $NAMESPACE
    echo ""
    
    if kubectl get hpa -n $NAMESPACE &> /dev/null; then
        print_info "📈 Horizontal Pod Autoscaler:"
        kubectl get hpa -n $NAMESPACE
        echo ""
    fi
    
    if kubectl get ingress -n $NAMESPACE &> /dev/null; then
        print_info "🌐 Ingress:"
        kubectl get ingress -n $NAMESPACE
        echo ""
    fi
    
    print_step "🎉 Bankportal mit PostgreSQL 15 ist deployed!"
    echo ""
    print_info "Port-Forward für lokalen Zugriff:"
    print_info "  kubectl port-forward svc/frontend-service 8080:80 -n $NAMESPACE"
    print_info "  kubectl port-forward svc/auth-service 8081:8081 -n $NAMESPACE"
    print_info "  kubectl port-forward svc/account-service 8082:8082 -n $NAMESPACE"
    echo ""
}

# Cleanup Funktion
cleanup() {
    print_step "Cleanup wird durchgeführt..."
    kubectl delete namespace $NAMESPACE --ignore-not-found=true
    print_step "✅ Cleanup abgeschlossen"
}

# Logs anzeigen
show_logs() {
    print_step "Logs der Services:"
    echo ""
    
    # Letzte Logs aller Pods
    kubectl logs -l app.kubernetes.io/name=bankportal -n $NAMESPACE --tail=50
}

# Health Check
health_check() {
    print_step "Health Check wird durchgeführt..."
    
    # Port-Forward temporär für Health Checks
    kubectl port-forward svc/auth-service 18081:8081 -n $NAMESPACE &
    AUTH_PF_PID=$!
    kubectl port-forward svc/account-service 18082:8082 -n $NAMESPACE &
    ACCOUNT_PF_PID=$!
    
    sleep 5
    
    # Auth Service Health Check
    if curl -f http://localhost:18081/actuator/health >/dev/null 2>&1; then
        print_step "✅ Auth Service: Gesund"
    else
        print_warning "⚠️  Auth Service: Nicht erreichbar"
    fi
    
    # Account Service Health Check
    if curl -f http://localhost:18082/actuator/health >/dev/null 2>&1; then
        print_step "✅ Account Service: Gesund"
    else
        print_warning "⚠️  Account Service: Nicht erreichbar"
    fi
    
    # Cleanup Port-Forwards
    kill $AUTH_PF_PID $ACCOUNT_PF_PID 2>/dev/null || true
}

# Hauptfunktion
main() {
    case "$1" in
        "deploy")
            check_prerequisites
            create_namespace
            deploy_configs
            deploy_databases
            wait_for_databases
            build_images
            deploy_services
            wait_for_services
            show_status
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "health")
            health_check
            ;;
        "cleanup")
            cleanup
            ;;
        *)
            echo "Usage: $0 {deploy|status|logs|health|cleanup}"
            echo ""
            echo "Commands:"
            echo "  deploy [environment]  - Vollständiges Deployment (default: development)"
            echo "  status               - Status aller Resources anzeigen"
            echo "  logs                 - Logs aller Services anzeigen"
            echo "  health               - Health Check durchführen"
            echo "  cleanup              - Alle Resources löschen"
            echo ""
            echo "Examples:"
            echo "  $0 deploy development    # Development Deployment"
            echo "  $0 deploy production     # Production Deployment"
            echo "  $0 status               # Status prüfen"
            echo "  $0 logs                 # Logs anzeigen"
            echo "  $0 cleanup              # Alles löschen"
            echo ""
            echo "Environment: $ENVIRONMENT"
            echo "Namespace: $NAMESPACE"
            exit 1
            ;;
    esac
}

# Script ausführen
main "$@"