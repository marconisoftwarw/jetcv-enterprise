import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface UserData {
  idUser: string
  firstName: string
  lastName: string
  email: string
  phone?: string
  profilePicture?: string
  fullName: string
  type?: string
  languageCode?: string
  idUserHash: string
  profileCompleted?: boolean
  createdAt: string
  updatedAt?: string
}

interface LegalEntityData {
  idLegalEntity: string
  idLegalEntityHash: string
  legalName: string
  identifierCode?: string
  operationalAddress?: string
  operationalCity?: string
  operationalPostalCode?: string
  operationalState?: string
  operationalCountry?: string
  headquarterAddress?: string
  headquarterCity?: string
  headquarterPostalCode?: string
  headquarterState?: string
  headquarterCountry?: string
  legalRapresentative?: string
  email?: string
  phone?: string
  pec?: string
  website?: string
  logoPicture?: string
  companyPicture?: string
  status: string
  createdAt: string
  updatedAt?: string
  createdByIdUser: string
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    console.log('🚀 Starting legal entity creation with user...')

    // Create Supabase client with service role key for admin operations
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { userData, legalEntityData } = await req.json()

    console.log('📋 User data:', userData)
    console.log('🏢 Legal entity data:', legalEntityData)

    // Validate required fields
    if (!userData || !legalEntityData) {
      return new Response(
        JSON.stringify({
          ok: false,
          message: 'User data and legal entity data are required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Validate user data
    const requiredUserFields = ['idUser', 'firstName', 'email', 'fullName', 'idUserHash']
    for (const field of requiredUserFields) {
      if (!userData[field]) {
        return new Response(
          JSON.stringify({
            ok: false,
            message: `Missing required user field: ${field}`
          }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }
    }

    // Ensure lastName has a default value if empty
    if (!userData.lastName) {
      userData.lastName = 'N/A'
    }

    // Validate legal entity data - check both camelCase and snake_case versions
    const requiredEntityFields = [
      { camel: 'idLegalEntity', snake: 'id_legal_entity' },
      { camel: 'idLegalEntityHash', snake: 'id_legal_entity_hash' },
      { camel: 'legalName', snake: 'legal_name' },
      { camel: 'createdByIdUser', snake: 'created_by_id_user' }
    ]
    
    for (const field of requiredEntityFields) {
      const value = legalEntityData[field.camel] || legalEntityData[field.snake]
      if (!value) {
        return new Response(
          JSON.stringify({
            ok: false,
            message: `Missing required legal entity field: ${field.camel} or ${field.snake}`
          }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          }
        )
      }
    }

    // Start transaction-like operation
    try {
      // 1. Create user first
      console.log('👤 Creating user...')
      const { data: userResult, error: userError } = await supabaseClient
        .from('user')
        .insert({
          idUser: userData.idUser,
          firstName: userData.firstName,
          lastName: userData.lastName,
          email: userData.email,
          phone: userData.phone || null,
          profilePicture: userData.profilePicture || null,
          fullName: userData.fullName,
          type: userData.type || 'user',
          hasWallet: userData.hasWallet || false,
          hasCv: userData.hasCv || false,
          idUserHash: userData.idUserHash,
          profileCompleted: userData.profileCompleted || false,
          languageCodeApp: userData.languageCode || userData.languageCodeApp || 'it',
          createdAt: userData.createdAt,
          updatedAt: userData.updatedAt || null
        })
        .select()
        .single()

      if (userError) {
        console.error('❌ Error creating user:', userError)
        
        // Check if it's a duplicate key error
        if (userError.code === '23505') {
          console.log('⚠️ User already exists, continuing with legal entity creation...')
        } else {
          throw new Error(`Failed to create user: ${userError.message}`)
        }
      } else {
        console.log('✅ User created successfully:', userResult.idUser)
      }

      // 2. Create legal entity
      console.log('🏢 Creating legal entity...')
      const { data: entityResult, error: entityError } = await supabaseClient
        .from('legal_entity')
        .insert({
          id_legal_entity: legalEntityData.id_legal_entity,
          id_legal_entity_hash: legalEntityData.id_legal_entity_hash,
          legal_name: legalEntityData.legal_name,
          identifier_code: legalEntityData.identifier_code || null,
          operational_address: legalEntityData.operational_address || null,
          operational_city: legalEntityData.operational_city || null,
          operational_postal_code: legalEntityData.operational_postal_code || null,
          operational_state: legalEntityData.operational_state || null,
          operational_country: legalEntityData.operational_country || null,
          headquarter_address: legalEntityData.headquarter_address || null,
          headquarter_city: legalEntityData.headquarter_city || null,
          headquarter_postal_code: legalEntityData.headquarter_postal_code || null,
          headquarter_state: legalEntityData.headquarter_state || null,
          headquarter_country: legalEntityData.headquarter_country || null,
          legal_rapresentative: legalEntityData.legal_rapresentative || null,
          email: legalEntityData.email || null,
          phone: legalEntityData.phone || null,
          pec: legalEntityData.pec || null,
          website: legalEntityData.website || null,
          logo_picture: legalEntityData.logo_picture || null,
          company_picture: legalEntityData.company_picture || null,
          status: legalEntityData.status || 'pending',
          created_at: legalEntityData.created_at,
          updated_at: legalEntityData.updated_at || null,
          created_by_id_user: legalEntityData.created_by_id_user || legalEntityData.createdByIdUser
        })
        .select()
        .single()

      if (entityError) {
        console.error('❌ Error creating legal entity:', entityError)
        
        // If user was created but entity creation failed, we might want to clean up
        // For now, we'll just throw the error
        throw new Error(`Failed to create legal entity: ${entityError.message}`)
      }

      console.log('✅ Legal entity created successfully:', entityResult.id_legal_entity)

      // 3. Update user type to 'legal_entity'
      console.log('🔄 Updating user type to legal_entity...')
      try {
        const updateUserResponse = await fetch(`${supabaseUrl}/functions/v1/update-user-to-legalentity`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${supabaseServiceKey}`,
          },
          body: JSON.stringify({
            user_id: userData.idUser,
            legal_entity_id: entityResult.id_legal_entity
          })
        })

        if (updateUserResponse.ok) {
          const updateResult = await updateUserResponse.json()
          console.log('✅ User type updated to legal_entity successfully:', updateResult)
        } else {
          console.warn('⚠️ Warning: Could not update user type to legal_entity:', await updateUserResponse.text())
          // Don't fail the entire operation for this
        }
      } catch (updateError) {
        console.warn('⚠️ Warning: Error calling update-user-to-legalentity:', updateError)
        // Don't fail the entire operation for this
      }

      // 4. Create certifier relationship (optional - user becomes certifier for their own entity)
      console.log('🔗 Creating certifier relationship...')
      const certifierData = {
        id_certifier: crypto.randomUUID(),
        id_certifier_hash: crypto.randomUUID(),
        id_legal_entity: entityResult.id_legal_entity,
        id_user: userData.idUser,
        active: true,
        role: 'owner',
        created_at: new Date().toISOString(),
        invitation_token: null,
        kyc_passed: false
      }

      const { data: certifierResult, error: certifierError } = await supabaseClient
        .from('certifier')
        .insert(certifierData)
        .select()
        .single()

      if (certifierError) {
        console.warn('⚠️ Warning: Could not create certifier relationship:', certifierError.message)
        // Don't fail the entire operation for this
      } else {
        console.log('✅ Certifier relationship created successfully:', certifierResult.id_certifier)
      }

      // Return success response
      return new Response(
        JSON.stringify({
          ok: true,
          message: 'Legal entity and user created successfully',
          data: {
            user: userResult || { idUser: userData.idUser, message: 'User already existed' },
            legalEntity: entityResult,
            certifier: certifierResult || null
          }
        }),
        {
          status: 201,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )

    } catch (operationError) {
      console.error('❌ Operation failed:', operationError)
      
      return new Response(
        JSON.stringify({
          ok: false,
          message: 'Failed to create legal entity and user',
          error: operationError.message
        }),
        {
          status: 500,
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
