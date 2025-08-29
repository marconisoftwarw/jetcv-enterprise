# JetCV Enterprise

Un'applicazione Flutter per la gestione di enti legali con integrazione Supabase, supporto multi-ambiente e funzionalità amministrative.

## 🚀 Caratteristiche

- **Autenticazione Multi-Provider**: Email/Password e Google Sign-In
- **Multi-Environment**: Configurazione separata per test e produzione
- **Integrazione Supabase**: Database, autenticazione e Edge Functions
- **Dashboard Amministrativa**: Gestione enti legali e utenti
- **Gestione Enti Legali**: Creazione, approvazione e rifiuto
- **Inviti via Email**: Sistema di inviti per nuovi enti legali
- **UI Moderna**: Design Material 3 con tema personalizzato

## 🏗️ Architettura

```
lib/
├── core/                    # Configurazione e servizi core
│   ├── config/             # Configurazione multi-ambiente
│   ├── constants/          # Costanti dell'applicazione
│   ├── services/           # Servizi (Supabase, Email)
│   └── utils/              # Utility e helper
├── features/               # Funzionalità dell'app
│   ├── auth/              # Autenticazione
│   ├── admin/             # Dashboard amministrativa
│   └── legal_entity/      # Gestione enti legali
└── shared/                # Componenti condivisi
    ├── models/            # Modelli dati
    ├── providers/         # State management (Riverpod)
    └── widgets/           # Widget riutilizzabili
```

## 📋 Prerequisiti

- Flutter SDK 3.2.0 o superiore
- Dart SDK 3.2.0 o superiore
- Account Supabase
- Servizio email esterno (per inviti)

## 🛠️ Installazione

1. **Clona il repository**
   ```bash
   git clone <repository-url>
   cd jetcventerprise
   ```

2. **Installa le dipendenze**
   ```bash
   flutter pub get
   ```

3. **Configura l'ambiente**
   
   Modifica i file di configurazione in `lib/core/config/`:
   
   - `env_test.dart` - Configurazione ambiente di test
   - `env_prod.dart` - Configurazione ambiente di produzione
   
   Inserisci le tue credenziali Supabase:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   static const String supabaseServiceRoleKey = 'YOUR_SUPABASE_SERVICE_ROLE_KEY';
   ```

4. **Configura Supabase**
   
   Crea le seguenti tabelle nel tuo database Supabase:
   
   ```sql
   -- User table
   CREATE TABLE public.user (
     idUser uuid NOT NULL,
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
     type text,
     hasWallet boolean NOT NULL DEFAULT false,
     idWallet uuid,
     hasCv boolean NOT NULL DEFAULT false,
     idCv uuid,
     idUserHash text NOT NULL,
     profileCompleted boolean NOT NULL DEFAULT false,
     kycCompleted boolean,
     kycPassed boolean,
     languageCode text,
     CONSTRAINT user_pkey PRIMARY KEY (idUser)
   );

   -- Legal Entity table
   CREATE TABLE public.legal_entity (
     idLegalEntity uuid NOT NULL DEFAULT gen_random_uuid(),
     idLegalEntityHash text NOT NULL,
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
   ```

5. **Configura le Edge Functions**
   
   Crea le seguenti Edge Functions in Supabase:
   
   - `send-legal-entity-invitation` - Per l'invio di inviti via email
   
   Esempio di Edge Function:
   ```typescript
   import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
   
   serve(async (req) => {
     const { email, legalEntityName, invitationLink } = await req.json()
     
     // Implementa la logica di invio email
     // Usa il tuo servizio email preferito
     
     return new Response(
       JSON.stringify({ success: true }),
       { headers: { "Content-Type": "application/json" } },
     )
   })
   ```

## 🚀 Esecuzione

1. **Avvia l'applicazione**
   ```bash
   flutter run
   ```

2. **Per il rilascio**
   ```bash
   flutter build apk --release        # Android
   flutter build ios --release        # iOS
   flutter build web --release        # Web
   ```

## 🔧 Configurazione Multi-Environment

L'applicazione supporta automaticamente due ambienti:

- **Debug/Test**: Usa la configurazione di test
- **Release/Production**: Usa la configurazione di produzione

La configurazione viene gestita automaticamente in base al build mode.

## 📱 Funzionalità Principali

### Autenticazione
- Registrazione con email e password
- Accesso con email e password
- Supporto per Google Sign-In (da implementare)
- Gestione sessioni utente

### Dashboard Amministrativa
- Visualizzazione enti legali per status
- Approvazione/rifiuto enti legali
- Creazione manuale di nuovi enti
- Statistiche e metriche

### Gestione Enti Legali
- Creazione di nuovi enti legali
- Invio di inviti via email
- Gestione dello stato (pending/approved/rejected)
- Visualizzazione dettagli completi

## 🎨 Personalizzazione

### Tema
Il tema dell'applicazione può essere personalizzato modificando:
- `lib/main.dart` - Configurazione tema principale
- `lib/core/constants/app_constants.dart` - Costanti UI

### Colori e Stili
Modifica i colori e gli stili nel file `lib/main.dart` nella sezione `ThemeData`.

## 🔒 Sicurezza

- Autenticazione basata su Supabase Auth
- Validazione lato client e server
- Gestione sicura delle sessioni
- Controllo accessi basato su ruoli utente

## 📊 Monitoraggio e Logging

- Log di debug per lo sviluppo
- Gestione errori centralizzata
- Metriche di utilizzo (da implementare)

## 🚀 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributi

1. Fork del progetto
2. Crea un branch per la feature (`git checkout -b feature/AmazingFeature`)
3. Commit delle modifiche (`git commit -m 'Add some AmazingFeature'`)
4. Push al branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📄 Licenza

Questo progetto è sotto licenza MIT. Vedi il file `LICENSE` per i dettagli.

## 📞 Supporto

Per supporto e domande:
- Apri una issue su GitHub
- Contatta il team di sviluppo

## 🔄 Changelog

### v1.0.0
- Autenticazione email/password
- Dashboard amministrativa
- Gestione enti legali
- Supporto multi-ambiente
- Integrazione Supabase

## 🎯 Roadmap

- [ ] Implementazione Google Sign-In
- [ ] Notifiche push
- [ ] Dashboard utente
- [ ] Gestione certificazioni
- [ ] Integrazione blockchain
- [ ] App mobile nativa
- [ ] API REST pubblica
- [ ] Sistema di reportistica
- [ ] Integrazione KYC
- [ ] Supporto multi-lingua
