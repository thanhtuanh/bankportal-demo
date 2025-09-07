#!/usr/bin/env bash
# common.sh — Gemeinsame Hilfsfunktionen für Kubernetes-Demo-Skripte
# Bietet Farben, Logging und gängige Funktionen für Start/Stop-Skripte

set -euo pipefail

# Farben für Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # Keine Farbe

# Repo-Root ermitteln und dorthin wechseln
if command -v git >/dev/null 2>&1 && git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
cd "${REPO_ROOT}"

# Standardkonfiguration (überschreibbar via Umgebungsvariablen)
: "${NAMESPACE:=bankportal}"
: "${K8S_DIR:=temp-k8s-files}"
: "${MONITORING_ENABLED:=true}"
: "${DASHBOARD_ENABLED:=true}"

# Logging-Funktionen
log()  { echo -e "${BLUE}[INFO]${NC} $*"; }
ok()   { echo -e "${GREEN}[OK]${NC}   $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err()  { echo -e "${RED}[ERR]${NC}  $*"; exit 1; }

# Prüfen auf erforderliche Befehle
need() { command -v "$1" >/dev/null 2>&1 || err "$1 ist nicht installiert."; }

# Kubernetes-Cluster-Typ erkennen
detect_cluster_type() {
  local ctx
  ctx="$(kubectl config current-context 2>/dev/null || echo '')"
  if   [[ "$ctx" == *minikube*       ]]; then echo "minikube"
  elif [[ "$ctx" == kind*            ]]; then echo "kind"
  elif [[ "$ctx" == *docker-desktop* ]]; then echo "docker-desktop"
  else echo "unknown"; fi
}

# Banner anzeigen
banner() { echo -e "${PURPLE}================================================${NC}\n${PURPLE}$*${NC}\n${PURPLE}================================================${NC}"; }

# Port-Forwarding für einen Service neu starten
pf_restart() {
  local svc="$1" lport="$2" cport="$3"
  pkill -f "kubectl port-forward.*${svc}" 2>/dev/null || true
  (kubectl -n "${NAMESPACE}" port-forward "svc/${svc}" "${lport}:${cport}" >/dev/null 2>&1 &)
}
