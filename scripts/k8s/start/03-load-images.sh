#!/usr/bin/env bash
# 03-load-images.sh — Docker-Images in Kubernetes-Cluster laden
# Handhabt das Laden von Images für Minikube, Kind oder Docker Desktop

. "$(dirname "$0")/../common.sh"
banner "📤 Images in Cluster laden"

ctype="$(detect_cluster_type)"
case "$ctype" in
  minikube)
    log "Minikube: Images laden"
    minikube image load bankportal/auth-service:latest
    minikube image load bankportal/account-service:latest
    minikube image load bankportal/frontend:latest
    ;;
  kind)
    cname="$(kubectl config current-context | sed 's/kind-//')"
    log "Kind: Images in Cluster ${cname} laden"
    kind load docker-image bankportal/auth-service:latest --name "$cname"
    kind load docker-image bankportal/account-service:latest --name "$cname"
    kind load docker-image bankportal/frontend:latest --name "$cname"
    ;;
  docker-desktop)
    log "Docker Desktop: Images lokal verfügbar"
    ;;
  *)
    warn "Unbekannter Cluster-Typ – Images manuell sicherstellen"
    ;;
esac
ok "Images geladen oder verfügbar"
