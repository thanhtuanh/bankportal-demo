#!/bin/bash

# 🛑 Bank Portal - Kubernetes Demo Stop Script
# 🎯 Sauberes Herunterfahren des K8s Demos

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
K8S_DIR="k8s"

# Banner
echo -e "${RED}"
echo "🛑 =============================================="
echo "   BANK PORTAL - KUBERNETES DEMO STOP"
echo "   Sauberes Herunterfahren"
echo "===============================================${NC}"
echo ""

# Stop port forwarding
stop_port_forwarding() {
    echo -e "${YELLOW}🔗 Stoppe Port Forwarding...${NC}"
    
    # Kill all kubectl port-forward processes
    if pgrep -f "kubectl port-forward" > /dev/null; then
        pkill -f "kubectl port-forward"
        echo -e "${GREEN}✅ Port Forwarding gestoppt${NC}"
    else
        echo -e "${CYAN}ℹ️  Kein aktives Port Forwarding gefunden${NC}"
    fi
}

# Delete Kubernetes resources
delete_k8s_resources() {
    echo -e "${YELLOW}🗑️ Lösche Kubernetes Ressourcen...${NC}"
    
    # Check if namespace exists
    if kubectl get namespace $NAMESPACE > /dev/null 2>&1; then
        echo -e "${CYAN}   🔄 Lösche Services und Deployments...${NC}"
        
        # Delete in reverse order
        if [ -d "$K8S_DIR" ]; then
            # Delete monitoring
            if [ -d "$K8S_DIR/monitoring" ]; then
                kubectl delete -f $K8S_DIR/monitoring/ --ignore-not-found=true
            fi
            
            # Delete services
            if [ -f "$K8S_DIR/base/frontend.yaml" ]; then
                kubectl delete -f $K8S_DIR/base/frontend.yaml --ignore-not-found=true
            fi
            if [ -f "$K8S_DIR/base/account-service.yaml" ]; then
                kubectl delete -f $K8S_DIR/base/account-service.yaml --ignore-not-found=true
            fi
            if [ -f "$K8S_DIR/base/auth-service.yaml" ]; then
                kubectl delete -f $K8S_DIR/base/auth-service.yaml --ignore-not-found=true
            fi
            
            # Delete databases
            if [ -f "$K8S_DIR/base/postgres-account.yaml" ]; then
                kubectl delete -f $K8S_DIR/base/postgres-account.yaml --ignore-not-found=true
            fi
            if [ -f "$K8S_DIR/base/postgres-auth.yaml" ]; then
                kubectl delete -f $K8S_DIR/base/postgres-auth.yaml --ignore-not-found=true
            fi
            
            # Delete config
            if [ -f "$K8S_DIR/base/secrets.yaml" ]; then
                kubectl delete -f $K8S_DIR/base/secrets.yaml --ignore-not-found=true
            fi
            if [ -f "$K8S_DIR/base/configmap.yaml" ]; then
                kubectl delete -f $K8S_DIR/base/configmap.yaml --ignore-not-found=true
            fi
        else
            # Fallback: delete by labels/namespace
            echo -e "${CYAN}   🔄 Lösche alle Ressourcen im Namespace...${NC}"
            kubectl delete all --all -n $NAMESPACE --ignore-not-found=true
            kubectl delete configmaps --all -n $NAMESPACE --ignore-not-found=true
            kubectl delete secrets --all -n $NAMESPACE --ignore-not-found=true
        fi
        
        # Delete namespace
        echo -e "${CYAN}   🗂️ Lösche Namespace...${NC}"
        kubectl delete namespace $NAMESPACE --ignore-not-found=true
        
        echo -e "${GREEN}✅ Kubernetes Ressourcen gelöscht${NC}"
    else
        echo -e "${CYAN}ℹ️  Namespace $NAMESPACE existiert nicht${NC}"
    fi
}

# Delete Kubernetes Dashboard
delete_k8s_dashboard() {
    echo -e "${YELLOW}📊 Lösche Kubernetes Dashboard...${NC}"
    
    # Delete admin user
    kubectl delete clusterrolebinding admin-user --ignore-not-found=true
    kubectl delete serviceaccount admin-user -n kubernetes-dashboard --ignore-not-found=true
    
    # Delete dashboard
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml --ignore-not-found=true > /dev/null 2>&1 || true
    
    echo -e "${GREEN}✅ Kubernetes Dashboard gelöscht${NC}"
}

# Show final status
show_final_status() {
    echo -e "${BLUE}📊 Finale Status-Überprüfung...${NC}"
    
    # Check remaining resources
    if kubectl get namespace $NAMESPACE > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Namespace $NAMESPACE existiert noch${NC}"
        kubectl get all -n $NAMESPACE 2>/dev/null || true
    else
        echo -e "${GREEN}✅ Namespace $NAMESPACE erfolgreich gelöscht${NC}"
    fi
    
    # Check port forwarding
    if pgrep -f "kubectl port-forward" > /dev/null; then
        echo -e "${YELLOW}⚠️  Port Forwarding Prozesse noch aktiv:${NC}"
        pgrep -f "kubectl port-forward" | head -5
    else
        echo -e "${GREEN}✅ Kein aktives Port Forwarding${NC}"
    fi
}

# Show cleanup summary
show_cleanup_summary() {
    echo -e "${GREEN}🎉 ======================================"
    echo "   KUBERNETES DEMO CLEANUP ABGESCHLOSSEN"
    echo "======================================${NC}"
    
    echo ""
    echo -e "${PURPLE}🧹 Was wurde bereinigt:${NC}"
    echo -e "${CYAN}   ✅ Port Forwarding gestoppt${NC}"
    echo -e "${CYAN}   ✅ Kubernetes Ressourcen gelöscht${NC}"
    echo -e "${CYAN}   ✅ Namespace '$NAMESPACE' entfernt${NC}"
    echo -e "${CYAN}   ✅ Kubernetes Dashboard entfernt${NC}"
    echo -e "${CYAN}   ✅ Generierte Manifeste gelöscht${NC}"
    
    echo ""
    echo -e "${PURPLE}🔄 Zum Neustart:${NC}"
    echo -e "${CYAN}   ./scripts/start-k8s-demo.sh${NC}"
    
    echo ""
    echo -e "${PURPLE}🛠️ Nützliche Befehle:${NC}"
    echo -e "${CYAN}   Cluster Status:    kubectl cluster-info${NC}"
    echo -e "${CYAN}   Alle Namespaces:   kubectl get namespaces${NC}"
    echo -e "${CYAN}   Aktive Prozesse:   ps aux | grep kubectl${NC}"
    
    echo ""
    echo -e "${GREEN}✨ Demo erfolgreich gestoppt!${NC}"
}

# Main execution
main() {
    stop_port_forwarding
    delete_k8s_resources
    delete_k8s_dashboard
    cleanup_generated_files
    show_final_status
    show_cleanup_summary
}

# Handle script arguments
case "${1:-}" in
    --keep-files)
        echo -e "${YELLOW}ℹ️  Behalte generierte Dateien${NC}"
        cleanup_generated_files() { echo -e "${CYAN}ℹ️  Überspringe Datei-Bereinigung${NC}"; }
        ;;
    --keep-dashboard)
        echo -e "${YELLOW}ℹ️  Behalte Kubernetes Dashboard${NC}"
        delete_k8s_dashboard() { echo -e "${CYAN}ℹ️  Überspringe Dashboard-Löschung${NC}"; }
        ;;
    --force)
        echo -e "${YELLOW}⚡ Force-Modus aktiviert${NC}"
        set +e  # Continue on errors
        ;;
    --help)
        echo "Bank Portal Kubernetes Demo Stop Script"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --keep-files     Behalte generierte K8s Manifeste"
        echo "  --keep-dashboard Behalte Kubernetes Dashboard"
        echo "  --force          Ignoriere Fehler und fahre fort"
        echo "  --help           Zeige diese Hilfe"
        exit 0
        ;;
esac

# Run main function
main
