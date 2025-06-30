#!/bin/bash
echo "🏗️ Building Bank Portal Application..."

# Build Auth Service
echo "📦 Building Auth Service..."
cd auth-service
mvn clean package -DskipTests
cd ..

# Build Account Service  
echo "📦 Building Account Service..."
cd account-service
mvn clean package -DskipTests
cd ..

# Build Frontend
echo "📦 Building Frontend..."
cd frontend

# Clear npm cache and node_modules
echo "🧹 Cleaning npm cache..."
rm -rf node_modules package-lock.json
npm cache clean --force

# Install dependencies with legacy peer deps
echo "📦 Installing dependencies..."
npm install --legacy-peer-deps

# Build the application
echo "🔨 Building Angular application..."
npm run build:prod

cd ..

echo "✅ Build completed successfully!"