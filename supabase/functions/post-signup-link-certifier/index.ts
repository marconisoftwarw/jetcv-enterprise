import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    if (!supabaseUrl || !serviceKey) {
      return json(500, { ok: false, message: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY" });
    }
    const admin = createClient(supabaseUrl, serviceKey);

    // JWT opzionale: se presente lo uso per ricavare email/metadati
    const authHeader = req.headers.get("Authorization") ?? "";
    const jwt = authHeader.startsWith("Bearer ") ? authHeader.slice(7) : null;

    let authEmail: string | null = null;
    let authUserId: string | null = null;
    let authMeta: Record<string, unknown> = {};
    if (jwt) {
      const authed = createClient(supabaseUrl, jwt, { global: { headers: { Authorization: `Bearer ${jwt}` } } } as any);
      const { data, error } = await (authed as any).auth.getUser();
      if (!error && data?.user) {
        authEmail = data.user.email ?? null;
        authUserId = data.user.id ?? null;
        authMeta = data.user.user_metadata ?? {};
      }
    }

    const body = await safeJson(req);
    const email: string | null = body?.email ?? authEmail ?? null;
    if (!email) {
      return json(400, { ok: false, message: "Email obbligatoria (o passa Authorization JWT)" });
    }

    // 1) USER: trova per email; se non esiste, crea con type='certifier'
    let { data: userRow, error: userLookupErr } = await admin
      .from("user")
      .select("*")
      .eq("email", email)
      .maybeSingle();
    if (userLookupErr) {
      return json(500, { ok: false, message: "Errore lookup user", error: userLookupErr.message });
    }

    if (!userRow) {
      const resolvedIdUser = body?.id_user ?? authUserId ?? crypto.randomUUID();
      const firstName = body?.firstName ?? (authMeta as any)?.firstName ?? null;
      const lastName  = body?.lastName  ?? (authMeta as any)?.lastName  ?? null;

      const { data: insertedUser, error: insertUserErr } = await admin
        .from("user")
        .insert({
          idUser: resolvedIdUser,
          email,
          firstName,
          lastName: lastName ?? "N/A",
          fullName: [firstName, lastName].filter(Boolean).join(" ") || null,
          type: "certifier",
          idUserHash: crypto.randomUUID(),
          profileCompleted: true,
          languageCodeApp: "it",
          createdAt: new Date().toISOString(),
        })
        .select()
        .single();

      if (insertUserErr) {
        // in race, ritenta lookup
        if ((insertUserErr as any).code === "23505") {
          const { data: again, error: againErr } = await admin
            .from("user")
            .select("*")
            .eq("email", email)
            .single();
          if (againErr) return json(500, { ok: false, message: "Race su user.email e fetch fallita", error: againErr.message });
          userRow = again;
        } else {
          return json(500, { ok: false, message: "Errore insert user", error: insertUserErr.message });
        }
      } else {
        userRow = insertedUser;
      }
    } else if (userRow.type !== "certifier") {
      const { data: updated, error: updErr } = await admin
        .from("user")
        .update({ type: "certifier", updatedAt: new Date().toISOString() })
        .eq("idUser", userRow.idUser)
        .select()
        .single();
      if (updErr) return json(500, { ok: false, message: "Errore update user.type", error: updErr.message });
      userRow = updated;
    }

    const idUser = userRow.idUser as string;

    // 2) RECUPERA id_legal_entity DAL/I CERTIFIER ESISTENTE/I DI QUESTO USER
    //    priorità: active=true, altrimenti il più recente
    let id_legal_entity: string | null = null;

    // a) prova active=true
    {
      const { data: activeCert, error } = await admin
        .from("certifier")
        .select("id_legal_entity, created_at")
        .eq("id_user", idUser)
        .eq("active", true)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      if (error) return json(500, { ok: false, message: "Errore lookup certifier attivo", error: error.message });
      if (activeCert) id_legal_entity = activeCert.id_legal_entity;
    }

    // b) se non trovato, prendi l'ultimo creato
    if (!id_legal_entity) {
      const { data: lastCert, error } = await admin
        .from("certifier")
        .select("id_legal_entity, created_at")
        .eq("id_user", idUser)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      if (error) return json(500, { ok: false, message: "Errore lookup ultimo certifier", error: error.message });
      if (lastCert) id_legal_entity = lastCert.id_legal_entity;
    }

    // Se ancora null → non abbiamo modo di "recuperare" l'ente
    if (!id_legal_entity) {
      return json(400, {
        ok: false,
        message: "Nessun certifier esistente per questo utente: impossibile recuperare id_legal_entity. Passalo esplicitamente o definisci una regola di default.",
      });
    }

    // 3) ASSICURA/CREA IL CERTIFIER PER QUELL'ENTE (idempotente)
    // get-then-insert per evitare duplicati (non avendo UNIQUE su (id_user,id_legal_entity))
    const { data: existingCert, error: certLookupErr } = await admin
      .from("certifier")
      .select("*")
      .eq("id_user", idUser)
      .eq("id_legal_entity", id_legal_entity)
      .maybeSingle();
    if (certLookupErr) {
      return json(500, { ok: false, message: "Errore lookup certifier finale", error: certLookupErr.message });
    }

    let certRow = existingCert;
    if (!certRow) {
      const { data: insertedCert, error: insertCertErr } = await admin
        .from("certifier")
        .insert({
          id_certifier: crypto.randomUUID(),
          id_certifier_hash: crypto.randomUUID(),
          id_user: idUser,
          id_legal_entity,
          active: true,
          role: "Certificatore",
          created_at: new Date().toISOString(),
          updated_at: null,
        })
        .select()
        .single();

      if (insertCertErr) {
        // race-safe retry
        if ((insertCertErr as any).code === "23505") {
          const { data: againCert, error: againErr } = await admin
            .from("certifier")
            .select("*")
            .eq("id_user", idUser)
            .eq("id_legal_entity", id_legal_entity)
            .single();
          if (againErr) return json(500, { ok: false, message: "Race su certifier e fetch fallita", error: againErr.message });
          certRow = againCert;
        } else {
          return json(500, { ok: false, message: "Errore insert certifier", error: insertCertErr.message });
        }
      } else {
        certRow = insertedCert;
      }
    }

    return json(200, {
      ok: true,
      message: "User (type='certifier') sincronizzato e certifier assicurato usando id_legal_entity esistente",
      data: { user: userRow, certifier: certRow, id_legal_entity },
    });
  } catch (err: any) {
    console.error("❌ Unexpected error:", err);
    return json(500, { ok: false, message: "Internal server error", error: err?.message ?? String(err) });
  }
});

function json(status: number, payload: unknown) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function safeJson(req: Request) {
  try { return await req.json(); } catch { return {}; }
}
