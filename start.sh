#!/bin/bash
echo "🚀 Starting Bank Portal Application..."

# Start with Docker Compose
docker-compose up --build -d

echo "🎉 Application started successfully!"
echo ""
echo "📱 Frontend: http://localhost:4200"
echo "🔐 Auth Service: http://localhost:8081"
echo "💳 Account Service: http://localhost:8082"
echo ""
echo "👤 Test Users:"
echo "   Username: testuser, Password: test123"
echo "   Username: admin, Password: test123"
