### 1. Admin-User registrieren (falls noch nicht vorhanden)
Registriert den User „admin“ im Auth-Service.  
```bash
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}' 
```

---

### 2. Normalen User registrieren
Registriert den User „alice“ im Auth-Service.  
```bash
curl -X POST http://localhost:8082/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret"}'
```

---

### 3. Admin-Login (JWT-Token erhalten)
Loggt den Admin ein und gibt das JWT-Token zurück.  
```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'
```

---

### 4. User-Login (JWT-Token erhalten)
Loggt den User „alice“ ein und gibt das JWT-Token zurück.  
```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret"}'
```

---

### 5. Alle Accounts anzeigen (Token notwendig!)
Zeigt alle Accounts im Account-Service an.  
```bash
curl -H "Authorization: Bearer DEIN_TOKEN_HIER" \
  http://localhost:8081/api/accounts
```

---

### 6. Neues Konto anlegen (Token notwendig!)
Legt ein neues Konto für „alice“ an.  
```bash
curl -X POST http://localhost:8081/api/accounts \
  -H "Authorization: Bearer DEIN_TOKEN_HIER" \
  -H "Content-Type: application/json" \
  -d '{"owner":"alice","balance":1000}'
```

---

### 7. Geldüberweisung zwischen Konten (Token notwendig!)
Überweist 100 Einheiten von Konto 1 zu Konto 2.  
```bash
curl -X POST http://localhost:8081/api/accounts/transfer \
  -H "Authorization: Bearer DEIN_TOKEN_HIER" \
  -H "Content-Type: application/json" \
  -d '{"fromAccountId":1,"toAccountId":2,"amount":100}'
```

---

### 8. Aktuellen Benutzer abfragen (Token notwendig!)
Fragt die User-Infos vom Auth-Service ab (nur wenn Endpoint /api/auth/me vorhanden ist).  
```bash
curl -H "Authorization: Bearer DEIN_TOKEN_HIER" \
  http://localhost:8082/api/auth/me
```

