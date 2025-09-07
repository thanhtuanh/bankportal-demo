#!/usr/bin/env bash
# start-k8s.sh — Wrapper zum Starten der Bank Portal Kubernetes-Demo
# Zweck: Führt alle Start-Sub-Skripte sequentiell aus und verarbeitet Kommandozeilenargumente
# Argumente:
#   --no-monitoring: Deaktiviert Prometheus und Grafana
#   --no-dashboard: Deaktiviert das Kubernetes Dashboard
# Hinweis: Umgebungsvariablen (NAMESPACE, K8S_DIR, etc.) können überschrieben werden

set -euo pipefail

# Pfad zum Skript-Verzeichnis
BASE="$(cd "$(dirname "$0")" && pwd)/k8s"
# Standardwerte für Umgebungsvariablen
export NAMESPACE="${NAMESPACE:-bankportal}"
export K8S_DIR="${K8S_DIR:-temp-k8s-files}"
export MONITORING_ENABLED="${MONITORING_ENABLED:-true}"
export DASHBOARD_ENABLED="${DASHBOARD_ENABLED:-true}"

# Argumente verarbeiten
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-monitoring) MONITORING_ENABLED=false; shift ;;
    --no-dashboard) DASHBOARD_ENABLED=false; shift ;;
    *) echo "Unbekanntes Argument: $1"; exit 1 ;;
  esac
done

# Einbinden der gemeinsamen Funktionen
. "${BASE}/common.sh"
banner "🚀 BANK PORTAL – K8s START (Namespace: $NAMESPACE)"

# Sub-Skripte ausführen
for s in 01-check 02-build-images 03-load-images 04-generate-manifests 05-apply 06-wait 07-dashboard 08-status 09-port-forward 10-access-info; do
  if [ -f "${BASE}/start/${s}.sh" ]; then
    "${BASE}/start/${s}.sh"
  else
    err "Skript ${BASE}/start/${s}.sh nicht gefunden"
  fi
done

ok "Kubernetes-Demo erfolgreich gestartet"