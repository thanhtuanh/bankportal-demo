# 🌐 Frontend Benutzer-Anleitung

## 📱 Banking Web-App Bedienung

Nach dem Start des Demos ist die Banking-Anwendung unter **http://localhost:4200** verfügbar. Hier ist eine Schritt-für-Schritt Anleitung:

## 1. 🏠 Startseite & Navigation

Wenn Sie http://localhost:4200 öffnen, sehen Sie:
- **🏦 Bank Portal Logo** - Moderne Banking-Oberfläche
- **📱 Responsive Design** - Funktioniert auf Desktop, Tablet und Mobile
- **🔐 Login/Register Buttons** - Oben rechts in der Navigation

```
┌─────────────────────────────────────────────────────────┐
│  🏦 Bank Portal                    🔐 Login | Register  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│         Willkommen zum Bank Portal                      │
│         Moderne Banking-Lösung                          │
│                                                         │
│    [Jetzt registrieren]  [Anmelden]                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 2. 👤 Benutzer-Registrierung

**Schritt 1:** Klicken Sie auf **"Register"** in der oberen Navigation

**Schritt 2:** Füllen Sie das Registrierungsformular aus:
- **👤 Benutzername**: z.B. "demo" (mindestens 3 Zeichen)
- **🔒 Passwort**: z.B. "demo123" (mindestens 6 Zeichen)
- **🔒 Passwort bestätigen**: Wiederholen Sie das Passwort

**Schritt 3:** Klicken Sie auf **"Registrieren"**

```
┌─────────────────────────────────────────────────────────┐
│  📝 Neuen Account erstellen                             │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  👤 Benutzername: [demo____________]                    │
│                                                         │
│  🔒 Passwort:     [••••••••_______]                    │
│                                                         │
│  🔒 Bestätigen:   [••••••••_______]                    │
│                                                         │
│           [Registrieren]  [Abbrechen]                   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**✅ Erfolg:** Sie sehen eine Bestätigung "Benutzer erfolgreich registriert!"

## 3. 🔐 Anmeldung

**Schritt 1:** Klicken Sie auf **"Login"** (oder werden automatisch weitergeleitet)

**Schritt 2:** Geben Sie Ihre Anmeldedaten ein:
- **👤 Benutzername**: "demo"
- **🔒 Passwort**: "demo123"

**Schritt 3:** Klicken Sie auf **"Anmelden"**

**✅ Erfolg:** Sie werden zum Dashboard weitergeleitet

## 4. 📊 Dashboard - Hauptansicht

Nach erfolgreicher Anmeldung sehen Sie das **Banking Dashboard**:

```
┌─────────────────────────────────────────────────────────┐
│  🏦 Bank Portal    👤 demo                    [Logout]  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📊 Meine Konten                    [+ Neues Konto]     │
│  ─────────────────────────────────────────────────────  │
│                                                         │
│  💳 Konto #1001                           1.000,00 €    │
│     Girokonto                                           │
│     [Details] [Überweisung]                             │
│                                                         │
│  💳 Konto #1002                             500,00 €    │
│     Sparkonto                                           │
│     [Details] [Überweisung]                             │
│                                                         │
│  📈 Gesamtsaldo: 1.500,00 €                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Dashboard-Features:**
- **💳 Konten-Übersicht** - Alle Ihre Bankkonten auf einen Blick
- **💰 Saldo-Anzeige** - Aktueller Kontostand in Euro
- **🔄 Echtzeit-Updates** - Automatische Aktualisierung
- **📱 Responsive Design** - Optimiert für alle Geräte

## 5. 💼 Neues Konto erstellen

**Schritt 1:** Klicken Sie auf **"+ Neues Konto"** im Dashboard

**Schritt 2:** Füllen Sie das Formular aus:
- **📝 Kontoname**: z.B. "Mein Girokonto"
- **💰 Startguthaben**: z.B. "1000" (in Euro)
- **🏷️ Kontotyp**: Girokonto/Sparkonto (optional)

**Schritt 3:** Klicken Sie auf **"Konto erstellen"**

**✅ Erfolg:** Das neue Konto erscheint sofort im Dashboard

## 6. 💸 Geld überweisen

**Schritt 1:** Klicken Sie bei einem Konto auf **"Überweisung"**

**Schritt 2:** Wählen Sie die Überweisungsdetails:
- **📤 Von Konto**: Automatisch ausgewählt
- **📥 Zu Konto**: Zielkonto aus Dropdown wählen
- **💰 Betrag**: z.B. "100" (in Euro)
- **📝 Verwendungszweck**: z.B. "Testüberweisung" (optional)

**Schritt 3:** Klicken Sie auf **"Überweisung ausführen"**

**✅ Erfolg:** 
- Bestätigung "Überweisung erfolgreich!"
- Kontostände werden sofort aktualisiert
- Transaktion erscheint in der Historie

## 7. 📋 Transaktionshistorie

**Schritt 1:** Klicken Sie bei einem Konto auf **"Details"**

**Schritt 2:** Sie sehen die **Transaktionshistorie**:

```
┌─────────────────────────────────────────────────────────┐
│  📋 Konto #1001 - Transaktionshistorie                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  💰 Aktueller Saldo: 900,00 €                          │
│                                                         │
│  📅 Transaktionen:                                      │
│  ─────────────────────────────────────────────────────  │
│                                                         │
│  📤 05.07.2024 14:30  -100,00 €  Zu Konto #1002       │
│     Testüberweisung                                     │
│                                                         │
│  📥 05.07.2024 10:00  +1000,00 €  Kontoeröffnung       │
│     Startguthaben                                       │
│                                                         │
│                                    [Zurück]             │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Historie-Features:**
- **📅 Chronologische Auflistung** aller Transaktionen
- **💰 Beträge** mit Ein- und Ausgängen
- **📝 Verwendungszweck** und Details
- **🔄 Echtzeit-Updates** bei neuen Transaktionen

## 8. 📱 Mobile Ansicht

Das Bank Portal ist **vollständig responsive**. Auf Mobilgeräten:

```
┌─────────────────┐
│ 🏦 Bank Portal  │
│           ☰ Menü│
├─────────────────┤
│                 │
│ 📊 Meine Konten │
│                 │
│ 💳 Konto #1001  │
│    900,00 €     │
│    [Details]    │
│    [Transfer]   │
│                 │
│ 💳 Konto #1002  │
│    600,00 €     │
│    [Details]    │
│    [Transfer]   │
│                 │
│ [+ Neues Konto] │
│                 │
└─────────────────┘
```

**Mobile Features:**
- **☰ Hamburger-Menü** für Navigation
- **👆 Touch-optimierte Buttons**
- **📱 Optimierte Layouts** für kleine Bildschirme
- **⚡ Schnelle Ladezeiten**

## 🎯 Typische Benutzer-Workflows

### 🚀 Schnellstart-Workflow (2 Minuten):
1. **Registrieren** → 2. **Anmelden** → 3. **Konto erstellen** → 4. **Fertig!**

### 💸 Überweisung-Workflow (1 Minute):
1. **Dashboard öffnen** → 2. **"Überweisung" klicken** → 3. **Details eingeben** → 4. **Bestätigen**

### 📊 Konten-Management:
1. **Mehrere Konten erstellen** → 2. **Zwischen Konten überweisen** → 3. **Historie verfolgen**

## 💡 Tipps für die beste Erfahrung

### ✅ Do's:
- **🔄 Seite aktualisieren** wenn Daten nicht sofort erscheinen
- **💰 Realistische Beträge** für Tests verwenden
- **📝 Aussagekräftige Kontonnamen** wählen
- **🔐 Sichere Passwörter** auch für Demo verwenden

### ❌ Don'ts:
- **Keine echten Bankdaten** eingeben (ist nur Demo!)
- **Nicht gleichzeitig** in mehreren Tabs anmelden
- **Browser-Cache leeren** wenn Probleme auftreten

## 🛠️ Fehlerbehebung

### Häufige Probleme:

**Problem:** "Seite lädt nicht"
```
Lösung: 
1. Prüfen Sie: http://localhost:4200
2. Services neu starten: docker-compose restart
3. Browser-Cache leeren
```

**Problem:** "Anmeldung fehlgeschlagen"
```
Lösung:
1. Benutzername/Passwort prüfen
2. Neu registrieren falls nötig
3. Backend-Status prüfen: http://localhost:8081/api/health
```

**Problem:** "Konto kann nicht erstellt werden"
```
Lösung:
1. Alle Felder ausfüllen
2. Gültigen Betrag eingeben (nur Zahlen)
3. Backend-Logs prüfen: docker-compose logs account-service
```

## 🎉 Demo-Erfolg!

Nach dieser Anleitung können Sie:
- ✅ **Vollständige Banking-Funktionen** nutzen
- ✅ **Mehrere Konten** verwalten
- ✅ **Geld überweisen** zwischen Konten
- ✅ **Transaktionshistorie** verfolgen
- ✅ **Mobile und Desktop** Versionen nutzen

**Das Bank Portal zeigt moderne Banking-UX mit professioneller Benutzerführung!** 🚀
