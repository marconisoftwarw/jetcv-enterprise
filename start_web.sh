#!/bin/bash

# Script per avviare Flutter web sulla porta 8080
echo "🚀 Avvio Flutter Web sulla porta 8080..."

# Verifica se la porta 8080 è già in uso
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  La porta 8080 è già in uso. Terminando il processo..."
    lsof -ti:8080 | xargs kill -9
    sleep 2
fi

# Avvia Flutter web sulla porta 8080
flutter run -d chrome --web-port=8080 --web-hostname=localhost
