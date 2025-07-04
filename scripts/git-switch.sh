#!/bin/bash

# 🔄 Git Backup Switch Script
# Einfacher Wechsel zwischen den Backup-Ständen

set -e

echo "🔄 Bank Portal - Git Backup Switch"
echo "=================================="

# Aktueller Branch anzeigen
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Aktueller Branch: $CURRENT_BRANCH"
echo ""

# Verfügbare Optionen
echo "📋 Verfügbare Backup-Stände:"
echo "  1) stand-1  - Original main Branch (vor Merge)"
echo "  2) stand-2  - Production-ready Version (nach Merge)"
echo "  3) main     - Aktueller Hauptbranch"
echo "  4) k8s      - Entwicklungsbranch"
echo ""

# Benutzer-Eingabe
read -p "🎯 Zu welchem Stand wechseln? (1/2/3/4): " choice

case $choice in
    1)
        TARGET="stand-1"
        DESCRIPTION="Original main Branch (vor allen Änderungen)"
        ;;
    2)
        TARGET="stand-2"
        DESCRIPTION="Production-ready Version mit allen Features"
        ;;
    3)
        TARGET="main"
        DESCRIPTION="Aktueller Hauptbranch"
        ;;
    4)
        TARGET="k8s"
        DESCRIPTION="Entwicklungsbranch"
        ;;
    *)
        echo "❌ Ungültige Auswahl!"
        exit 1
        ;;
esac

# Warnung bei uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  Warnung: Es gibt uncommitted Änderungen!"
    echo "   Diese werden gestashed und können später wiederhergestellt werden."
    read -p "   Fortfahren? (y/n): " confirm
    if [[ $confirm != "y" ]]; then
        echo "❌ Abgebrochen."
        exit 1
    fi
    git stash push -m "Auto-stash before switching to $TARGET"
    echo "💾 Änderungen gestashed."
fi

# Branch wechseln
echo "🔄 Wechsle zu Branch: $TARGET"
echo "📝 Beschreibung: $DESCRIPTION"
git checkout $TARGET

# Status anzeigen
echo ""
echo "✅ Erfolgreich gewechselt!"
echo "📍 Aktueller Branch: $(git branch --show-current)"
echo "📊 Letzte Commits:"
git log --oneline -3

echo ""
echo "🎯 Nützliche Commands:"
echo "  git stash list          # Gestashte Änderungen anzeigen"
echo "  git stash pop           # Letzte Änderungen wiederherstellen"
echo "  ./scripts/git-switch.sh # Erneut wechseln"
echo "  git log --oneline -10   # Commit-Historie anzeigen"
