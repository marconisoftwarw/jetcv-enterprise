import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: corsHeaders
    });
  }

  const reqId = crypto.randomUUID();
  console.log(`[${reqId}] Starting update-user-to-legalentity function`);

  try {
    // Create Supabase client with service role key for admin operations
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    
    const admin = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });

    // Parse request body
    let requestData;
    try {
      const contentType = req.headers.get('content-type');
      if (contentType?.includes('application/json')) {
        requestData = await req.json();
      } else {
        const formData = await req.formData();
        requestData = {
          user_id: String(formData.get('user_id') || ''),
          legal_entity_id: formData.get('legal_entity_id') ? String(formData.get('legal_entity_id')) : undefined
        };
      }
    } catch (parseError) {
      console.error(`[${reqId}] Error parsing request:`, parseError);
      return new Response(JSON.stringify({
        error: 'Invalid request format',
        details: parseError.message
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }

    // Validate required fields
    if (!requestData.user_id) {
      console.error(`[${reqId}] Missing required field: user_id`);
      return new Response(JSON.stringify({
        error: 'user_id is required'
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }

    console.log(`[${reqId}] Updating user type for user: ${requestData.user_id}`);
    if (requestData.legal_entity_id) {
      console.log(`[${reqId}] Legal entity ID: ${requestData.legal_entity_id}`);
    }

    // Update user type to 'legal_entity'
    const { data: updatedUser, error: updateError } = await admin.from('user').update({
      type: 'legal_entity',
      updatedAt: new Date().toISOString()
    }).eq('idUser', requestData.user_id).select('idUser, firstName, lastName, email, type, updatedAt').single();

    if (updateError) {
      console.error(`[${reqId}] Error updating user type:`, updateError);
      return new Response(JSON.stringify({
        error: 'Failed to update user type',
        details: updateError.message
      }), {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }

    if (!updatedUser) {
      console.error(`[${reqId}] User not found: ${requestData.user_id}`);
      return new Response(JSON.stringify({
        error: 'User not found'
      }), {
        status: 404,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json'
        }
      });
    }

    console.log(`[${reqId}] Successfully updated user type to legal_entity:`, {
      user_id: updatedUser.idUser,
      name: `${updatedUser.firstName} ${updatedUser.lastName}`,
      email: updatedUser.email,
      type: updatedUser.type,
      updated_at: updatedUser.updatedAt
    });

    // If legal_entity_id is provided, also create a certifier record
    if (requestData.legal_entity_id) {
      console.log(`[${reqId}] Creating certifier record for legal entity: ${requestData.legal_entity_id}`);
      
      // Generate certifier hash
      const certifierHash = crypto.randomUUID();
      
      const { data: certifier, error: certifierError } = await admin.from('certifier').insert({
        id_certifier_hash: certifierHash,
        id_legal_entity: requestData.legal_entity_id,
        id_user: requestData.user_id,
        active: true,
        role: 'certifier',
        kyc_passed: false // Will be updated after KYC completion
      }).select('id_certifier, id_certifier_hash, id_legal_entity, id_user, active, role').single();

      if (certifierError) {
        console.error(`[${reqId}] Error creating certifier record:`, certifierError);
        // Don't fail the entire request if certifier creation fails
        // The user type is still updated successfully
      } else {
        console.log(`[${reqId}] Successfully created certifier record:`, certifier);
      }
    }

    // Return success response
    const response = {
      success: true,
      message: 'User type updated to legal_entity successfully',
      data: {
        user: updatedUser,
        certifier_created: !!requestData.legal_entity_id
      }
    };

    console.log(`[${reqId}] Function completed successfully`);
    return new Response(JSON.stringify(response), {
      status: 200,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });

  } catch (error) {
    console.error(`[${reqId}] Unexpected error:`, error);
    return new Response(JSON.stringify({
      error: 'Internal server error',
      details: error.message
    }), {
      status: 500,
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/json'
      }
    });
  }
});
