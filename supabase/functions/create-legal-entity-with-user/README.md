# Create Legal Entity with User Edge Function

Questa Edge Function gestisce la creazione di entità legali e utenti in un'unica operazione atomica.

## Funzionalità

- Crea un utente nel database
- Crea un'entità legale associata all'utente
- Crea automaticamente una relazione certificatore (l'utente diventa proprietario/certificatore della propria entità)
- Gestisce errori di duplicazione (se l'utente esiste già, continua con la creazione dell'entità)
- Operazione atomica (se una parte fallisce, l'operazione viene interrotta)

## Deploy

Per deployare questa Edge Function su Supabase:

```bash
# Assicurati di essere nella directory del progetto
cd /Users/riccardo/Desktop/jetcv-enterprise

# Deploy della funzione
supabase functions deploy create-legal-entity-with-user
```

## Utilizzo

La funzione accetta un payload JSON con la seguente struttura:

```json
{
  "userData": {
    "idUser": "uuid",
    "firstName": "string",
    "lastName": "string", 
    "email": "string",
    "phone": "string (optional)",
    "profilePicture": "string (optional)",
    "fullName": "string",
    "type": "string (optional, default: 'user')",
    "languageCode": "string (optional, default: 'it')",
    "idUserHash": "string",
    "profileCompleted": "boolean (optional, default: false)",
    "createdAt": "ISO string",
    "updatedAt": "ISO string (optional)"
  },
  "legalEntityData": {
    "idLegalEntity": "uuid",
    "idLegalEntityHash": "string",
    "legalName": "string",
    "identifierCode": "string (optional)",
    "operationalAddress": "string (optional)",
    "operationalCity": "string (optional)",
    "operationalPostalCode": "string (optional)",
    "operationalState": "string (optional)",
    "operationalCountry": "string (optional)",
    "headquarterAddress": "string (optional)",
    "headquarterCity": "string (optional)",
    "headquarterPostalCode": "string (optional)",
    "headquarterState": "string (optional)",
    "headquarterCountry": "string (optional)",
    "legalRapresentative": "string (optional)",
    "email": "string (optional)",
    "phone": "string (optional)",
    "pec": "string (optional)",
    "website": "string (optional)",
    "logoPicture": "string (optional)",
    "companyPicture": "string (optional)",
    "status": "string (default: 'pending')",
    "createdAt": "ISO string",
    "updatedAt": "ISO string (optional)",
    "createdByIdUser": "uuid"
  }
}
```

## Risposta

La funzione restituisce:

```json
{
  "ok": true,
  "message": "Legal entity and user created successfully",
  "data": {
    "user": { /* dati utente */ },
    "legalEntity": { /* dati entità legale */ },
    "certifier": { /* dati relazione certificatore */ }
  }
}
```

## Errori

La funzione gestisce i seguenti errori:

- **400**: Dati mancanti o non validi
- **500**: Errori del server o del database

## Note

- La funzione utilizza la service role key per bypassare le restrizioni RLS
- Se l'utente esiste già, la creazione dell'entità procede comunque
- La relazione certificatore è opzionale e non blocca l'operazione se fallisce
- Tutte le operazioni sono atomiche a livello di Edge Function
