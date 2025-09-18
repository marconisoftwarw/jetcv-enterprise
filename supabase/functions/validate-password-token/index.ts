import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
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
    console.log('🔐 Validating password setup token...')

    // Create Supabase client with service role key for admin operations
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { token } = await req.json()

    if (!token) {
      return new Response(
        JSON.stringify({
          valid: false,
          message: 'Token is required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Check if token exists and is not expired
    const { data: user, error } = await supabaseClient
      .from('user')
      .select('idUser, password_setup_token, password_setup_expires_at')
      .eq('password_setup_token', token)
      .single()

    if (error || !user) {
      console.log('❌ Token not found or invalid')
      return new Response(
        JSON.stringify({
          valid: false,
          message: 'Invalid token'
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Check if token is expired
    const now = new Date()
    const expiresAt = new Date(user.password_setup_expires_at)

    if (now > expiresAt) {
      console.log('❌ Token expired')
      return new Response(
        JSON.stringify({
          valid: false,
          message: 'Token expired'
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    console.log('✅ Token is valid')
    return new Response(
      JSON.stringify({
        valid: true,
        message: 'Token is valid'
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )

  } catch (error) {
    console.error('❌ Error validating token:', error)
    
    return new Response(
      JSON.stringify({
        valid: false,
        message: 'Internal server error'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
