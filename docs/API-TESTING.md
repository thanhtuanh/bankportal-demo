# 🧪 API Testing Guide

## 📋 Übersicht

Vollständige Anleitung zum Testen der Bank Portal APIs mit curl, Postman und Swagger UI.

## 🔐 Auth Service API (Port 8081)

### **Base URL:** http://localhost:8081/api

### 1. 👤 Benutzer registrieren

```bash
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

**Erwartete Antwort:**
```json
{
  "message": "User registered successfully",
  "username": "testuser"
}
```

### 2. 🔐 JWT Token erhalten

```bash
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'
```

**Erwartete Antwort:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "type": "Bearer",
  "username": "testuser",
  "expiresIn": 86400
}
```

### 3. 🔍 Token validieren

```bash
# Token in Variable speichern
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET http://localhost:8081/api/auth/validate \
  -H "Authorization: Bearer $TOKEN"
```

**Erwartete Antwort:**
```json
{
  "valid": true,
  "username": "testuser",
  "expiresAt": "2024-07-06T10:30:00Z"
}
```

## 💼 Account Service API (Port 8082)

### **Base URL:** http://localhost:8082/api

### 1. 💳 Konto erstellen

```bash
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "owner": "testuser",
    "balance": 1000.0,
    "accountType": "CHECKING"
  }'
```

**Erwartete Antwort:**
```json
{
  "id": 1,
  "owner": "testuser",
  "balance": 1000.0,
  "accountType": "CHECKING",
  "createdAt": "2024-07-05T10:30:00Z"
}
```

### 2. 📊 Alle Konten anzeigen

```bash
curl -X GET http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN"
```

**Erwartete Antwort:**
```json
[
  {
    "id": 1,
    "owner": "testuser",
    "balance": 1000.0,
    "accountType": "CHECKING",
    "createdAt": "2024-07-05T10:30:00Z"
  }
]
```

### 3. 🔍 Einzelnes Konto anzeigen

```bash
curl -X GET http://localhost:8082/api/accounts/1 \
  -H "Authorization: Bearer $TOKEN"
```

### 4. 💸 Geld überweisen

```bash
# Erst zweites Konto erstellen
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "owner": "testuser",
    "balance": 500.0,
    "accountType": "SAVINGS"
  }'

# Dann Überweisung durchführen
curl -X POST http://localhost:8082/api/accounts/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fromAccountId": 1,
    "toAccountId": 2,
    "amount": 100.0,
    "description": "Test transfer"
  }'
```

**Erwartete Antwort:**
```json
{
  "transactionId": "tx_123456789",
  "fromAccountId": 1,
  "toAccountId": 2,
  "amount": 100.0,
  "description": "Test transfer",
  "timestamp": "2024-07-05T10:35:00Z",
  "status": "COMPLETED"
}
```

### 5. 📋 Transaktionshistorie

```bash
curl -X GET http://localhost:8082/api/accounts/1/transactions \
  -H "Authorization: Bearer $TOKEN"
```

**Erwartete Antwort:**
```json
[
  {
    "id": 1,
    "accountId": 1,
    "type": "TRANSFER_OUT",
    "amount": -100.0,
    "description": "Test transfer",
    "timestamp": "2024-07-05T10:35:00Z",
    "balanceAfter": 900.0
  }
]
```

## 🔍 Health Checks

### Auth Service Health
```bash
curl http://localhost:8081/api/health
```

### Account Service Health
```bash
curl http://localhost:8082/api/health
```

### Detailed Health Information
```bash
curl http://localhost:8081/actuator/health
curl http://localhost:8082/actuator/health
```

## 📊 Swagger UI Testing

### Auth Service Swagger
- **URL:** http://localhost:8081/swagger-ui/index.html
- **Features:** Interactive API testing, Request/Response examples
- **Authentication:** Bearer Token nach Login

### Account Service Swagger
- **URL:** http://localhost:8082/swagger-ui/index.html
- **Features:** Interactive API testing, Request/Response examples
- **Authentication:** Bearer Token erforderlich

### Swagger UI Workflow:
1. **Auth Service Swagger öffnen**
2. **POST /api/auth/login** ausführen
3. **Token kopieren**
4. **"Authorize" Button** klicken
5. **"Bearer TOKEN_HIER_EINFÜGEN"** eingeben
6. **Account Service Swagger öffnen**
7. **Gleichen Token verwenden**

## 🧪 Vollständiges Test-Szenario

### Automatisiertes Test-Script:

```bash
#!/bin/bash

# Bank Portal API Test Script
echo "🧪 Starting Bank Portal API Tests..."

BASE_AUTH="http://localhost:8081/api"
BASE_ACCOUNT="http://localhost:8082/api"

# 1. Benutzer registrieren
echo "👤 Registering user..."
curl -s -X POST $BASE_AUTH/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "apitest", "password": "test123"}' | jq

# 2. JWT Token erhalten
echo "🔐 Getting JWT token..."
TOKEN=$(curl -s -X POST $BASE_AUTH/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "apitest", "password": "test123"}' \
  | jq -r '.token')

echo "Token: ${TOKEN:0:50}..."

# 3. Erstes Konto erstellen
echo "💳 Creating first account..."
ACCOUNT1=$(curl -s -X POST $BASE_ACCOUNT/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"owner": "apitest", "balance": 1000.0}' | jq)

echo "Account 1: $ACCOUNT1"

# 4. Zweites Konto erstellen
echo "💳 Creating second account..."
ACCOUNT2=$(curl -s -X POST $BASE_ACCOUNT/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"owner": "apitest", "balance": 500.0}' | jq)

echo "Account 2: $ACCOUNT2"

# 5. Alle Konten anzeigen
echo "📊 Listing all accounts..."
curl -s -X GET $BASE_ACCOUNT/accounts \
  -H "Authorization: Bearer $TOKEN" | jq

# 6. Geld überweisen
echo "💸 Transferring money..."
curl -s -X POST $BASE_ACCOUNT/accounts/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fromAccountId": 1, "toAccountId": 2, "amount": 100.0}' | jq

# 7. Finale Kontostände
echo "📈 Final account balances..."
curl -s -X GET $BASE_ACCOUNT/accounts \
  -H "Authorization: Bearer $TOKEN" | jq

echo "✅ API Tests completed!"
```

## 📱 Postman Collection

### Import-URL:
```
https://raw.githubusercontent.com/thanhtuanh/bankportal-demo/main/docs/postman/bankportal-collection.json
```

### Postman Environment Variables:
```json
{
  "auth_base_url": "http://localhost:8081/api",
  "account_base_url": "http://localhost:8082/api",
  "jwt_token": "{{token}}",
  "username": "testuser",
  "password": "password123"
}
```

## 🔧 Erweiterte Tests

### Performance Testing
```bash
# Load Testing mit Apache Bench
ab -n 1000 -c 10 -H "Authorization: Bearer $TOKEN" \
  http://localhost:8082/api/accounts

# Concurrent User Testing
for i in {1..10}; do
  curl -X GET http://localhost:8082/api/accounts \
    -H "Authorization: Bearer $TOKEN" &
done
wait
```

### Error Handling Tests
```bash
# Invalid Token
curl -X GET http://localhost:8082/api/accounts \
  -H "Authorization: Bearer invalid_token"

# Missing Authorization
curl -X GET http://localhost:8082/api/accounts

# Invalid JSON
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"invalid": json}'

# Insufficient Funds
curl -X POST http://localhost:8082/api/accounts/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fromAccountId": 1, "toAccountId": 2, "amount": 99999.0}'
```

## 📊 Monitoring & Metrics

### Prometheus Metrics
```bash
# Auth Service Metrics
curl http://localhost:8081/actuator/prometheus

# Account Service Metrics
curl http://localhost:8082/actuator/prometheus

# Custom Business Metrics
curl http://localhost:8082/actuator/metrics/accounts.created
curl http://localhost:8082/actuator/metrics/transfers.completed
```

## 🛠️ Troubleshooting

### Häufige Probleme:

**Problem:** "401 Unauthorized"
```bash
# Lösung: Neuen Token generieren
TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "password": "password123"}' \
  | jq -r '.token')
```

**Problem:** "Connection refused"
```bash
# Lösung: Services Status prüfen
docker-compose ps
curl http://localhost:8081/api/health
curl http://localhost:8082/api/health
```

**Problem:** "Invalid JSON"
```bash
# Lösung: JSON Syntax prüfen
echo '{"username": "test"}' | jq  # Sollte formatiert ausgeben
```

## 🎯 Quick Commands

```bash
# Kompletter Test-Workflow
./scripts/test-api.sh

# Nur Auth Service testen
./scripts/test-auth-service.sh

# Health Checks
curl http://localhost:8081/api/health && curl http://localhost:8082/api/health

# Token generieren und speichern
export TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' | jq -r '.token')
```

**🧪 Mit diesen Tests können Sie alle API-Funktionen vollständig validieren!**
