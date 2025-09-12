#!/usr/bin/env bash

# 🛑 Schritt Stop-40: Generierte Dateien bereinigen
# Löscht den temporären Ordner mit generierten YAML‑Manifesten.

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../stop-k8s-demo.sh"

cleanup_generated_files
show_final_status
echo -e "${GREEN}✅ Dateien bereinigt${NC}"

