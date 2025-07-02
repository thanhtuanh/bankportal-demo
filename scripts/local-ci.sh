#!/bin/bash
# scripts/local-ci.sh
set -e

echo "🚀 Starting Local CI/CD Pipeline..."

# Frontend
echo "📱 Building and Testing Frontend..."
cd frontend
npm ci
npm run lint
npm run test:ci
npm run build:prod
cd ..

# Auth Service
echo "🔐 Building and Testing Auth Service..."
cd auth-service
mvn clean test
mvn package -DskipTests
cd ..

# Account Service
echo "💳 Building and Testing Account Service..."
cd account-service
mvn clean test
mvn package -DskipTests
cd ..

# Docker Build
echo "🐳 Building Docker Images..."
docker-compose build

echo "✅ Local CI/CD completed successfully!"