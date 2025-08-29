# JetCV Enterprise - Guida di Setup

## 🚀 Configurazione Rapida

### 1. Configurazione Supabase

1. **Crea un progetto Supabase** su [supabase.com](https://supabase.com)
2. **Ottieni le credenziali** dal dashboard:
   - URL del progetto
   - Anon Key
   - Service Role Key

### 2. Configurazione Ambiente

Modifica i file in `lib/core/config/`:

```dart
// env_test.dart e env_prod.dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
static const String supabaseServiceRoleKey = 'YOUR_SUPABASE_SERVICE_ROLE_KEY';
```

### 3. Database Schema

Esegui questo SQL nel tuo database Supabase:

```sql
-- Abilita l'estensione UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabella utenti
CREATE TABLE public.user (
  idUser uuid NOT NULL DEFAULT gen_random_uuid(),
  firstName text,
  lastName text,
  email text,
  phone text,
  dateOfBirth date,
  address text,
  city text,
  state text,
  postalCode text,
  countryCode text,
  profilePicture text,
  gender text,
  createdAt timestamp with time zone NOT NULL DEFAULT now(),
  updatedAt timestamp with time zone,
  fullName text,
  type text DEFAULT 'user',
  hasWallet boolean NOT NULL DEFAULT false,
  idWallet uuid,
  hasCv boolean NOT NULL DEFAULT false,
  idCv uuid,
  idUserHash text NOT NULL DEFAULT gen_random_uuid()::text,
  profileCompleted boolean NOT NULL DEFAULT false,
  kycCompleted boolean DEFAULT false,
  kycPassed boolean DEFAULT false,
  languageCode text DEFAULT 'it',
  CONSTRAINT user_pkey PRIMARY KEY (idUser)
);

-- Tabella enti legali
CREATE TABLE public.legal_entity (
  idLegalEntity uuid NOT NULL DEFAULT gen_random_uuid(),
  idLegalEntityHash text NOT NULL DEFAULT gen_random_uuid()::text,
  legalName text NOT NULL,
  identifierCode text NOT NULL,
  operationalAddress text NOT NULL,
  headquartersAddress text NOT NULL,
  legalRepresentative text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  pec text,
  website text,
  createdAt timestamp with time zone NOT NULL DEFAULT now(),
  updatedAt timestamp with time zone,
  statusUpdatedAt timestamp with time zone,
  statusUpdatedByIdUser uuid,
  requestingIdUser uuid NOT NULL,
  status text NOT NULL DEFAULT 'pending',
  logoPictureUrl text,
  companyPictureUrl text,
  address text,
  city text,
  state text,
  postalcode text,
  countrycode text,
  CONSTRAINT legal_entity_pkey PRIMARY KEY (idLegalEntity)
);

-- RLS (Row Level Security)
ALTER TABLE public.user ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_entity ENABLE ROW LEVEL SECURITY;

-- Policy per utenti
CREATE POLICY "Users can view own profile" ON public.user
  FOR SELECT USING (auth.uid()::text = idUser::text);

CREATE POLICY "Users can update own profile" ON public.user
  FOR UPDATE USING (auth.uid()::text = idUser::text);

-- Policy per enti legali
CREATE POLICY "Anyone can view legal entities" ON public.legal_entity
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create legal entities" ON public.legal_entity
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admins can update legal entities" ON public.legal_entity
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.user 
      WHERE idUser = auth.uid()::text 
      AND type = 'admin'
    )
  );
```

### 4. Edge Functions

1. **Installa Supabase CLI**:
   ```bash
   npm install -g supabase
   ```

2. **Deploy delle Edge Functions**:
   ```bash
   cd edge
   supabase functions deploy send-legal-entity-invitation
   ```

### 5. Test dell'Applicazione

```bash
flutter run
```

## 🔧 Configurazione Avanzata

### Variabili d'Ambiente

L'app supporta automaticamente:
- **Debug Mode**: Configurazione test
- **Release Mode**: Configurazione produzione

### Servizi Email

Per implementare l'invio email, modifica la Edge Function:

```typescript
// Esempio con SendGrid
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { email, legalEntityName, invitationLink } = await req.json()
  
  // Configura SendGrid
  const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${Deno.env.get('SENDGRID_API_KEY')}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      personalizations: [{ to: [{ email }] }],
      from: { email: 'noreply@jetcv.com' },
      subject: `Invito per ${legalEntityName}`,
      content: [{
        type: 'text/html',
        value: `Sei stato invitato a partecipare a ${legalEntityName}. Clicca qui: ${invitationLink}`
      }]
    })
  })
  
  return new Response(JSON.stringify({ success: true }))
})
```

## 🚨 Risoluzione Problemi

### Errori Comuni

1. **"Supabase not initialized"**
   - Verifica le credenziali in `lib/core/config/`
   - Controlla la connessione internet

2. **"Table not found"**
   - Esegui lo schema SQL nel database
   - Verifica i nomi delle tabelle

3. **"Authentication failed"**
   - Controlla le policy RLS
   - Verifica la configurazione auth in Supabase

### Debug

Abilita i log dettagliati:

```dart
// In lib/core/services/supabase_service.dart
print('Supabase URL: ${AppConfig.supabaseUrl}');
print('Supabase Key: ${AppConfig.supabaseAnonKey}');
```

## 📱 Funzionalità Disponibili

✅ **Implementato**:
- Autenticazione email/password
- Dashboard amministrativa
- Gestione enti legali
- Multi-ambiente
- UI responsive

🔄 **In Sviluppo**:
- Google Sign-In
- Notifiche push
- Dashboard utente

📋 **Pianificato**:
- Gestione certificazioni
- Integrazione blockchain
- Sistema KYC

## 🎯 Prossimi Passi

1. **Configura le credenziali Supabase**
2. **Esegui lo schema del database**
3. **Deploy delle Edge Functions**
4. **Testa l'autenticazione**
5. **Crea il primo ente legale**
6. **Personalizza l'UI secondo le tue esigenze**

## 📞 Supporto

Per assistenza:
- Controlla i log dell'applicazione
- Verifica la configurazione Supabase
- Consulta la documentazione Flutter
- Apri una issue su GitHub
