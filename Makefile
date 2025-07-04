.PHONY: help dev test clean status

help: ## Zeige verfügbare Befehle
	@echo "🏦 Bankportal Demo - PostgreSQL 15"
	@echo "=================================="
	@echo ""
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

dev: ## Lokale Entwicklung starten
	@echo "🚀 Starte lokale Entwicklung..."
	docker-compose up -d postgres-auth postgres-account
	docker build -t bankportal-frontend:test frontend/
	docker run -d -p 8080:80 --name frontend-dev bankportal-frontend:test

test-db: ## Teste PostgreSQL 15 Datenbanken
	@echo "🗄️ Teste PostgreSQL 15..."
	docker exec postgres-auth pg_isready -U admin -d authdb
	docker exec postgres-account pg_isready -U admin -d accountdb
	docker exec postgres-auth psql -U admin -d authdb -c "SELECT version();"

test-frontend: ## Teste Frontend
	@echo "🎨 Teste Frontend..."
	curl -f http://localhost:8080 || echo "❌ Frontend nicht erreichbar"
	curl -f http://localhost:8080/health || echo "❌ Frontend Health Check fehlgeschlagen"

status: ## Zeige Status aller Services
	@echo "📊 Service Status:"
	@echo "Frontend:"
	@docker ps | grep frontend || echo "Frontend nicht aktiv"
	@echo "PostgreSQL:"
	@docker-compose ps

clean: ## Cleanup alle Container
	@echo "🧹 Cleanup..."
	docker stop frontend-dev frontend-test 2>/dev/null || true
	docker rm frontend-dev frontend-test 2>/dev/null || true
	docker-compose down

logs: ## Zeige Logs
	@echo "📜 Logs:"
	@docker logs frontend-dev 2>/dev/null || docker logs frontend-test 2>/dev/null || echo "Keine Frontend Logs"
	@docker-compose logs postgres-auth postgres-account
