#!/usr/bin/env bash
# 01-check.sh — Voraussetzungen für Kubernetes-Demo prüfen
# Prüft auf kubectl, docker und Cluster-Verfügbarkeit

. "$(dirname "$0")/../common.sh"
banner "🔍 Voraussetzungen prüfen"

# Erforderliche Tools prüfen
need kubectl
need docker

# Cluster-Verbindung prüfen
if ! kubectl cluster-info >/dev/null 2>&1; then
  err "Kein Kubernetes-Cluster erreichbar. Starte Minikube, Docker Desktop K8s oder Kind."
fi
ok "kubectl und Cluster erreichbar"
kubectl cluster-info | head -2 || true
