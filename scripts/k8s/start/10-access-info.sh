#!/usr/bin/env bash
# 10-access-info.sh — Zugriffsinformationen anzeigen
# Zeigt URLs, Logins und nützliche Befehle

. "$(dirname "$0")/../common.sh"
banner "🎉 Zugriff"

echo -e "${PURPLE}🌐 Service URLs (Port Forwarding):${NC}"
echo -e "${CYAN}   Frontend:        http://localhost:4200${NC}"
echo -e "${CYAN}   Auth Service:    http://localhost:8081${NC}"
echo -e "${CYAN}   Account Service: http://localhost:8082${NC}"

if [ "${MONITORING_ENABLED}" = "true" ]; then
  echo -e "${PURPLE}📊 Monitoring URLs:${NC}"
  echo -e "${CYAN}   Prometheus:      http://localhost:9090${NC}"
  echo -e "${CYAN}   Grafana:         http://localhost:3000 (admin/admin123)${NC}"
fi

if [ "${DASHBOARD_ENABLED}" = "true" ]; then
  echo -e "${PURPLE}📊 Kubernetes Dashboard:${NC}"
  echo -e "${CYAN}   1. Starte Proxy: kubectl proxy${NC}"
  echo -e "${CYAN}   2. URL: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/${NC}"
  echo -e "${CYAN}   3. Token: kubectl -n kubernetes-dashboard create token admin-user${NC}"
fi

echo -e "${PURPLE}🧪 Demo-Daten:${NC}"
echo -e "${CYAN}   Username: demo${NC}"
echo -e "${CYAN}   Password: demo123${NC}"

echo -e "${PURPLE}🛠️ Nützliche Befehle:${NC}"
echo -e "${CYAN}   Pods anzeigen:     kubectl get pods -n $NAMESPACE${NC}"
echo -e "${CYAN}   Services anzeigen: kubectl get services -n $NAMESPACE${NC}"
echo -e "${CYAN}   Logs anzeigen:     kubectl logs -f deployment/auth-service -n $NAMESPACE${NC}"
echo -e "${CYAN}   Demo stoppen:      ./scripts/k8s/stop-k8s.sh${NC}"
