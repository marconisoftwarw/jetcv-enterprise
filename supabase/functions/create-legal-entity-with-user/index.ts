import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

serve(async (req)=>{
  // Preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: corsHeaders
    });
  }
  if (req.method !== "POST") {
    return new Response(JSON.stringify({
      ok: false,
      message: "Method not allowed"
    }), {
      status: 405,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  }
  try {
    const supabase = createClient(Deno.env.get("SUPABASE_URL") ?? "", Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "");
    const { userData, legalEntityData } = await req.json();
    // --- VALIDAZIONI MINIME ---
    if (!userData?.email) {
      return new Response(JSON.stringify({
          ok: false,
        message: "Missing user email"
      }), {
          status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    if (!userData?.password) {
      return new Response(JSON.stringify({
            ok: false,
        message: "Missing required user field: password"
      }), {
            status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    if (!userData?.firstName || !userData?.fullName) {
      return new Response(JSON.stringify({
        ok: false,
        message: "Missing user firstName/fullName"
      }), {
        status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    if (!legalEntityData?.id_legal_entity_hash || !legalEntityData?.status) {
      return new Response(JSON.stringify({
            ok: false,
        message: "Missing legalEntity id_legal_entity_hash/status"
      }), {
            status: 400,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    console.log("🚀 Starting flow: Auth -> user -> legal_entity -> certifier");
    // 1) CREA UTENTE AUTH (o prosegui se esiste già)
    let authUserId = null;
    let authEmail = null;
    try {
      const { data, error } = await supabase.auth.admin.createUser({
        email: userData.email,
        password: userData.password,
        email_confirm: true,
        user_metadata: {
          firstName: userData.firstName,
          lastName: userData.lastName || "N/A",
          fullName: userData.fullName,
          idUserHash: userData.idUserHash
        }
      });
      if (error) {
        // Se l'utente esiste già, continuiamo
        console.warn("⚠️ Auth createUser error:", error.message);
        if (!/already exists|duplicate/i.test(error.message ?? "")) {
          return new Response(JSON.stringify({
            ok: false,
            message: "Failed to create auth user",
            error: error.message
          }), {
            status: 409,
            headers: {
              ...corsHeaders,
              "Content-Type": "application/json"
            }
          });
        }
      } else {
        authUserId = data.user?.id ?? null;
        authEmail = data.user?.email ?? null;
        console.log("✅ Auth user created:", authUserId);
      }
    } catch (e) {
      console.error("❌ Unexpected error creating auth user:", e);
      return new Response(JSON.stringify({
        ok: false,
        message: "Failed to create auth user",
        error: e.message
      }), {
        status: 500,
          headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    // 2) INSERISCI/UPSERT NELLA TABELLA public.user
    // Se abbiamo un id da Auth usiamolo come primary key per allineare user.idUser = auth.id
    const idUserToStore = authUserId ?? userData.idUser;
    if (!idUserToStore) {
      // fallback: se Auth non ha restituito id e non ci hai passato idUser, blocchiamo
      return new Response(JSON.stringify({
        ok: false,
        message: "Missing idUser: neither Auth returned one nor payload provided one"
      }), {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    // upsert su chiave primaria idUser per idempotenza
    const { data: userRow, error: userError } = await supabase.from("user").upsert({
      idUser: idUserToStore,
      firstName: userData.firstName,
      lastName: userData.lastName || "N/A",
      email: userData.email,
      phone: userData.phone ?? null,
      profilePicture: userData.profilePicture ?? null,
      fullName: userData.fullName,
      type: "legal_entity",
      hasWallet: userData.hasWallet ?? false,
      hasCv: userData.hasCv ?? false,
      idUserHash: userData.idUserHash,
      profileCompleted: userData.profileCompleted ?? false,
      languageCodeApp: userData.languageCode ?? userData.languageCodeApp ?? "it",
      createdAt: userData.createdAt ?? new Date().toISOString(),
      updatedAt: userData.updatedAt ?? null
    }, {
      onConflict: "idUser"
    }).select().single();
    if (userError) {
      console.error("❌ Error upserting user:", userError);
      return new Response(JSON.stringify({
        ok: false,
        message: `Failed to upsert user: ${userError.message}`
      }), {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    // 3) CREA/UPSERTA LEGAL ENTITY e collega created_by_id_user
    const legalEntityInsert = {
      id_legal_entity: legalEntityData.id_legal_entity ?? undefined,
      id_legal_entity_hash: legalEntityData.id_legal_entity_hash,
      legal_name: legalEntityData.legal_name ?? null,
      identifier_code: legalEntityData.identifier_code ?? null,
      operational_address: legalEntityData.operational_address ?? null,
      operational_city: legalEntityData.operational_city ?? null,
      operational_postal_code: legalEntityData.operational_postal_code ?? null,
      operational_state: legalEntityData.operational_state ?? null,
      operational_country: legalEntityData.operational_country ?? null,
      headquarter_address: legalEntityData.headquarter_address ?? null,
      headquarter_city: legalEntityData.headquarter_city ?? null,
      headquarter_postal_code: legalEntityData.headquarter_postal_code ?? null,
      headquarter_state: legalEntityData.headquarter_state ?? null,
      headquarter_country: legalEntityData.headquarter_country ?? null,
      legal_rapresentative: legalEntityData.legal_rapresentative ?? null,
      email: legalEntityData.email ?? null,
      phone: legalEntityData.phone ?? null,
      pec: legalEntityData.pec ?? null,
      website: legalEntityData.website ?? null,
      status: legalEntityData.status,
      logo_picture: legalEntityData.logo_picture ?? null,
      company_picture: legalEntityData.company_picture ?? null,
      created_at: legalEntityData.created_at ?? new Date().toISOString(),
      created_by_id_user: idUserToStore
    };
    // Idempotenza: upsert su id_legal_entity_hash (se unico nel tuo schema) oppure su id_legal_entity se lo passi sempre.
    // Qui uso id_legal_entity_hash; se preferisci la PK, cambia onConflict in "id_legal_entity".
    const { data: leRow, error: leError } = await supabase.from("legal_entity").upsert(legalEntityInsert, {
      onConflict: "id_legal_entity"
    }).select().single();
    if (leError) {
      console.error("❌ Error upserting legal_entity:", leError);
      return new Response(JSON.stringify({
          ok: false,
        message: `Failed to upsert legal entity: ${leError.message}`
      }), {
          status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json"
        }
      });
    }
    const idLegalEntity = leRow.id_legal_entity;
    // 4) CREA/UPSERTA CERTIFIER per collegare l'utente alla legal entity (ruolo "owner")
    // Vincolo FK: certifier.id_user -> public.user.idUser, certifier.id_legal_entity -> legal_entity.id_legal_entity
    // Idempotenza: uso (id_legal_entity, id_user) come chiave logica; se non hai unique su queste colonne,
    // RESPONSE OK
    return new Response(JSON.stringify({
      ok: true,
      idLegalEntity
    }), {
      status: 201,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  } catch (error) {
    console.error("❌ Unexpected error:", error);
    return new Response(JSON.stringify({
        ok: false,
      message: "Internal server error",
        error: error.message
    }), {
        status: 500,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json"
      }
    });
  }
});
