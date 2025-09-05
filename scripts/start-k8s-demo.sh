#!/bin/bash

# 🚀 Bank Portal - Kubernetes Demo Startup Script
# 🎯 Vollständiges K8s Setup für Lernen und Demo

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="bankportal"
K8S_DIR="temp-k8s-files"
MONITORING_ENABLED=true
DASHBOARD_ENABLED=true

# Banner
echo -e "${BLUE}"
echo "🚀 =============================================="
echo "   BANK PORTAL - KUBERNETES DEMO STARTUP"
echo "   Vollständiges K8s Setup für Lernen"
echo "===============================================${NC}"
echo ""

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}🔍 Prüfe Voraussetzungen...${NC}"
    
    # Check kubectl
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl ist nicht installiert!${NC}"
        echo -e "${YELLOW}Installation: https://kubernetes.io/docs/tasks/tools/install-kubectl/${NC}"
        exit 1
    fi
    
    # Check Kubernetes cluster
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}❌ Kein Kubernetes Cluster verfügbar!${NC}"
        echo -e "${YELLOW}Starten Sie Minikube, Docker Desktop K8s oder Kind:${NC}"
        echo -e "${CYAN}  minikube start${NC}"
        echo -e "${CYAN}  kind create cluster${NC}"
        exit 1
    fi
    
    # Check Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker ist nicht installiert!${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Alle Voraussetzungen erfüllt${NC}"
    
    # Show cluster info
    echo -e "${CYAN}📊 Kubernetes Cluster Info:${NC}"
    kubectl cluster-info | head -2
    echo ""
}

# Build Docker images
build_images() {
    echo -e "${BLUE}🔨 Baue Docker Images...${NC}"
    
    # Build Auth Service
    echo -e "${CYAN}   📦 Baue Auth Service...${NC}"
    if docker build -t bankportal/auth-service:latest ./auth-service > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Auth Service Image erstellt${NC}"
    else
        echo -e "${RED}   ❌ Auth Service Build fehlgeschlagen${NC}"
        exit 1
    fi
    
    # Build Account Service
    echo -e "${CYAN}   📦 Baue Account Service...${NC}"
    if docker build -t bankportal/account-service:latest ./account-service > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Account Service Image erstellt${NC}"
    else
        echo -e "${RED}   ❌ Account Service Build fehlgeschlagen${NC}"
        exit 1
    fi
    
    # Build Frontend
    echo -e "${CYAN}   📦 Baue Frontend...${NC}"
    if docker build -t bankportal/frontend:latest ./frontend > /dev/null 2>&1; then
        echo -e "${GREEN}   ✅ Frontend Image erstellt${NC}"
    else
        echo -e "${RED}   ❌ Frontend Build fehlgeschlagen${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Alle Images erfolgreich erstellt${NC}"
}

# Load images to cluster
load_images_to_cluster() {
    echo -e "${BLUE}📤 Lade Images in Kubernetes Cluster...${NC}"
    
    # Detect cluster type
    CLUSTER_TYPE=""
    if kubectl config current-context | grep -q "minikube"; then
        CLUSTER_TYPE="minikube"
    elif kubectl config current-context | grep -q "kind"; then
        CLUSTER_TYPE="kind"
    elif kubectl config current-context | grep -q "docker-desktop"; then
        CLUSTER_TYPE="docker-desktop"
    fi
    
    case $CLUSTER_TYPE in
        "minikube")
            echo -e "${CYAN}   🔄 Lade Images in Minikube...${NC}"
            minikube image load bankportal/auth-service:latest
            minikube image load bankportal/account-service:latest
            minikube image load bankportal/frontend:latest
            ;;
        "kind")
            echo -e "${CYAN}   🔄 Lade Images in Kind...${NC}"
            CLUSTER_NAME=$(kubectl config current-context | sed 's/kind-//')
            kind load docker-image bankportal/auth-service:latest --name $CLUSTER_NAME
            kind load docker-image bankportal/account-service:latest --name $CLUSTER_NAME
            kind load docker-image bankportal/frontend:latest --name $CLUSTER_NAME
            ;;
        "docker-desktop")
            echo -e "${CYAN}   🔄 Docker Desktop - Images bereits verfügbar${NC}"
            ;;
        *)
            echo -e "${YELLOW}   ⚠️  Unbekannter Cluster-Typ - Images möglicherweise nicht verfügbar${NC}"
            ;;
    esac
    
    echo -e "${GREEN}✅ Images in Cluster geladen${NC}"
}

# Create Kubernetes manifests
create_k8s_manifests() {
    echo -e "${BLUE}📝 Erstelle Kubernetes Manifeste...${NC}"
    
    # Create k8s directory
    mkdir -p $K8S_DIR/base
    mkdir -p $K8S_DIR/monitoring
    
    # Create namespace
    cat > $K8S_DIR/base/namespace.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: bankportal
  labels:
    name: bankportal
EOF

    # Create ConfigMap
    cat > $K8S_DIR/base/configmap.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: bankportal
data:
  SPRING_PROFILES_ACTIVE: "kubernetes"
  LOG_LEVEL: "INFO"
  POSTGRES_AUTH_HOST: "postgres-auth-service"
  POSTGRES_AUTH_PORT: "5432"
  POSTGRES_AUTH_DB: "authdb"
  POSTGRES_ACCOUNT_HOST: "postgres-account-service"
  POSTGRES_ACCOUNT_PORT: "5432"
  POSTGRES_ACCOUNT_DB: "accountdb"
  AUTH_SERVICE_URL: "http://auth-service:8081"
  ACCOUNT_SERVICE_URL: "http://account-service:8082"
  JWT_EXPIRATION: "3600"
EOF

    # Create Secrets
    cat > $K8S_DIR/base/secrets.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: bankportal
type: Opaque
data:
  POSTGRES_AUTH_PASSWORD: cGFzc3dvcmQxMjM=
  POSTGRES_ACCOUNT_PASSWORD: cGFzc3dvcmQxMjM=
  JWT_SECRET: bXlzZWNyZXRrZXlteXNlY3JldGtleW15c2VjcmV0a2V5MTIzNDU2
EOF

    echo -e "${GREEN}✅ Basis-Manifeste erstellt${NC}"
}

# Create database manifests
create_database_manifests() {
    echo -e "${CYAN}   📄 Erstelle Database Manifeste...${NC}"
    
    # Auth Database
    cat > $K8S_DIR/base/postgres-auth.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-auth
  namespace: bankportal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-auth
  template:
    metadata:
      labels:
        app: postgres-auth
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: POSTGRES_AUTH_DB
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: POSTGRES_AUTH_PASSWORD
        volumeMounts:
        - name: postgres-auth-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-auth-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-auth-service
  namespace: bankportal
spec:
  selector:
    app: postgres-auth
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
EOF

    # Account Database
    cat > $K8S_DIR/base/postgres-account.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres-account
  namespace: bankportal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgres-account
  template:
    metadata:
      labels:
        app: postgres-account
    spec:
      containers:
      - name: postgres
        image: postgres:15-alpine
        ports:
        - containerPort: 5432
        env:
        - name: POSTGRES_DB
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: POSTGRES_ACCOUNT_DB
        - name: POSTGRES_USER
          value: "admin"
        - name: POSTGRES_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: POSTGRES_ACCOUNT_PASSWORD
        volumeMounts:
        - name: postgres-account-storage
          mountPath: /var/lib/postgresql/data
      volumes:
      - name: postgres-account-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: postgres-account-service
  namespace: bankportal
spec:
  selector:
    app: postgres-account
  ports:
  - port: 5432
    targetPort: 5432
  type: ClusterIP
EOF
}

# Create service manifests
create_service_manifests() {
    echo -e "${CYAN}   📄 Erstelle Service Manifeste...${NC}"
    
    # Auth Service
    cat > $K8S_DIR/base/auth-service.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth-service
  namespace: bankportal
spec:
  replicas: 2
  selector:
    matchLabels:
      app: auth-service
  template:
    metadata:
      labels:
        app: auth-service
    spec:
      containers:
      - name: auth-service
        image: bankportal/auth-service:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8081
        env:
        - name: SPRING_PROFILES_ACTIVE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: SPRING_PROFILES_ACTIVE
        - name: POSTGRES_AUTH_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: POSTGRES_AUTH_HOST
        - name: POSTGRES_AUTH_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: POSTGRES_AUTH_PASSWORD
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: JWT_SECRET
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8081
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: auth-service
  namespace: bankportal
spec:
  selector:
    app: auth-service
  ports:
  - port: 8081
    targetPort: 8081
  type: ClusterIP
EOF

    # Account Service
    cat > $K8S_DIR/base/account-service.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: account-service
  namespace: bankportal
spec:
  replicas: 2
  selector:
    matchLabels:
      app: account-service
  template:
    metadata:
      labels:
        app: account-service
    spec:
      containers:
      - name: account-service
        image: bankportal/account-service:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8082
        env:
        - name: SPRING_PROFILES_ACTIVE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: SPRING_PROFILES_ACTIVE
        - name: POSTGRES_ACCOUNT_HOST
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: POSTGRES_ACCOUNT_HOST
        - name: POSTGRES_ACCOUNT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: POSTGRES_ACCOUNT_PASSWORD
        - name: AUTH_SERVICE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: AUTH_SERVICE_URL
        livenessProbe:
          httpGet:
            path: /api/health
            port: 8082
          initialDelaySeconds: 60
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /api/health
            port: 8082
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: account-service
  namespace: bankportal
spec:
  selector:
    app: account-service
  ports:
  - port: 8082
    targetPort: 8082
  type: ClusterIP
EOF

    # Frontend
    cat > $K8S_DIR/base/frontend.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: bankportal
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: frontend
        image: bankportal/frontend:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 80
        env:
        - name: AUTH_SERVICE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: AUTH_SERVICE_URL
        - name: ACCOUNT_SERVICE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: ACCOUNT_SERVICE_URL
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: bankportal
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: NodePort
EOF
}

# Continue in next part...
echo -e "${GREEN}✅ Service Manifeste erstellt${NC}"
# Create monitoring manifests
create_monitoring_manifests() {
    if [ "$MONITORING_ENABLED" = true ]; then
        echo -e "${CYAN}   📊 Erstelle Monitoring Manifeste...${NC}"
        
        # Prometheus
        cat > $K8S_DIR/monitoring/prometheus.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  namespace: bankportal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:latest
        ports:
        - containerPort: 9090
        args:
        - '--config.file=/etc/prometheus/prometheus.yml'
        - '--storage.tsdb.path=/prometheus/'
        - '--web.console.libraries=/etc/prometheus/console_libraries'
        - '--web.console.templates=/etc/prometheus/consoles'
        - '--web.enable-lifecycle'
        volumeMounts:
        - name: prometheus-config
          mountPath: /etc/prometheus/
        - name: prometheus-storage
          mountPath: /prometheus/
      volumes:
      - name: prometheus-config
        configMap:
          name: prometheus-config
      - name: prometheus-storage
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
  namespace: bankportal
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
  type: NodePort
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: bankportal
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
    - job_name: 'auth-service'
      static_configs:
      - targets: ['auth-service:8081']
      metrics_path: '/actuator/prometheus'
    - job_name: 'account-service'
      static_configs:
      - targets: ['account-service:8082']
      metrics_path: '/actuator/prometheus'
EOF

        # Grafana
        cat > $K8S_DIR/monitoring/grafana.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  namespace: bankportal
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "admin123"
        - name: GF_INSTALL_PLUGINS
          value: "grafana-kubernetes-app"
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
        - name: grafana-config
          mountPath: /etc/grafana/provisioning/
      volumes:
      - name: grafana-storage
        emptyDir: {}
      - name: grafana-config
        configMap:
          name: grafana-config
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
  namespace: bankportal
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
  type: NodePort
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-config
  namespace: bankportal
data:
  datasources.yml: |
    apiVersion: 1
    datasources:
    - name: Prometheus
      type: prometheus
      access: proxy
      url: http://prometheus:9090
      isDefault: true
EOF
    fi
}

# Deploy to Kubernetes
deploy_to_kubernetes() {
    echo -e "${BLUE}🚀 Deploye zu Kubernetes...${NC}"
    
    # Deploy base components
    echo -e "${CYAN}   📦 Deploye Basis-Komponenten...${NC}"
    kubectl apply -f $K8S_DIR/base/namespace.yaml
    kubectl apply -f $K8S_DIR/base/configmap.yaml
    kubectl apply -f $K8S_DIR/base/secrets.yaml
    
    # Deploy databases
    echo -e "${CYAN}   🗄️ Deploye Datenbanken...${NC}"
    kubectl apply -f $K8S_DIR/base/postgres-auth.yaml
    kubectl apply -f $K8S_DIR/base/postgres-account.yaml
    
    # Wait for databases
    echo -e "${YELLOW}   ⏳ Warte auf Datenbanken...${NC}"
    kubectl wait --for=condition=ready pod -l app=postgres-auth -n $NAMESPACE --timeout=120s
    kubectl wait --for=condition=ready pod -l app=postgres-account -n $NAMESPACE --timeout=120s
    
    # Deploy services
    echo -e "${CYAN}   🔧 Deploye Services...${NC}"
    kubectl apply -f $K8S_DIR/base/auth-service.yaml
    kubectl apply -f $K8S_DIR/base/account-service.yaml
    kubectl apply -f $K8S_DIR/base/frontend.yaml
    
    # Deploy monitoring
    if [ "$MONITORING_ENABLED" = true ]; then
        echo -e "${CYAN}   📊 Deploye Monitoring...${NC}"
        kubectl apply -f $K8S_DIR/monitoring/
    fi
    
    echo -e "${GREEN}✅ Deployment abgeschlossen${NC}"
}

# Wait for services
wait_for_services() {
    echo -e "${YELLOW}⏳ Warte auf Services...${NC}"
    
    # Wait for deployments
    echo -e "${CYAN}   Warte auf Auth Service...${NC}"
    kubectl wait --for=condition=available deployment/auth-service -n $NAMESPACE --timeout=300s
    
    echo -e "${CYAN}   Warte auf Account Service...${NC}"
    kubectl wait --for=condition=available deployment/account-service -n $NAMESPACE --timeout=300s
    
    echo -e "${CYAN}   Warte auf Frontend...${NC}"
    kubectl wait --for=condition=available deployment/frontend -n $NAMESPACE --timeout=300s
    
    if [ "$MONITORING_ENABLED" = true ]; then
        echo -e "${CYAN}   Warte auf Monitoring Services...${NC}"
        kubectl wait --for=condition=available deployment/prometheus -n $NAMESPACE --timeout=180s || true
        kubectl wait --for=condition=available deployment/grafana -n $NAMESPACE --timeout=180s || true
    fi
    
    echo -e "${GREEN}✅ Alle Services sind bereit${NC}"
}

# Show status
show_status() {
    echo -e "${PURPLE}📊 ======================================"
    echo "   KUBERNETES DEPLOYMENT STATUS"
    echo "======================================${NC}"
    
    # Show pods
    echo -e "${CYAN}🔍 Pods Status:${NC}"
    kubectl get pods -n $NAMESPACE -o wide
    
    echo ""
    echo -e "${CYAN}🌐 Services Status:${NC}"
    kubectl get services -n $NAMESPACE
    
    echo ""
    echo -e "${CYAN}📦 Deployments Status:${NC}"
    kubectl get deployments -n $NAMESPACE
}

# Setup port forwarding
setup_port_forwarding() {
    echo -e "${BLUE}🔗 Setup Port Forwarding...${NC}"
    
    # Kill existing port forwards
    pkill -f "kubectl port-forward" 2>/dev/null || true
    sleep 2
    
    # Start port forwarding in background
    echo -e "${CYAN}   🌐 Frontend Port Forward (4200)...${NC}"
    kubectl port-forward service/frontend 4200:80 -n $NAMESPACE > /dev/null 2>&1 &
    
    echo -e "${CYAN}   🔐 Auth Service Port Forward (8081)...${NC}"
    kubectl port-forward service/auth-service 8081:8081 -n $NAMESPACE > /dev/null 2>&1 &
    
    echo -e "${CYAN}   💼 Account Service Port Forward (8082)...${NC}"
    kubectl port-forward service/account-service 8082:8082 -n $NAMESPACE > /dev/null 2>&1 &
    
    if [ "$MONITORING_ENABLED" = true ]; then
        echo -e "${CYAN}   📊 Prometheus Port Forward (9090)...${NC}"
        kubectl port-forward service/prometheus 9090:9090 -n $NAMESPACE > /dev/null 2>&1 &
        
        echo -e "${CYAN}   📈 Grafana Port Forward (3000)...${NC}"
        kubectl port-forward service/grafana 3000:3000 -n $NAMESPACE > /dev/null 2>&1 &
    fi
    
    # Wait for port forwards to establish
    sleep 5
    echo -e "${GREEN}✅ Port Forwarding aktiv${NC}"
}

# Install Kubernetes Dashboard
install_k8s_dashboard() {
    if [ "$DASHBOARD_ENABLED" = true ]; then
        echo -e "${BLUE}📊 Installiere Kubernetes Dashboard...${NC}"
        
        # Install dashboard
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml > /dev/null 2>&1
        
        # Create admin user
        cat << EOF | kubectl apply -f - > /dev/null 2>&1
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
        
        echo -e "${GREEN}✅ Kubernetes Dashboard installiert${NC}"
    fi
}

# Show access information
show_access_info() {
    echo -e "${GREEN}🎉 ======================================"
    echo "   BANK PORTAL KUBERNETES DEMO BEREIT!"
    echo "======================================${NC}"
    
    echo ""
    echo -e "${PURPLE}🌐 Service URLs (Port Forwarding):${NC}"
    echo -e "${CYAN}   Frontend:        http://localhost:4200${NC}"
    echo -e "${CYAN}   Auth Service:    http://localhost:8081${NC}"
    echo -e "${CYAN}   Account Service: http://localhost:8082${NC}"
    
    if [ "$MONITORING_ENABLED" = true ]; then
        echo ""
        echo -e "${PURPLE}📊 Monitoring URLs:${NC}"
        echo -e "${CYAN}   Prometheus:      http://localhost:9090${NC}"
        echo -e "${CYAN}   Grafana:         http://localhost:3000 (admin/admin123)${NC}"
    fi
    
    if [ "$DASHBOARD_ENABLED" = true ]; then
        echo ""
        echo -e "${PURPLE}📊 Kubernetes Dashboard:${NC}"
        echo -e "${CYAN}   1. Starte Proxy: kubectl proxy${NC}"
        echo -e "${CYAN}   2. URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/${NC}"
        echo -e "${CYAN}   3. Token: kubectl -n kubernetes-dashboard create token admin-user${NC}"
    fi
    
    echo ""
    echo -e "${PURPLE}🧪 Demo-Daten:${NC}"
    echo -e "${CYAN}   Username: demo${NC}"
    echo -e "${CYAN}   Password: demo123${NC}"
    
    echo ""
    echo -e "${PURPLE}🛠️ Nützliche Befehle:${NC}"
    echo -e "${CYAN}   Pods anzeigen:     kubectl get pods -n $NAMESPACE${NC}"
    echo -e "${CYAN}   Services anzeigen: kubectl get services -n $NAMESPACE${NC}"
    echo -e "${CYAN}   Logs anzeigen:     kubectl logs -f deployment/auth-service -n $NAMESPACE${NC}"
    echo -e "${CYAN}   Demo stoppen:      ./scripts/stop-k8s-demo.sh${NC}"
    
    echo ""
    echo -e "${GREEN}🚀 Viel Spaß beim Kubernetes Lernen!${NC}"
}

# Main execution
main() {
    check_prerequisites
    build_images
    load_images_to_cluster
    create_k8s_manifests
    create_database_manifests
    create_service_manifests
    create_monitoring_manifests
    deploy_to_kubernetes
    wait_for_services
    install_k8s_dashboard
    show_status
    setup_port_forwarding
    show_access_info
}

# Handle script arguments
case "${1:-}" in
    --no-monitoring)
        MONITORING_ENABLED=false
        ;;
    --no-dashboard)
        DASHBOARD_ENABLED=false
        ;;
    --minimal)
        MONITORING_ENABLED=false
        DASHBOARD_ENABLED=false
        ;;
    --help)
        echo "Bank Portal Kubernetes Demo Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --no-monitoring  Disable Prometheus/Grafana"
        echo "  --no-dashboard   Disable Kubernetes Dashboard"
        echo "  --minimal        Disable monitoring and dashboard"
        echo "  --help           Show this help"
        exit 0
        ;;
esac

# Run main function
main
