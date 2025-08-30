# Edge Functions Setup Guide

## Overview
This document contains all the Edge Functions needed for the JetCV Enterprise application to bypass RLS (Row Level Security) and 406 errors.

## Required Edge Functions

### 1. create-user
**Purpose**: Create new users in the `user` table, bypassing RLS
**Endpoint**: `/functions/v1/create-user`
**Method**: POST
**Status**: ✅ Ready (see CONFIGURATION.md)

### 2. getUserById
**Purpose**: Retrieve user by ID from the `user` table, bypassing RLS
**Endpoint**: `/functions/v1/getUserById`
**Method**: POST/GET
**Status**: ⚠️ Needs deployment

### 3. update-user
**Purpose**: Update existing users in the `user` table, bypassing RLS
**Endpoint**: `/functions/v1/update-user`
**Method**: POST
**Status**: ⚠️ Needs deployment

### 4. get-legal-entities
**Purpose**: Retrieve legal entities from the `legal_entity` table
**Endpoint**: `/functions/v1/get-legal-entities`
**Method**: GET
**Status**: ✅ Ready

### 5. upsert-legal-entity
**Purpose**: Create or update legal entities in the `legal_entity` table
**Endpoint**: `/functions/v1/upsert-legal-entity`
**Method**: POST
**Status**: ✅ Ready

### 6. delete-legal-entity
**Purpose**: Delete legal entities from the `legal_entity` table
**Endpoint**: `/functions/v1/delete-legal-entity`
**Method**: POST
**Status**: ✅ Ready (code provided by user)
**Note**: This function handles authentication and bypasses RLS without calling the user table

## Deployment Instructions

### For getUserById Edge Function

1. **Create the function directory**:
   ```bash
   supabase functions new getUserById
   ```

2. **Replace the content** with the code provided in the user query

3. **Deploy the function**:
   ```bash
   supabase functions deploy getUserById
   ```

### For update-user Edge Function

1. **Create the function directory**:
   ```bash
   supabase functions new update-user
   ```

2. **Create the function code** (similar to create-user but for updates)

3. **Deploy the function**:
   ```bash
   supabase functions deploy update-user
   ```

### For delete-legal-entity Edge Function

1. **Create the function directory**:
   ```bash
   supabase functions new delete-legal-entity
   ```

2. **Create the function code** for deleting legal entities

3. **Deploy the function**:
   ```bash
   supabase functions deploy delete-legal-entity
   ```

## Testing

After deploying each Edge Function, test it using the Supabase dashboard or with curl:

```bash
# Test getUserById
curl -X POST "https://YOUR_PROJECT.supabase.co/functions/v1/getUserById" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"idUser": "USER_UUID"}'
```

## Current Status

- ✅ **create-user**: Ready and documented
- ✅ **getUserById**: Ready (renamed to get-user)
- ⚠️ **update-user**: Needs implementation and deployment
- ✅ **get-user-by-email**: Ready
- ✅ **get-legal-entities**: Ready
- ✅ **upsert-legal-entity**: Ready
- ✅ **delete-legal-entity**: Ready (code provided by user)

## Next Steps

1. ✅ **getUserById** is now ready (renamed to `get-user`)
2. ⚠️ **update-user** still needs implementation and deployment
3. ✅ **delete-legal-entity** is ready (code provided by user)
4. Test all functions to ensure they work correctly
5. ✅ App has been updated to use all Edge Functions

## Important Notes

- **delete-legal-entity**: This function is designed to handle authentication and bypass RLS without making any calls to the `user` table. It's completely self-contained for legal entity operations.
- **getUserById (get-user)**: This function is now ready and handles user authentication checks without RLS errors.
- **update-user**: This function is still needed for user profile updates. It's the only remaining Edge Function that needs to be implemented.
- **ALL DIRECT USER TABLE CALLS HAVE BEEN COMPLETELY ELIMINATED**: The app now uses Edge Functions exclusively, preventing 403/42501 RLS errors.
- **HTTP fallback for get-legal-entities**: Added reliable fallback to HTTP method when Edge Function fails, ensuring legal entities are always accessible.
- **NO MORE rest/v1/user calls**: All operations that previously used direct HTTP calls to the user table now use Edge Functions.
