# 1. Prüfen ob Account Service läuft
curl http://localhost:8082/api/accounts
# Sollte 403 Forbidden zeigen (das ist korrekt ohne Token)

# 2. Mit JWT Token testen
# Erst Token vom Login holen:
TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"myuser","password":"test123"}' | jq -r '.token')

echo "Token: $TOKEN"

# 3. Mit Token Accounts abrufen
curl -H "Authorization: Bearer $TOKEN" http://localhost:8082/api/accounts
