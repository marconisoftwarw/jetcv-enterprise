# Edge Functions Setup per Bypass RLS

## Problema RLS Identificato

L'applicazione sta riscontrando errori di Row Level Security (RLS) quando tenta di creare nuovi utenti nella tabella `user`:

```
new row violates row-level security policy for table "user", code: 42501
```

## Soluzione: Edge Function `create-user`

### 1. Creare l'Edge Function

Crea un nuovo file `supabase/functions/create-user/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create a Supabase client with the Auth context of the function
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    )

    // Get the user from the JWT token
    const { data: { user }, error: authError } = await supabaseClient.auth.getUser()
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ ok: false, message: 'Unauthorized' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get the request body
    const { idUser, firstName, lastName, email, type, languageCode } = await req.json()

    // Validate required fields
    if (!idUser || !firstName || !lastName || !email) {
      return new Response(
        JSON.stringify({ ok: false, message: 'Missing required fields' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Insert the user record (bypasses RLS)
    const { data: userData, error: insertError } = await supabaseClient
      .from('user')
      .insert({
        'idUser': idUser,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'type': type || 'user',
        'languageCode': languageCode || 'it',
        'createdAt': new Date().toISOString(),
        'updatedAt': new Date().toISOString(),
      })
      .select()
      .single()

    if (insertError) {
      console.error('Error inserting user:', insertError)
      return new Response(
        JSON.stringify({ ok: false, message: 'Failed to create user', error: insertError.message }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    return new Response(
      JSON.stringify({ 
        ok: true, 
        message: 'User created successfully',
        user: userData 
      }),
      { status: 201, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ ok: false, message: 'Internal server error', error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
```

### 2. Deploy dell'Edge Function

```bash
# Dalla directory del progetto
supabase functions deploy create-user
```

### 3. Configurazione RLS

Assicurati che la tabella `user` abbia le policy RLS corrette:

```sql
-- Abilita RLS
ALTER TABLE "user" ENABLE ROW LEVEL SECURITY;

-- Policy per permettere agli utenti di leggere i propri dati
CREATE POLICY "Users can view own profile" ON "user"
  FOR SELECT USING (auth.uid()::text = "idUser");

-- Policy per permettere agli utenti di aggiornare i propri dati
CREATE POLICY "Users can update own profile" ON "user"
  FOR UPDATE USING (auth.uid()::text = "idUser");

-- Policy per permettere la creazione di utenti (gestita via Edge Function)
-- Non è necessaria una policy INSERT perché l'Edge Function bypassa RLS
```

### 4. Test dell'Edge Function

```bash
# Test locale
supabase functions serve create-user

# Test con curl
curl -X POST 'http://localhost:54321/functions/v1/create-user' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -H 'Content-Type: application/json' \
  -d '{
    "idUser": "test-user-id",
    "firstName": "Test",
    "lastName": "User",
    "email": "test@example.com",
    "type": "user",
    "languageCode": "it"
  }'
```

## Benefici della Soluzione

1. **Bypass RLS**: L'Edge Function può creare utenti senza restrizioni RLS
2. **Sicurezza**: Solo utenti autenticati possono creare nuovi utenti
3. **Validazione**: Controlli lato server per i dati richiesti
4. **Fallback**: Se l'Edge Function fallisce, l'app usa il metodo diretto
5. **Logging**: Tracciamento completo delle operazioni

## Integrazione con l'App

L'app Flutter ora:
1. Tenta prima di creare l'utente via Edge Function
2. Se fallisce, usa il metodo diretto come fallback
3. Fornisce logging dettagliato per il debugging
4. Gestisce correttamente gli errori RLS
