#!/bin/bash
# scripts/deploy-local.sh
set -e

echo "📦 Deploying to local Kubernetes..."

# Apply PostgreSQL first
kubectl apply -f k8s/postgres.yaml

# Wait for PostgreSQL
kubectl wait --for=condition=ready pod -l app=postgres-auth -n bankportal-dev --timeout=300s
kubectl wait --for=condition=ready pod -l app=postgres-account -n bankportal-dev --timeout=300s

# Deploy services
export IMAGE_TAG=latest
envsubst < k8s/dev/deployment.yaml | kubectl apply -f -

# Wait for deployment
kubectl wait --for=condition=available --timeout=300s deployment/bankportal-frontend -n bankportal-dev
kubectl wait --for=condition=available --timeout=300s deployment/bankportal-account-service -n bankportal-dev

echo "✅ Deployment completed!"