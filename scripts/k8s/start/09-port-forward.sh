#!/usr/bin/env bash
# 09-port-forward.sh — Port-Forwarding einrichten
# Startet Port-Forwards für alle Services

. "$(dirname "$0")/../common.sh"
banner "🔗 Port-Forwarding"

pkill -f "kubectl port-forward" 2>/dev/null || true
sleep 2

pf_restart frontend 4200 80
pf_restart auth-service 8081 8081
pf_restart account-service 8082 8082

if [ "${MONITORING_ENABLED}" = "true" ]; then
  pf_restart prometheus 9090 9090
  pf_restart grafana 3000 3000
fi

sleep 5
ok "Port-Forwarding aktiv: 4200/8081/8082 (+ ggf. 9090/3000)"
