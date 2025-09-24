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
    console.log('🔐 Resetting password...')

    // Create Supabase client with service role key for admin operations
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { token, password } = await req.json()

    if (!token || !password) {
      return new Response(
        JSON.stringify({
          ok: false,
          message: 'Token and password are required'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    if (password.length < 8) {
      return new Response(
        JSON.stringify({
          ok: false,
          message: 'Password must be at least 8 characters long'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Find user by password_reset_token
    const { data: user, error: userError } = await supabaseClient
      .from('user')
      .select('idUser, password_reset_token')
      .eq('password_reset_token', token)
      .single()

    if (userError || !user) {
      console.log('❌ User not found for reset token')
      return new Response(
        JSON.stringify({
          ok: false,
          message: 'Invalid or expired reset token'
        }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Update user password using Supabase Auth Admin API
    const { data: authData, error: authError } = await supabaseClient.auth.admin.updateUserById(
      user.idUser,
      { password: password }
    )

    if (authError) {
      console.error('❌ Error updating password:', authError)
      return new Response(
        JSON.stringify({
          ok: false,
          message: 'Failed to update password'
        }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Clear the password reset token
    const { error: clearError } = await supabaseClient
      .from('user')
      .update({
        password_reset_token: null,
        updatedAt: new Date().toISOString()
      })
      .eq('idUser', user.idUser)

    if (clearError) {
      console.error('❌ Error clearing password reset token:', clearError)
      // Don't fail the operation for this, just log the error
    }

    console.log('✅ Password reset successfully for user:', user.idUser)
    return new Response(
      JSON.stringify({
        ok: true,
        message: 'Password reset successfully'
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )

  } catch (error) {
    console.error('❌ Error resetting password:', error)
    
    return new Response(
      JSON.stringify({
        ok: false,
        message: 'Internal server error'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
