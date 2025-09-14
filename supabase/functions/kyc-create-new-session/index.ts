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
    // Create a Supabase client without authentication for public access
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    // Get the request body
    const { callback, firstName, lastName, additionalFields } = await req.json()

    console.log('Creating Veriff session for:', { firstName, lastName, additionalFields })

    // For now, return a mock response since we don't have Veriff API keys configured
    // In a real implementation, you would call the Veriff API here
    const mockSessionId = `veriff_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
    const mockVerificationUrl = `https://magic.veriff.com/v/veriff-${mockSessionId}`

    const response = {
      success: true,
      sessionId: mockSessionId,
      verificationUrl: mockVerificationUrl,
      status: 'created',
      message: 'Veriff session created successfully (mock)'
    }

    console.log('Mock Veriff session created:', response)

    return new Response(
      JSON.stringify(response),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error creating Veriff session:', error)
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message,
        message: 'Failed to create Veriff session'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})
