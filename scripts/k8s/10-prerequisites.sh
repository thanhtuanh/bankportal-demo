#!/usr/bin/env bash

# 📘 Schritt 10: Voraussetzungen prüfen
# Dieses Skript prüft, ob kubectl, ein laufender Kubernetes‑Cluster
# (z. B. minikube/kind/Docker Desktop) und Docker verfügbar sind.
# So lernst du: Ohne funktionsfähige Tools kann kein Deployment erfolgen.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Funktionen aus dem Demo-Skript einbinden (ohne direkten Start)
source "${SCRIPT_DIR}/../start-k8s-demo.sh"

check_prerequisites

echo -e "${GREEN}✅ Voraussetzungen erfüllt – weiter mit Schritt 20 (Images bauen)${NC}"

