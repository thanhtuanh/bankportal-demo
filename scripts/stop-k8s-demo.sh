#!/usr/bin/env bash
# stop-k8s.sh — Wrapper zum Stoppen der Bank Portal Kubernetes-Demo
# Zweck: Führt alle Stop-Sub-Skripte sequentiell aus und verarbeitet Kommandozeilenargumente
# Argumente:
#   --keep-files: Behält generierte Manifeste (temp-k8s-files) bei
#   --keep-dashboard: Behält das Kubernetes Dashboard
# Hinweis: Umgebungsvariablen (NAMESPACE, K8S_DIR, etc.) können überschrieben werden

set -euo pipefail

# Pfad zum Skript-Verzeichnis
BASE="$(cd "$(dirname "$0")" && pwd)/k8s"
# Standardwerte für Umgebungsvariablen
export NAMESPACE="${NAMESPACE:-bankportal}"
export K8S_DIR="${K8S_DIR:-temp-k8s-files}"
KEEP_FILES=false
KEEP_DASHBOARD=false

# Argumente verarbeiten
while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-files) KEEP_FILES=true; shift ;;
    --keep-dashboard) KEEP_DASHBOARD=true; shift ;;
    *) echo "Unbekanntes Argument: $1"; exit 1 ;;
  esac
done

# Einbinden der gemeinsamen Funktionen
. "${BASE}/common.sh"
banner "🛑 BANK PORTAL – K8s STOP (Namespace: $NAMESPACE)"

# Sub-Skripte ausführen, abhängig von Argumenten
for s in 01-stop-port-forward 02-delete-resources; do
  if [ -f "${BASE}/stop/${s}.sh" ]; then
    "${BASE}/stop/${s}.sh"
  else
    err "Skript ${BASE}/stop/${s}.sh nicht gefunden"
  fi
done

# Dashboard nur löschen, wenn --keep-dashboard nicht gesetzt ist
if [ "$KEEP_DASHBOARD" != "true" ]; then
  if [ -f "${BASE}/stop/03-delete-dashboard.sh" ]; then
    "${BASE}/stop/03-delete-dashboard.sh"
  else
    err "Skript ${BASE}/stop/03-delete-dashboard.sh nicht gefunden"
  fi
fi

# Dateien nur löschen, wenn --keep-files nicht gesetzt ist
if [ "$KEEP_FILES" != "true" ]; then
  if [ -f "${BASE}/stop/04-clean-files.sh" ]; then
    "${BASE}/stop/04-clean-files.sh"
  else
    err "Skript ${BASE}/stop/04-clean-files.sh nicht gefunden"
  fi
fi

# Zusammenfassung anzeigen
if [ -f "${BASE}/stop/05-summary.sh" ]; then
  "${BASE}/stop/05-summary.sh"
else
  err "Skript ${BASE}/stop/05-summary.sh nicht gefunden"
fi

ok "Kubernetes-Demo erfolgreich gestoppt"