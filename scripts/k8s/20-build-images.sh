#!/usr/bin/env bash

# 📘 Schritt 20: Docker-Images bauen
# Wir bauen die Images für Auth‑Service, Account‑Service und Frontend lokal.
# So lernst du: Images kapseln deine Anwendung für alle Cluster-Typen gleich.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../start-k8s-demo.sh"

build_images
echo -e "${GREEN}✅ Images gebaut – weiter mit Schritt 30 (Images in den Cluster laden)${NC}"

