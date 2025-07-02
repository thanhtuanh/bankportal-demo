# 1. Benutzer registrieren
curl -X POST http://localhost:8081/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}'

# 2. Anmelden und Token erhalten
TOKEN=$(curl -s -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}' | jq -r '.token')

echo "Token: $TOKEN"

# 3. Konto erstellen
curl -X POST http://localhost:8082/api/accounts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"owner":"Test User","balance":1000}'

# 4. Konten anzeigen
curl -H "Authorization: Bearer $TOKEN" http://localhost:8082/api/accounts

# 5. Frontend testen
echo "Frontend verfügbar unter: http://localhost:4200"