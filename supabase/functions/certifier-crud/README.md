# Certifier CRUD Edge Function

This Supabase Edge Function provides comprehensive CRUD (Create, Read, Update, Delete) operations for certifiers, including the ability to create users and certifiers together in a single transaction.

## Endpoints

### GET /functions/v1/certifier-crud

Retrieve certifiers based on query parameters:

- `id_certifier` - Get specific certifier by ID
- `id_legal_entity` - Get all certifiers for a legal entity
- `id_user` - Get certifier for a specific user

**Example:**
```bash
curl -X GET "https://your-project.supabase.co/functions/v1/certifier-crud?id_legal_entity=123"
```

### POST /functions/v1/certifier-crud

Create, update, or delete certifiers using JSON body.

## Operations

### 1. Create Certifier with User (create_with_user)

Creates both a user and an associated certifier in a single transaction. This is ideal for adding new certifiers with complete user information.

```json
{
  "operation": "create_with_user",
  "userData": {
    "firstName": "Mario",
    "lastName": "Rossi",
    "email": "mario.rossi@example.com",
    "phone": "+39 123 456 7890",
    "city": "Roma",
    "address": "Via Roma 123",
    "type": "certifier",
    "languageCode": "it"
  },
  "certifierData": {
    "id_legal_entity": "uuid-legal-entity",
    "role": "Senior Certifier",
    "active": true
  }
}
```

**Response:**
```json
{
  "ok": true,
  "message": "User and certifier created successfully",
  "data": {
    "user": { ... },
    "certifier": { ... }
  }
}
```

### 2. Create Certifier Only (create)

Creates only a certifier record, optionally associated with an existing user.

```json
{
  "operation": "create",
  "data": {
    "id_legal_entity": "required-uuid",
    "id_user": "optional-uuid",
    "role": "Certifier Role",
    "active": true
  }
}
```

### 3. Update Certifier (update)

Updates an existing certifier's information.

```json
{
  "operation": "update",
  "id_certifier": "required-uuid",
  "data": {
    "role": "Updated Role",
    "active": false
  }
}
```

### 4. Delete Certifier (delete)

Deletes a certifier record.

```json
{
  "operation": "delete",
  "id_certifier": "required-uuid"
}
```

## User Data Fields

When using `create_with_user` operation, the following user fields are supported:

### Required Fields
- `firstName` (string) - User's first name
- `lastName` (string) - User's last name  
- `email` (string) - User's email address

### Optional Fields
- `phone` (string) - Phone number
- `city` (string) - City of residence
- `address` (string) - Full address
- `state` (string) - State/Province
- `postalCode` (string) - Postal/ZIP code
- `countryCode` (string) - Country code
- `type` (string) - User type (defaults to 'certifier')
- `languageCode` (string) - Language preference (defaults to 'it')
- `gender` (string) - Gender
- `dateOfBirth` (string) - Date of birth in ISO format
- `profilePicture` (string) - Profile picture URL
- `profileCompleted` (boolean) - Whether profile is complete (defaults to true)

## Certifier Data Fields

### Required Fields
- `id_legal_entity` (string) - UUID of the legal entity

### Optional Fields
- `id_user` (string) - UUID of associated user
- `role` (string) - Certifier's role
- `active` (boolean) - Whether certifier is active (defaults to true)
- `invitation_token` (string) - Invitation token if applicable
- `kyc_passed` (boolean) - KYC verification status
- `id_kyc_attempt` (string) - KYC attempt ID

## Response Format

All responses follow this format:

### Success Response
```json
{
  "ok": true,
  "message": "Operation completed successfully",
  "data": { ... }
}
```

### Error Response
```json
{
  "ok": false,
  "message": "Error description",
  "error": "Detailed error message"
}
```

## Error Handling

The function handles various error scenarios:

- **400 Bad Request**: Missing required fields
- **404 Not Found**: Certifier not found for update/delete operations
- **409 Conflict**: User already exists (for create_with_user)
- **500 Internal Server Error**: Database or server errors

## Transaction Safety

When using `create_with_user`, the function attempts to create both user and certifier records. If user creation succeeds but certifier creation fails, the operation will fail and return an error. Manual cleanup may be required in such cases.

## Security

This function requires proper authentication headers:
- `apikey`: Supabase anon key
- `Authorization`: Bearer token with service role key for admin operations

The function uses service role permissions to bypass Row Level Security (RLS) policies for administrative operations.

## Usage Examples

### Creating a Complete Certifier with User Data
```javascript
const response = await fetch('/functions/v1/certifier-crud', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${serviceRoleKey}`
  },
  body: JSON.stringify({
    operation: 'create_with_user',
    userData: {
      firstName: 'Giovanni',
      lastName: 'Bianchi',
      email: 'giovanni.bianchi@example.com',
      phone: '+39 333 123 4567',
      city: 'Milano',
      address: 'Corso Buenos Aires 15'
    },
    certifierData: {
      id_legal_entity: 'legal-entity-uuid',
      role: 'Quality Manager',
      active: true
    }
  })
});
```

### Updating a Certifier
```javascript
const response = await fetch('/functions/v1/certifier-crud', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${serviceRoleKey}`
  },
  body: JSON.stringify({
    operation: 'update',
    id_certifier: 'certifier-uuid',
    data: {
      role: 'Senior Quality Manager',
      active: true
    }
  })
});
```