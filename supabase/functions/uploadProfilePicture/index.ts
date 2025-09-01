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
    // Create Supabase client
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
    const { file, fileName, fileType, folder } = await req.json()

    if (!file || !fileName || !fileType) {
      throw new Error('Missing required parameters: file, fileName, fileType')
    }

    // Decode base64 file
    const fileData = Uint8Array.from(atob(file), c => c.charCodeAt(0))

    // Generate unique file name
    const timestamp = new Date().getTime()
    const uniqueFileName = `${timestamp}_${fileName}`

    // Determine folder path
    const folderPath = folder || 'profile-pictures'
    const filePath = `${folderPath}/${uniqueFileName}`

    // Upload file to Supabase Storage
    const { data, error } = await supabaseClient.storage
      .from('images')
      .upload(filePath, fileData, {
        contentType: fileType,
        upsert: false
      })

    if (error) {
      throw new Error(`Upload error: ${error.message}`)
    }

    // Get public URL
    const { data: urlData } = supabaseClient.storage
      .from('images')
      .getPublicUrl(filePath)

    return new Response(
      JSON.stringify({
        success: true,
        url: urlData.publicUrl,
        path: filePath
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error:', error.message)
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})
