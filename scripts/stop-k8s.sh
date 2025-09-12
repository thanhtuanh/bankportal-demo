#!/usr/bin/env bash

# ⏹️ Stop-K8s (modular): Fährt die Demo strukturiert herunter.
# Optionen:
#   --keep-files      Behalte generierte YAML‑Manifeste
#   --keep-dashboard  Behalte Kubernetes Dashboard
#   --force          Ignoriere Fehler und fahre fort

set -Eeuo pipefail
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

KEEP_FILES=false
KEEP_DASHBOARD=false
FORCE=false

for arg in "$@"; do
  case "$arg" in
    --keep-files)     KEEP_FILES=true ;;
    --keep-dashboard) KEEP_DASHBOARD=true ;;
    --force)          FORCE=true ;;
    --help)
      echo "Stoppt die modularen K8s-Schritte (Cleanup)"
      echo "Usage: $0 [--keep-files] [--keep-dashboard] [--force]"
      exit 0
      ;;
  esac
done

# Flags an die gesourcten Funktionen weitergeben, indem wir Stop-Skript mit
# alternativen Funktions-Implementierungen vorbereiten
if $KEEP_FILES; then
  # Überschreibe cleanup-Funktion zur Laufzeit
  export SKIP_CLEANUP_FILES=1
fi
if $KEEP_DASHBOARD; then
  export SKIP_DELETE_DASHBOARD=1
fi
if $FORCE; then
  set +e
fi

"${BASE_DIR}/k8s/stop-10-port-forward.sh"
"${BASE_DIR}/k8s/stop-20-delete-resources.sh"

if ! $KEEP_DASHBOARD; then
  "${BASE_DIR}/k8s/stop-30-delete-dashboard.sh"
else
  echo "ℹ️  Dashboard bleibt erhalten (--keep-dashboard)"
fi

if ! $KEEP_FILES; then
  "${BASE_DIR}/k8s/stop-40-cleanup-files.sh"
else
  echo "ℹ️  Generierte Dateien bleiben erhalten (--keep-files)"
fi

echo ""
echo "✅ Stop-Cleanup abgeschlossen."

