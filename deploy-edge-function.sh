#!/bin/bash

# Script per deployare l'Edge Function create-legal-entity-with-user

echo "🚀 Deploying create-legal-entity-with-user Edge Function..."

# Verifica che Supabase CLI sia installato
if ! command -v supabase &> /dev/null; then
    echo "❌ Supabase CLI non trovato. Installa Supabase CLI prima di continuare."
    echo "📖 Guida: https://supabase.com/docs/guides/cli"
    exit 1
fi

# Verifica che siamo nella directory corretta
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Questo script deve essere eseguito dalla directory root del progetto Flutter"
    exit 1
fi

# Verifica che la funzione esista
if [ ! -d "supabase/functions/create-legal-entity-with-user" ]; then
    echo "❌ Directory della funzione non trovata: supabase/functions/create-legal-entity-with-user"
    exit 1
fi

# Deploy della funzione
echo "📦 Deploying function..."
supabase functions deploy create-legal-entity-with-user

if [ $? -eq 0 ]; then
    echo "✅ Edge Function deployata con successo!"
    echo "🔗 URL: https://YOUR_PROJECT_ID.supabase.co/functions/v1/create-legal-entity-with-user"
    echo ""
    echo "📝 Per testare la funzione, puoi usare:"
    echo "curl -X POST 'https://YOUR_PROJECT_ID.supabase.co/functions/v1/create-legal-entity-with-user' \\"
    echo "  -H 'Authorization: Bearer YOUR_ANON_KEY' \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -d '{ \"userData\": {...}, \"legalEntityData\": {...} }'"
else
    echo "❌ Errore durante il deploy della funzione"
    exit 1
fi
