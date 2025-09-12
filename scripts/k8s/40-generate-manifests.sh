#!/usr/bin/env bash

# 📘 Schritt 40: Kubernetes‑Manifeste generieren
# Die Demo erzeugt YAML‑Dateien unter `temp-k8s-files`, u. a. Namespace,
# ConfigMap/Secrets, Datenbanken und Services.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../start-k8s-demo.sh"

create_k8s_manifests
create_database_manifests
create_service_manifests

if [[ "${MONITORING_ENABLED:-true}" == "true" ]]; then
  create_monitoring_manifests
fi

echo -e "${GREEN}✅ Manifeste erzeugt – weiter mit Schritt 50 (Deploy)${NC}"

