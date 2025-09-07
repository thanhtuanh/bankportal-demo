#!/usr/bin/env bash
# 04-clean-files.sh — Generierte Dateien löschen
# Entfernt den temp-k8s-files Ordner

. "$(dirname "$0")/../common.sh"
banner "🧹 Generierte Dateien löschen"

[ -d "${K8S_DIR}" ] && { rm -rf "${K8S_DIR}"; ok "Ordner ${K8S_DIR} gelöscht"; } || warn "Kein ${K8S_DIR} gefunden"
