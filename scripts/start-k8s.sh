#!/usr/bin/env bash

# ▶️ Start-K8s (modular): Führt die einzelnen Tutorial-Schritte nacheinander aus.
# Optionen:
#   --no-monitoring   Prometheus/Grafana nicht bereitstellen
#   --no-dashboard    Kubernetes Dashboard nicht installieren
#   --minimal         Beides deaktivieren

set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Standard-Flags (können via CLI geändert werden)
export MONITORING_ENABLED=true
export DASHBOARD_ENABLED=true

for arg in "$@"; do
  case "$arg" in
    --no-monitoring) export MONITORING_ENABLED=false ;;
    --no-dashboard)  export DASHBOARD_ENABLED=false  ;;
    --minimal)       export MONITORING_ENABLED=false; export DASHBOARD_ENABLED=false ;;
    --help)
      echo "Startet die modularen K8s-Schritte als Tutorial"
      echo "Usage: $0 [--no-monitoring] [--no-dashboard] [--minimal]"
      exit 0
      ;;
  esac
done

"${BASE_DIR}/k8s/10-prerequisites.sh"
"${BASE_DIR}/k8s/20-build-images.sh"
"${BASE_DIR}/k8s/30-load-images.sh"
"${BASE_DIR}/k8s/40-generate-manifests.sh"
"${BASE_DIR}/k8s/50-deploy.sh"
"${BASE_DIR}/k8s/60-wait-and-status.sh"
"${BASE_DIR}/k8s/70-port-forward.sh"
"${BASE_DIR}/k8s/80-dashboard.sh"

echo ""
echo "🎉 Alle Schritte abgeschlossen. Viel Erfolg beim Ausprobieren!"

