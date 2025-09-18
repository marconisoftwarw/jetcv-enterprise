import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface UserData {
  idUser?: string
  firstName: string
  lastName: string
  email: string
  phone?: string
  profilePicture?: string
  fullName: string
  type?: string
  hasWallet?: boolean
  idWallet?: string
  hasCv?: boolean
  idCv?: string
  idUserHash?: string
  profileCompleted?: boolean
  languageCode?: string
  gender?: string
  dateOfBirth?: string
  address?: string
  city?: string
  state?: string
  postalCode?: string
  countryCode?: string
  createdAt?: string
  updatedAt?: string
}

interface CertifierData {
  id_certifier?: string
  id_certifier_hash?: string
  id_legal_entity: string
  id_user?: string
  active?: boolean
  role?: string
  created_at?: string
  updated_at?: string
  invitation_token?: string
  kyc_passed?: boolean
  id_kyc_attempt?: string
}

interface CreateCertifierWithUserRequest {
  operation: 'create_with_user'
  userData: UserData
  certifierData: CertifierData
}

interface CreateCertifierRequest {
  operation: 'create'
  data: CertifierData
}

interface UpdateCertifierRequest {
  operation: 'update'
  id_certifier: string
  data: Partial<CertifierData>
}

interface DeleteCertifierRequest {
  operation: 'delete'
  id_certifier: string
}

interface GetCertifierRequest {
  operation: 'get'
  id_certifier?: string
  id_legal_entity?: string
  id_user?: string
}

type CertifierRequest = CreateCertifierWithUserRequest | CreateCertifierRequest | UpdateCertifierRequest | DeleteCertifierRequest | GetCertifierRequest

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('🚀 Starting certifier CRUD operation...')

    // Create Supabase client with service role key for admin operations
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Handle GET requests for retrieving certifiers
    if (req.method === 'GET') {
      const url = new URL(req.url)
      const idCertifier = url.searchParams.get('id_certifier')
      const idLegalEntity = url.searchParams.get('id_legal_entity')
      const idUser = url.searchParams.get('id_user')

      console.log('📋 GET request params:', { idCertifier, idLegalEntity, idUser })

      let query = supabaseClient.from('certifier').select('*')

      if (idCertifier) {
        query = query.eq('id_certifier', idCertifier)
      }
      if (idLegalEntity) {
        query = query.eq('id_legal_entity', idLegalEntity)
      }
      if (idUser) {
        query = query.eq('id_user', idUser)
      }

      const { data: certifiers, error } = await query

      if (error) {
        console.error('❌ Error retrieving certifiers:', error)
        return new Response(
          JSON.stringify({
            ok: false,
            message: 'Failed to retrieve certifiers',
            error: error.message
          }),
          {
            status: 500,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }

      console.log(`✅ Retrieved ${certifiers.length} certifiers`)
      return new Response(
        JSON.stringify({
          ok: true,
          data: certifiers
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Handle POST/PUT/DELETE requests with JSON body
    const requestData: CertifierRequest = await req.json()
    console.log('📋 Request data:', requestData)

    switch (requestData.operation) {
      case 'create_with_user':
        return await handleCreateCertifierWithUser(supabaseClient, requestData)
      case 'create':
        return await handleCreateCertifier(supabaseClient, requestData)
      case 'update':
        return await handleUpdateCertifier(supabaseClient, requestData)
      case 'delete':
        return await handleDeleteCertifier(supabaseClient, requestData)
      default:
        return new Response(
          JSON.stringify({
            ok: false,
            message: 'Invalid operation. Supported operations: create_with_user, create, update, delete, get'
          }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
    }

  } catch (error) {
    console.error('❌ Unexpected error:', error)
    
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'Internal server error',
        error: error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})

async function handleCreateCertifierWithUser(supabaseClient: any, request: CreateCertifierWithUserRequest) {
  console.log('👤 Creating certifier with user data...')
  
  const { userData, certifierData } = request
  
  // Validate required fields for user
  if (!userData.firstName || !userData.lastName || !userData.email) {
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'firstName, lastName, and email are required for user creation'
      }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  // Validate required fields for certifier
  if (!certifierData.id_legal_entity) {
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'id_legal_entity is required for certifier creation'
      }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  try {
    // Start transaction-like operation
    console.log('🔄 Starting user and certifier creation transaction...')

    // 1. Create user first
    console.log('👤 Creating user...')
    const userDataToInsert = {
      idUser: userData.idUser || crypto.randomUUID(),
      firstName: userData.firstName,
      lastName: userData.lastName || 'N/A',
      email: userData.email,
      phone: userData.phone || null,
      profilePicture: userData.profilePicture || null,
      fullName: userData.fullName || `${userData.firstName} ${userData.lastName || ''}`.trim(),
      type: userData.type || 'certifier',
      hasWallet: userData.hasWallet || false,
      hasCv: userData.hasCv || false,
      idUserHash: userData.idUserHash || crypto.randomUUID(),
      profileCompleted: userData.profileCompleted || true,
      languageCodeApp: userData.languageCode || 'it',
      gender: userData.gender || null,
      dateOfBirth: userData.dateOfBirth || null,
      address: userData.address || null,
      city: userData.city || null,
      state: userData.state || null,
      postalCode: userData.postalCode || null,
      countryCode: userData.countryCode || null,
      createdAt: userData.createdAt || new Date().toISOString(),
      updatedAt: userData.updatedAt || null
    }

    const { data: userResult, error: userError } = await supabaseClient
      .from('user')
      .insert(userDataToInsert)
      .select()
      .single()

    if (userError) {
      console.error('❌ Error creating user:', userError)
      
      // Check if it's a duplicate key error (user already exists)
      if (userError.code === '23505') {
        return new Response(
          JSON.stringify({
            ok: false,
            message: 'User with this email already exists',
            error: userError.message
          }),
          {
            status: 409,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }
      
      throw new Error(`Failed to create user: ${userError.message}`)
    }

    console.log('✅ User created successfully:', userResult.idUser)

    // 2. Create certifier associated with the user
    console.log('🔗 Creating certifier...')
    const certifierDataToInsert = {
      id_certifier: certifierData.id_certifier || crypto.randomUUID(),
      id_certifier_hash: certifierData.id_certifier_hash || crypto.randomUUID(),
      id_legal_entity: certifierData.id_legal_entity,
      id_user: userResult.idUser, // Use the created user's ID
      active: certifierData.active !== undefined ? certifierData.active : true,
      role: certifierData.role || 'Certificatore',
      created_at: certifierData.created_at || new Date().toISOString(),
      updated_at: certifierData.updated_at || null,
      invitation_token: certifierData.invitation_token || null,
      kyc_passed: certifierData.kyc_passed || null,
      id_kyc_attempt: certifierData.id_kyc_attempt || null
    }

    const { data: certifierResult, error: certifierError } = await supabaseClient
      .from('certifier')
      .insert(certifierDataToInsert)
      .select()
      .single()

    if (certifierError) {
      console.error('❌ Error creating certifier:', certifierError)
      
      // If certifier creation fails, we should ideally rollback the user creation
      // For now, we'll log the error and continue
      console.warn('⚠️ User was created but certifier creation failed. Manual cleanup may be needed.')
      
      throw new Error(`Failed to create certifier: ${certifierError.message}`)
    }

    console.log('✅ Certifier created successfully:', certifierResult.id_certifier)

    // Return success response with both user and certifier data
    return new Response(
      JSON.stringify({
        ok: true,
        message: 'User and certifier created successfully',
        data: {
          user: userResult,
          certifier: certifierResult
        }
      }),
      {
        status: 201,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )

  } catch (operationError) {
    console.error('❌ Transaction failed:', operationError)
    
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'Failed to create user and certifier',
        error: operationError.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
}

async function handleCreateCertifier(supabaseClient: any, request: CreateCertifierRequest) {
  console.log('👤 Creating certifier only...')
  
  // Validate required fields
  const { data } = request
  if (!data.id_legal_entity) {
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'id_legal_entity is required'
      }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  // Generate IDs if not provided
  const certifierData = {
    id_certifier: data.id_certifier || crypto.randomUUID(),
    id_certifier_hash: data.id_certifier_hash || crypto.randomUUID(),
    id_legal_entity: data.id_legal_entity,
    id_user: data.id_user || null,
    active: data.active !== undefined ? data.active : true,
    role: data.role || null,
    created_at: data.created_at || new Date().toISOString(),
    updated_at: data.updated_at || null,
    invitation_token: data.invitation_token || null,
    kyc_passed: data.kyc_passed || null,
    id_kyc_attempt: data.id_kyc_attempt || null
  }

  const { data: result, error } = await supabaseClient
    .from('certifier')
    .insert(certifierData)
    .select()
    .single()

  if (error) {
    console.error('❌ Error creating certifier:', error)
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'Failed to create certifier',
        error: error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  console.log('✅ Certifier created successfully:', result.id_certifier)
  return new Response(
    JSON.stringify({
      ok: true,
      message: 'Certifier created successfully',
      data: result
    }),
    {
      status: 201,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  )
}

async function handleUpdateCertifier(supabaseClient: any, request: UpdateCertifierRequest) {
  console.log('📝 Updating certifier...')
  
  const { id_certifier, data } = request
  
  if (!id_certifier) {
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'id_certifier is required for update operation'
      }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  // Add updated_at timestamp
  const updateData = {
    ...data,
    updated_at: new Date().toISOString()
  }

  const { data: result, error } = await supabaseClient
    .from('certifier')
    .update(updateData)
    .eq('id_certifier', id_certifier)
    .select()
    .single()

  if (error) {
    console.error('❌ Error updating certifier:', error)
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'Failed to update certifier',
        error: error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  if (!result) {
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'Certifier not found'
      }),
      {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  console.log('✅ Certifier updated successfully:', result.id_certifier)
  return new Response(
    JSON.stringify({
      ok: true,
      message: 'Certifier updated successfully',
      data: result
    }),
    {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  )
}

async function handleDeleteCertifier(supabaseClient: any, request: DeleteCertifierRequest) {
  console.log('🗑️ Deleting certifier...')
  
  const { id_certifier } = request
  
  if (!id_certifier) {
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'id_certifier is required for delete operation'
      }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  const { data: result, error } = await supabaseClient
    .from('certifier')
    .delete()
    .eq('id_certifier', id_certifier)
    .select()
    .single()

  if (error) {
    console.error('❌ Error deleting certifier:', error)
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'Failed to delete certifier',
        error: error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  if (!result) {
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'Certifier not found'
      }),
      {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }

  console.log('✅ Certifier deleted successfully:', result.id_certifier)
  return new Response(
    JSON.stringify({
      ok: true,
      message: 'Certifier deleted successfully',
      data: result
    }),
    {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    }
  )
}