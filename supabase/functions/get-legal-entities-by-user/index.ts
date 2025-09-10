// supabase/functions/get-legal-of-user/index.ts
// Deno Edge Function - Ritorna le legal_entity collegate a un id_user tramite public.certifier
// CORS: stile "aperto" come in certifications/index.ts

// Tipi runtime Supabase (opzionale)
// import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const CORS_OPEN = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-service-auth"
};

function corsHeaders() {
  return CORS_OPEN;
}

function json(status: number, body: unknown) {
  return new Response(JSON.stringify(body, null, 2), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      ...corsHeaders()
    }
  });
}

async function readJson<T = any>(req: Request): Promise<T | undefined> {
  const ct = req.headers.get("content-type") || "";
  if (ct.includes("application/json")) {
    try {
      return await req.json();
    } catch {
      return undefined;
    }
  }
  return undefined;
}

function qp(url: URL, name: string) {
  const v = url.searchParams.get(name);
  return v === null ? undefined : v;
}

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function maskUuid(id?: string | null) {
  if (!id) return "(none)";
  return id.length > 12 ? `${id.slice(0, 8)}…${id.slice(-4)}` : id;
}

Deno.serve(async (req) => {
  const request_id = crypto.randomUUID();

  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders() });
  }

  // @ts-ignore deno-types
  const { createClient } = await import("https://esm.sh/@supabase/supabase-js@2");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"); // service role → bypass RLS

  if (!supabaseUrl || !serviceRoleKey) {
    return json(500, {
      ok: false,
      error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY",
      request_id
    });
  }

  // Client admin: NON passare Authorization utente
  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
  });

  // (opzionale) protezione con segreto
  const requiredSecret = Deno.env.get("SERVICE_WEBHOOK_SECRET");
  if (requiredSecret) {
    const provided = req.headers.get("x-service-auth");
    if (provided !== requiredSecret) {
      return json(403, { ok: false, error: "Forbidden", request_id });
    }
  }

  try {
    const url = new URL(req.url);

    // Input: POST (body) oppure GET (querystring)
    let id_user: string | undefined;
    if (req.method === "POST") {
      const body = await readJson<Record<string, unknown>>(req);
      id_user = (body?.id_user as string) ?? (body?.idUser as string);
    } else if (req.method === "GET") {
      id_user = (qp(url, "id_user") as string) ?? (qp(url, "idUser") as string);
    } else {
      return json(405, { ok: false, error: "Method Not Allowed", request_id });
    }

    if (!id_user || !UUID_RE.test(id_user)) {
      return json(400, {
        ok: false,
        error: "Bad Request",
        message: "id_user (UUID) is required and must be valid.",
        request_id,
        echo: { id_user: maskUuid(id_user) }
      });
    }

    // 1) Prendi le id_legal_entity da public.certifier filtrando per id_user
    const { data: certRows, error: certErr } = await admin
      .from("certifier")
      .select("id_legal_entity, active")
      .eq("id_user", id_user);
      // .eq("active", true) // se vuoi solo attivi

    if (certErr) {
      return json(500, { ok: false, error: certErr.message, request_id });
    }

    const ids = Array.from(
      new Set((certRows ?? []).map((r: any) => r.id_legal_entity))
    ).filter(Boolean) as string[];

    if (!ids.length) {
      return json(200, { ok: true, data: [], count: 0, request_id });
    }

    // 2) Carica le legal_entity corrispondenti
    const { data: leRows, error: leErr } = await admin
      .from("legal_entity")
      .select(`
        id_legal_entity,
        id_legal_entity_hash,
        legal_name,
        identifier_code,
        operational_address,
        operational_city,
        operational_postal_code,
        operational_state,
        operational_country,
        headquarter_address,
        headquarter_city,
        headquarter_postal_code,
        headquarter_state,
        headquarter_country,
        legal_rapresentative,
        email,
        phone,
        pec,
        website,
        status,
        logo_picture,
        company_picture,
        created_at,
        updated_at,
        created_by_id_user
      `)
      .in("id_legal_entity", ids)
      .order("updated_at", { ascending: false });

    if (leErr) {
      return json(500, { ok: false, error: leErr.message, request_id });
    }

    return json(200, {
      ok: true,
      data: leRows ?? [],
      count: leRows?.length ?? 0,
      request_id
    });
  } catch (e: any) {
    return json(500, {
      ok: false,
      error: "Server Error",
      message: e?.message ?? String(e),
      request_id
    });
  }
});
