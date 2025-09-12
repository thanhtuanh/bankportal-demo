#!/usr/bin/env bash

# 📘 Schritt 30: Images in den Cluster laden
# Je nach Cluster (minikube/kind/docker-desktop) werden lokale Images in den
# Cluster gebracht, damit kein externes Registry-Push nötig ist.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib.sh"

load_images_to_cluster
echo -e "${GREEN}✅ Images im Cluster verfügbar – weiter mit Schritt 40 (Manifeste generieren)${NC}"
