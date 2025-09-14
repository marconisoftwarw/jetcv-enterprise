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
    // Create a Supabase client with the Auth context of the function
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Get the request body
    const { id } = await req.json()

    console.log('Getting Veriff session results for ID:', id)

    // For now, return a mock response
    // In a real implementation, you would call the Veriff API here
    const mockResults = {
      status: 'approved', // or 'declined', 'pending'
      decision: 'APPROVED', // or 'DECLINED', 'PENDING'
      reason: 'Document verification successful',
      timestamp: new Date().toISOString(),
      documents: [
        {
          type: 'passport',
          status: 'approved',
          confidence: 0.95
        }
      ]
    }

    const response = {
      success: true,
      sessionId: id,
      results: mockResults,
      message: 'Veriff session results retrieved successfully (mock)'
    }

    console.log('Mock Veriff session results:', response)

    return new Response(
      JSON.stringify(response),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    console.error('Error getting Veriff session results:', error)
    
    return new Response(
      JSON.stringify({ 
        success: false, 
        error: error.message,
        message: 'Failed to get Veriff session results'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      },
    )
  }
})
