const CORS_OPEN = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};

function corsHeaders() {
  return CORS_OPEN;
}

function nowIso() {
  return new Date().toISOString();
}

function qp(url: URL, name: string) {
  const v = url.searchParams.get(name);
  return v === null ? undefined : v;
}

function qbool(v: any) {
  if (!v) return false;
  return v === "1" || v.toLowerCase() === "true";
}

function redact(key: string) {
  if (!key) return "(missing)";
  return key.length <= 8 ? "***" : `${key.slice(0, 4)}…${key.slice(-4)}`;
}

function inferFileType(ct: string) {
  if (!ct) return "file";
  if (ct.startsWith("image/")) return "image";
  if (ct.startsWith("video/")) return "video";
  if (ct.startsWith("audio/")) return "audio";
  return "file";
}

async function sha256Hex(bytes: Uint8Array) {
  const h = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(h)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

function pickUserOtp(m: any) {
  if (!m || typeof m !== "object") return null;
  const id_user = m.id_user ?? m.user_id ?? m.idUser ?? m.userId ?? m.user?.id;
  const id_otp = m.id_otp ?? m.otp_id ?? m.idOtp ?? m.otpId ?? m.otp?.id;
  if (id_user && id_otp) {
    return {
      id_user: String(id_user),
      id_otp: String(id_otp),
      status: "pending",
      rejection_reason: m.rejection_reason ?? null
    };
  }
  return null;
}

async function safeJsonParse(req: Request, reqId: string, label: string) {
  const ct = req.headers.get("content-type") || "";
  if (!ct.includes("application/json")) return undefined;
  try {
    const parsed = await req.json();
    console.debug(`[${reqId}] [${label}] JSON keys:`, Object.keys(parsed || {}));
    return parsed;
  } catch (e) {
    console.error(`[${reqId}] [${label}] JSON parse error:`, e?.message || e);
    throw e;
  }
}

// ---- OTP claim helper: associa OTP -> user & legal entity (no status/locked_at) ----
async function claimOtpsOr409(admin: any, pairs: any[], id_legal_entity: string) {
  if (!pairs || !pairs.length) return;
  // dedup per id_otp mantenendo mapping otp->user
  const byOtp = new Map();
  for (const p of pairs) {
    if (!p || !p.id_otp || !p.id_user) continue;
    if (!byOtp.has(p.id_otp)) byOtp.set(p.id_otp, p.id_user);
  }
  const otpIds = Array.from(byOtp.keys());
  const now = nowIso();
  // 1) leggi stato attuale degli OTP
  const { data: rows, error: selErr } = await admin.from("otp").select("id_otp, used_by_id_user, burned_at, expires_at").in("id_otp", otpIds);
  if (selErr) throw new Error(`Failed to read OTP state: ${selErr.message}`);
  // 3) claim per-OTP con guardie anti-race
  for (const [id_otp, id_user] of byOtp.entries()) {
    const { data: upd, error: updErr } = await admin.from("otp").update({
      used_by_id_user: id_user,
      id_legal_entity: id_legal_entity,
      used_at: now,
      burned_at: now
    }).eq("id_otp", id_otp).select("id_otp");
    if (updErr) throw new Error(`Failed to claim OTP ${id_otp}: ${updErr.message}`);
    if (!upd || upd.length !== 1) {
      const err = new Error(`OTP ${id_otp} could not be claimed (race or unavailable).`);
      // @ts-ignore
      err._http409 = true;
      throw err;
    }
  }
}

Deno.serve(async (req) => {
  const reqId = crypto.randomUUID();
  const t0 = Date.now();
  const url = new URL(req.url);
  console.log(`[${reqId}] ===== Incoming ${nowIso()} =====`);
  console.log(`[${reqId}] ${req.method} ${url.pathname}${url.search}`);
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: corsHeaders()
    });
  }
  // @ts-ignore deno-types
  const { createClient } = await import("https://esm.sh/@supabase/supabase-js@2");
  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  console.log(`[${reqId}] Env -> URL:${!!supabaseUrl} SRK:${serviceRoleKey ? "present" : "missing"}`);
  if (!supabaseUrl || !serviceRoleKey) {
    return new Response(JSON.stringify({
      error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY"
    }), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders()
      },
      status: 500
    });
  }
  const admin = createClient(supabaseUrl, serviceRoleKey);
  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({
        error: "Method not allowed"
      }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders()
        },
        status: 405
      });
    }
    const ct = req.headers.get("content-type") || "";
    // ======================= JSON BRANCH =======================
    if (ct.includes("application/json")) {
      const body = await safeJsonParse(req, reqId, "JSON") ?? {};
      const cert = body.certification || {};
      const usersIn = Array.isArray(body.users) ? body.users : [];
      const mediaIn = Array.isArray(body.media) ? body.media : [];
      
      // Verifica che certification esista e abbia i campi richiesti
      if (!body.certification) {
        return new Response(JSON.stringify({
          error: "Missing certification object in request body"
        }), {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders()
          },
          status: 400
        });
      }
      
      const required = [
        cert.id_certifier,
        cert.id_legal_entity,
        cert.id_location,
        cert.n_users,
        cert.id_certification_category
      ];
      if (required.some((v) => !v)) {
        return new Response(JSON.stringify({
          error: "Missing required fields in certification"
        }), {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders()
          },
          status: 400
        });
      }
      // FK precheck
      const [le, loc, cat] = await Promise.all([
        admin.from("legal_entity").select("id_legal_entity").eq("id_legal_entity", String(cert.id_legal_entity)).maybeSingle(),
        admin.from("location").select("id_location").eq("id_location", String(cert.id_location)).maybeSingle(),
        admin.from("certification_category").select("id_certification_category").eq("id_certification_category", String(cert.id_certification_category)).maybeSingle()
      ]);
      if (!le.data) return new Response(JSON.stringify({
        error: "Invalid id_legal_entity: not found"
      }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders()
        },
        status: 400
      });
      if (!loc.data) return new Response(JSON.stringify({
        error: "Invalid id_location: not found"
      }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders()
        },
        status: 400
      });
      if (!cat.data) return new Response(JSON.stringify({
        error: "Invalid id_certification_category: not found"
      }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders()
        },
        status: 400
      });
      // Certifier autocreate se non esiste
      const certifierId = String(cert.id_certifier);
      const { data: existingCertifier } = await admin.from("certifier").select("id_certifier").eq("id_certifier", certifierId).maybeSingle();
      if (!existingCertifier) {
        const { error: ccErr } = await admin.from("certifier").insert({
          id_certifier: certifierId,
          id_certifier_hash: crypto.randomUUID(),
          id_legal_entity: String(cert.id_legal_entity)
        }).single();
        if (ccErr) {
          return new Response(JSON.stringify({
            error: `Failed to create certifier: ${ccErr.message}`
          }), {
            headers: {
              "Content-Type": "application/json",
              ...corsHeaders()
            },
            status: 400
          });
        }
      }
      // Insert certification (status: sent)
      const insertPayload = {
        id_certification_hash: crypto.randomUUID(),
        id_certifier: certifierId,
        id_legal_entity: String(cert.id_legal_entity),
        id_location: String(cert.id_location),
        n_users: Number(cert.n_users),
        id_certification_category: String(cert.id_certification_category),
        status: "sent",
        sent_at: cert.sent_at || nowIso(),
        draft_at: cert.draft_at || nowIso(),
        closed_at: cert.closed_at ?? null
      };
      const { data: certRow, error: certErr } = await admin.from("certification").insert(insertPayload).select("*").single();
      if (certErr) {
        return new Response(JSON.stringify({
          error: certErr.message
        }), {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders()
          },
          status: 400
        });
      }
      // Users -> pending (claim OTP prima di inserire certification_user)
      const mappedUsers = usersIn.map(pickUserOtp).filter(Boolean);
      let usersRows: any[] = [];
      let informationValues: any[] = [];
      
      if (mappedUsers.length) {
        // dedup & FK
        const seen = new Set();
        const dedup = mappedUsers.filter((u) => {
          const k = `${u.id_user}::${u.id_otp}`;
          if (seen.has(k)) return false;
          seen.add(k);
          return true;
        });
        const uniqUsers = [
          ...new Set(dedup.map((u) => u.id_user))
        ];
        const uniqOtps = [
          ...new Set(dedup.map((u) => u.id_otp))
        ];
        const [{ data: userOk, error: uErr }, { data: otpOk, error: oErr }] = await Promise.all([
          admin.from("user").select("idUser").in("idUser", uniqUsers),
          admin.from("otp").select("id_otp").in("id_otp", uniqOtps)
        ]);
        if (uErr || oErr) {
          return new Response(JSON.stringify({
            error: `FK check failed: ${uErr?.message || oErr?.message}`
          }), {
            headers: {
              "Content-Type": "application/json",
              ...corsHeaders()
            },
            status: 400
          });
        }
        const okUsers = new Set((userOk ?? []).map((r) => r.idUser));
        const okOtps = new Set((otpOk ?? []).map((r) => r.id_otp));
        const invalid = dedup.find((u) => !okUsers.has(u.id_user) || !okOtps.has(u.id_otp));
        if (invalid) {
          return new Response(JSON.stringify({
            error: "Invalid id_user or id_otp in users"
          }), {
            headers: {
              "Content-Type": "application/json",
              ...corsHeaders()
            },
            status: 400
          });
        }
        // Claim OTPs
        try {
          const otpPairs = dedup.map((u) => ({
            id_otp: u.id_otp,
            id_user: u.id_user
          }));
          await claimOtpsOr409(admin, otpPairs, String(certRow.id_legal_entity));
        } catch (e) {
          const status = e?._http409 ? 409 : 400;
          return new Response(JSON.stringify({
            error: e.message || String(e)
          }), {
            headers: {
              "Content-Type": "application/json",
              ...corsHeaders()
            },
            status
          });
        }
        // 1) leggi coppie già presenti
        const { data: existingCu, error: selErr } = await admin.from("certification_user").select("id_user,id_otp,id_certification_user").eq("id_certification", certRow.id_certification).in("id_user", uniqUsers).in("id_otp", uniqOtps);
        if (selErr) {
          return new Response(JSON.stringify({
            error: `Failed to check existing certification_user: ${selErr.message}`
          }), {
            headers: {
              "Content-Type": "application/json",
              ...corsHeaders()
            },
            status: 400
          });
        }
        const existingPairs = new Set((existingCu ?? []).map((r) => `${r.id_user}::${r.id_otp}`));
        // 2) inserisci solo nuove
        const toInsert = dedup.filter((u) => !existingPairs.has(`${u.id_user}::${u.id_otp}`)).map((u) => ({
          id_certification: certRow.id_certification,
          id_user: u.id_user,
          id_otp: u.id_otp,
          status: "pending",
          rejection_reason: u.rejection_reason ?? null
        }));
        let cuDataAll = [];
        if (toInsert.length) {
          const { data: insCu, error: insErr } = await admin.from("certification_user").insert(toInsert).select("*");
          if (insErr) {
            return new Response(JSON.stringify({
              error: `Failed to insert certification_user: ${insErr.message}`
            }), {
              headers: {
                "Content-Type": "application/json",
                ...corsHeaders()
              },
              status: 400
            });
          }
          cuDataAll = insCu ?? [];
        }
        usersRows = [
          ...(existingCu ?? []).map((r) => ({
            id_certification: certRow.id_certification,
            id_user: r.id_user,
            id_otp: r.id_otp,
            id_certification_user: r.id_certification_user,
            status: "pending",
            rejection_reason: null
          })),
          ...cuDataAll
        ];

        // Gestione esito e titolo: recupera le informazioni di certificazione
      console.log(`[${reqId}] Looking for certification information for legal_entity: ${String(cert.id_legal_entity)}`);
      console.log(`[${reqId}] Users rows count: ${usersRows.length}`);
      console.log(`[${reqId}] Esito value from body:`, body.esito_value);
      console.log(`[${reqId}] Titolo value from body:`, body.titolo_value);
      console.log(`[${reqId}] Titolo value type:`, typeof body.titolo_value);
      console.log(`[${reqId}] Titolo value length:`, body.titolo_value?.length);
        
        // Verifica la struttura della tabella
        const { data: tableInfo, error: tableErr } = await admin
          .from("certification_information_value")
          .select("*")
          .limit(1);
        console.log(`[${reqId}] Table structure check:`, { tableInfo, tableErr });
        
        // Verifica la struttura della tabella con una query di test
        try {
          const { data: testInsert, error: testErr } = await admin
            .from("certification_information_value")
            .insert({
              id_certification_information: "00000000-0000-0000-0000-000000000000",
              id_certification: "00000000-0000-0000-0000-000000000000",
              id_certification_user: null,
              value: "TEST_VALUE"
            })
            .select("*")
            .single();
          console.log(`[${reqId}] Test insert result:`, { testInsert, testErr });
          
          // Cancella il record di test
          if (testInsert) {
            await admin
              .from("certification_information_value")
              .delete()
              .eq("id_certification_information_value", testInsert.id_certification_information_value);
          }
        } catch (testError) {
          console.log(`[${reqId}] Test insert failed:`, testError);
        }
        
        // Recupera sia esito che titolo
        const [{ data: esitoInfo, error: esitoErr }, { data: titoloInfo, error: titoloErr }] = await Promise.all([
          admin
            .from("certification_information")
            .select("id_certification_information, name, label, type, scope")
            .or(`id_legal_entity.eq.${String(cert.id_legal_entity)},id_legal_entity.is.null`)
            .eq("name", "esito")
            .maybeSingle(),
          admin
            .from("certification_information")
            .select("id_certification_information, name, label, type, scope")
            .or(`id_legal_entity.eq.${String(cert.id_legal_entity)},id_legal_entity.is.null`)
            .eq("name", "titolo")
            .maybeSingle()
        ]);

        console.log(`[${reqId}] Esito info query result:`, { esitoInfo, esitoErr });
        console.log(`[${reqId}] Titolo info query result:`, { titoloInfo, titoloErr });

        // Crea array per tutti i valori da inserire
        const allValuesToInsert = [];

        // Gestione esito (per ogni utente)
        if (esitoErr) {
          console.warn(`[${reqId}] Error fetching esito information:`, esitoErr.message);
        } else if (esitoInfo) {
          console.log(`[${reqId}] Found esito information:`, esitoInfo);
          console.log(`[${reqId}] Esito value from body:`, body.esito_value);
          // Crea i valori di esito per ogni utente
          const esitoValues = usersRows.map((user) => {
            const esitoValue = {
              id_certification_information: esitoInfo.id_certification_information,
              id_certification: certRow.id_certification,
              id_certification_user: user.id_certification_user || null,
              value: body.esito_value !== null && body.esito_value !== undefined ? String(body.esito_value) : "0"
            };
            console.log(`[${reqId}] Mapped esito value for user ${user.id_user}:`, esitoValue);
            return esitoValue;
          });
          allValuesToInsert.push(...esitoValues);
        }

        // Gestione titolo (una sola volta, senza id_certification_user)
        if (titoloErr) {
          console.warn(`[${reqId}] Error fetching titolo information:`, titoloErr.message);
        } else if (titoloInfo) {
          console.log(`[${reqId}] Found titolo information:`, titoloInfo);
          console.log(`[${reqId}] Titolo value from body:`, body.titolo_value);
          const titoloValue = {
            id_certification_information: titoloInfo.id_certification_information,
            id_certification: certRow.id_certification,
            id_certification_user: null, // Titolo non ha id_certification_user
            value: body.titolo_value !== null && body.titolo_value !== undefined ? String(body.titolo_value) : ""
          };
          console.log(`[${reqId}] Mapped titolo value:`, titoloValue);
          allValuesToInsert.push(titoloValue);
        }

        if (allValuesToInsert.length > 0) {
          console.log(`[${reqId}] Prepared all values to insert:`, allValuesToInsert);

          // Inserisci tutti i valori uno alla volta
          console.log(`[${reqId}] Attempting to insert ${allValuesToInsert.length} values one by one...`);
          
          const insertedValues = [];
          
          for (let i = 0; i < allValuesToInsert.length; i++) {
            const val = allValuesToInsert[i];
            // Prova insert con valori espliciti nell'ordine corretto
            const singleInsertData = {
              value: val.value,
              id_certification_information: val.id_certification_information,
              id_certification: val.id_certification,
              id_certification_user: val.id_certification_user
            };
            
            console.log(`[${reqId}] ===== INSERTING VALUE ${i + 1}/${allValuesToInsert.length} =====`);
            console.log(`[${reqId}] Single insert data:`, singleInsertData);
            console.log(`[${reqId}] Value field specifically:`, val.value);
            console.log(`[${reqId}] About to insert into certification_information_value...`);
            
            // Prova insert con specifica esplicita dei campi nell'ordine corretto
            console.log(`[${reqId}] Inserting with explicit field order...`);
            
            const { data: singleInserted, error: singleError } = await admin
              .from("certification_information_value")
              .insert({
                id_certification_information: val.id_certification_information,
                id_certification: val.id_certification,
                id_certification_user: val.id_certification_user,
                value: val.value
              })
              .select("id_certification_information_value, id_certification_information, id_certification, id_certification_user, value, created_at, updated_at")
              .single();

            if (singleError) {
              console.error(`[${reqId}] Error inserting single value ${i + 1}:`, singleError);
              console.error(`[${reqId}] Error details:`, JSON.stringify(singleError, null, 2));
            } else {
              console.log(`[${reqId}] Successfully inserted single value ${i + 1}:`, singleInserted);
              console.log(`[${reqId}] Inserted value field:`, singleInserted?.value);
              console.log(`[${reqId}] Inserted ID field:`, singleInserted?.id_certification_information_value);
              insertedValues.push(singleInserted);
            }
          }
          
        informationValues = insertedValues;
        console.log(`[${reqId}] All values inserted. Total: ${insertedValues.length}`);
      } else {
        console.log(`[${reqId}] No certification information found for legal_entity: ${String(cert.id_legal_entity)}`);
        console.log(`[${reqId}] Skipping values creation - no certification_information found`);
      }

      // Gestione media titles dal media_metadata
      const mediaMetadataStr = body.media_metadata;
      if (mediaMetadataStr && Array.isArray(mediaMetadataStr)) {
        console.log(`[${reqId}] Processing media metadata for titles:`, mediaMetadataStr);
        
        // Cerca o crea una certification_information per i titoli dei media
        const { data: mediaTitleInfo, error: mediaTitleErr } = await admin
          .from("certification_information")
          .select("id_certification_information, name, label, type, scope")
          .or(`id_legal_entity.eq.${String(cert.id_legal_entity)},id_legal_entity.is.null`)
          .eq("name", "media_title")
          .maybeSingle();

        if (mediaTitleErr) {
          console.warn(`[${reqId}] Error fetching media_title information:`, mediaTitleErr.message);
        } else if (mediaTitleInfo) {
          console.log(`[${reqId}] Found media_title information:`, mediaTitleInfo);
          
          // Crea i valori per ogni titolo media
          const mediaTitleValues = mediaMetadataStr.map((metadata, index) => {
            const titleValue = {
              id_certification_information: mediaTitleInfo.id_certification_information,
              id_certification: certRow.id_certification,
              id_certification_user: null, // Media title non ha id_certification_user
              value: metadata.title || ""
            };
            console.log(`[${reqId}] Mapped media title value ${index}:`, titleValue);
            return titleValue;
          });

          // Inserisci i valori dei titoli media
          for (let i = 0; i < mediaTitleValues.length; i++) {
            const val = mediaTitleValues[i];
            console.log(`[${reqId}] Inserting media title value ${i + 1}:`, val);
            
            const { data: insertedTitle, error: titleError } = await admin
              .from("certification_information_value")
              .insert({
                id_certification_information: val.id_certification_information,
                id_certification: val.id_certification,
                id_certification_user: val.id_certification_user,
                value: val.value
              })
              .select("id_certification_information_value, id_certification_information, id_certification, id_certification_user, value, created_at, updated_at")
              .single();

            if (titleError) {
              console.error(`[${reqId}] Error inserting media title value ${i + 1}:`, titleError);
            } else {
              console.log(`[${reqId}] Successfully inserted media title value ${i + 1}:`, insertedTitle);
              informationValues.push(insertedTitle);
            }
          }
        } else {
          console.log(`[${reqId}] No media_title certification_information found, skipping media title values`);
        }
      } else {
        console.log(`[${reqId}] No media metadata provided, skipping media title processing`);
      }
      }
      // Media -> insert (no upload in JSON branch)
      let mediaRows: any[] = [];
      if (mediaIn.length) {
        const payloads = mediaIn.map((m) => ({
          id_media_hash: m.id_media_hash ?? crypto.randomUUID(),
          id_certification: certRow.id_certification,
          name: m.name ?? null,
          description: m.description ?? null,
          acquisition_type: m.acquisition_type ?? "deferred",
          captured_at: m.captured_at ?? nowIso(),
          id_location: m.id_location ?? null,
          file_type: m.file_type ?? "document"
        }));
        const { data: ins, error: mErr } = await admin.from("certification_media").insert(payloads).select("*");
        if (mErr) {
          return new Response(JSON.stringify({
            error: mErr.message
          }), {
            headers: {
              "Content-Type": "application/json",
              ...corsHeaders()
            },
            status: 400
          });
        }
        mediaRows = ins ?? [];
        // Link table (best-effort)
        admin.from("certification_has_media").insert(mediaRows.map((r) => ({
          id_certification: certRow.id_certification,
          id_certification_media: r.id_certification_media
        }))).catch(() => {});
      }
      return new Response(JSON.stringify({
        data: {
          ...certRow,
          users: usersRows,
          media: mediaRows,
          information_values: informationValues
        }
      }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders()
        },
        status: 201
      });
    }
    // ======================= MULTIPART BRANCH =======================
    if (!ct.includes("multipart/form-data")) {
      return new Response(JSON.stringify({
        error: "Unsupported content-type. Use application/json or multipart/form-data"
      }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders()
        },
        status: 400
      });
    }
    const form = await req.formData();
    const id_certifier = String(form.get("id_certifier") || "");
    const id_legal_entity = String(form.get("id_legal_entity") || "");
    const id_location = String(form.get("id_location") || "");
    const n_users = Number(form.get("n_users") ?? 0);
    const id_certification_category = String(form.get("id_certification_category") || "");
    if (!id_certifier || !id_legal_entity || !id_location || !id_certification_category) {
      return new Response(JSON.stringify({
        error: "Missing required fields in multipart body"
      }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders()
        },
        status: 400
      });
    }
    // FK prechecks
    const [le, loc, cat] = await Promise.all([
      admin.from("legal_entity").select("id_legal_entity").eq("id_legal_entity", id_legal_entity).maybeSingle(),
      admin.from("location").select("id_location").eq("id_location", id_location).maybeSingle(),
      admin.from("certification_category").select("id_certification_category").eq("id_certification_category", id_certification_category).maybeSingle()
    ]);
    if (!le.data) return new Response(JSON.stringify({
      error: "Invalid id_legal_entity: not found"
    }), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders()
      },
      status: 400
    });
    if (!loc.data) return new Response(JSON.stringify({
      error: "Invalid id_location: not found"
    }), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders()
      },
      status: 400
    });
    if (!cat.data) return new Response(JSON.stringify({
      error: "Invalid id_certification_category: not found"
    }), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders()
      },
      status: 400
    });
    // Certifier autocreate
    const { data: certifierRow } = await admin.from("certifier").select("id_certifier").eq("id_certifier", id_certifier).maybeSingle();
    if (!certifierRow) {
      const { error: cErr } = await admin.from("certifier").insert({
        id_certifier,
        id_certifier_hash: crypto.randomUUID(),
        id_legal_entity
      }).single();
      if (cErr) {
        return new Response(JSON.stringify({
          error: `Failed to create certifier: ${cErr.message}`
        }), {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders()
          },
          status: 400
        });
      }
    }
    const draft_at = form.get("draft_at") ? new Date(String(form.get("draft_at"))).toISOString() : nowIso();
    const sent_at = form.get("sent_at") ? new Date(String(form.get("sent_at"))).toISOString() : nowIso();
    const closed_at = form.get("closed_at") ? new Date(String(form.get("closed_at"))).toISOString() : null;
    const { data: certRow, error: certErr } = await admin.from("certification").insert({
      id_certification_hash: crypto.randomUUID(),
      id_certifier,
      id_legal_entity,
      id_location,
      n_users,
      id_certification_category,
      status: "sent",
      sent_at,
      draft_at,
      closed_at
    }).select("*").single();
    if (certErr) {
      return new Response(JSON.stringify({
        error: certErr.message
      }), {
        headers: {
          "Content-Type": "application/json",
          ...corsHeaders()
        },
        status: 400
      });
    }
    // Users from fields
    const usersToUpsert: any[] = [];
    const f_id_user = form.get("id_user");
    const f_id_otp = form.get("id_otp");
    if (f_id_user && f_id_otp) {
      usersToUpsert.push({
        id_certification: certRow.id_certification,
        id_user: String(f_id_user),
        id_otp: String(f_id_otp),
        status: "pending",
        rejection_reason: form.get("rejection_reason") ? String(form.get("rejection_reason")) : null
      });
    }
    const users_json = form.get("users_json");
    if (users_json) {
      try {
        const parsed = JSON.parse(String(users_json));
        if (Array.isArray(parsed)) {
          for (const u of parsed) {
            const pick = pickUserOtp(u);
            if (pick) usersToUpsert.push({
              id_certification: certRow.id_certification,
              id_user: pick.id_user,
              id_otp: pick.id_otp,
              status: "pending",
              rejection_reason: pick.rejection_reason ?? null
            });
          }
        }
      } catch { }
    }
    let usersRows: any[] = [];
    let informationValues: any[] = [];
    if (usersToUpsert.length) {
      const seen = new Set();
      const dedup = usersToUpsert.filter((u) => {
        const k = `${u.id_user}::${u.id_otp}`;
        if (seen.has(k)) return false;
        seen.add(k);
        return true;
      });
      const uniqUsers = [
        ...new Set(dedup.map((u) => u.id_user))
      ];
      const uniqOtps = [
        ...new Set(dedup.map((u) => u.id_otp))
      ];
      const [{ data: userOk, error: uErr }, { data: otpOk, error: oErr }] = await Promise.all([
        admin.from("user").select("idUser").in("idUser", uniqUsers),
        admin.from("otp").select("id_otp").in("id_otp", uniqOtps)
      ]);
      if (uErr || oErr) {
        return new Response(JSON.stringify({
          error: `FK check failed: ${uErr?.message || oErr?.message}`
        }), {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders()
          },
          status: 400
        });
      }
      const okUsers = new Set((userOk ?? []).map((r) => r.idUser));
      const okOtps = new Set((otpOk ?? []).map((r) => r.id_otp));
      const invalid = dedup.find((u) => !okUsers.has(u.id_user) || !okOtps.has(u.id_otp));
      if (invalid) {
        return new Response(JSON.stringify({
          error: "Invalid id_user or id_otp in users"
        }), {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders()
          },
          status: 400
        });
      }
      // Claim OTPs
      try {
        const otpPairs = dedup.map((u) => ({
          id_otp: u.id_otp,
          id_user: u.id_user
        }));
        await claimOtpsOr409(admin, otpPairs, String(certRow.id_legal_entity));
      } catch (e) {
        const status = e?._http409 ? 409 : 400;
        return new Response(JSON.stringify({
          error: e.message || String(e)
        }), {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders()
          },
          status
        });
      }
      // 1) leggi coppie già presenti
      const { data: existingCu, error: selErr } = await admin.from("certification_user").select("id_user,id_otp,id_certification_user").eq("id_certification", certRow.id_certification).in("id_user", uniqUsers).in("id_otp", uniqOtps);
      if (selErr) {
        return new Response(JSON.stringify({
          error: `Failed to check existing certification_user: ${selErr.message}`
        }), {
          headers: {
            "Content-Type": "application/json",
            ...corsHeaders()
          },
          status: 400
        });
      }
      const existingPairs = new Set((existingCu ?? []).map((r) => `${r.id_user}::${r.id_otp}`));
      // 2) inserisci solo nuove
      const toInsert = dedup.filter((u) => !existingPairs.has(`${u.id_user}::${u.id_otp}`)).map((u) => ({
        id_certification: certRow.id_certification,
        id_user: u.id_user,
        id_otp: u.id_otp,
        status: "pending",
        rejection_reason: u.rejection_reason ?? null
      }));
      let cuDataAll = [];
      if (toInsert.length) {
        const { data: insCu, error: insErr } = await admin.from("certification_user").insert(toInsert).select("*");
        if (insErr) {
          return new Response(JSON.stringify({
            error: `Failed to insert certification_user: ${insErr.message}`
          }), {
            headers: {
              "Content-Type": "application/json",
              ...corsHeaders()
            },
            status: 400
          });
        }
        cuDataAll = insCu ?? [];
      }
      usersRows = [
        ...(existingCu ?? []).map((r) => ({
          id_certification: certRow.id_certification,
          id_user: r.id_user,
          id_otp: r.id_otp,
          id_certification_user: r.id_certification_user,
          status: "pending",
          rejection_reason: null
        })),
        ...cuDataAll
      ];

      // Gestione esito e titolo per multipart: recupera le informazioni di certificazione
      console.log(`[${reqId}] Looking for certification information for legal_entity: ${id_legal_entity}`);
      console.log(`[${reqId}] Users rows count: ${usersRows.length}`);
      console.log(`[${reqId}] Esito value from form:`, form.get("esito_value"));
      console.log(`[${reqId}] Titolo value from form:`, form.get("titolo_value"));
      console.log(`[${reqId}] Titolo value type:`, typeof form.get("titolo_value"));
      console.log(`[${reqId}] Titolo value length:`, form.get("titolo_value")?.length);
      
      // Recupera sia esito che titolo
      const [{ data: esitoInfo, error: esitoErr }, { data: titoloInfo, error: titoloErr }] = await Promise.all([
        admin
          .from("certification_information")
          .select("id_certification_information, name, label, type, scope")
          .or(`id_legal_entity.eq.${id_legal_entity},id_legal_entity.is.null`)
          .eq("name", "esito")
          .maybeSingle(),
        admin
          .from("certification_information")
          .select("id_certification_information, name, label, type, scope")
          .or(`id_legal_entity.eq.${id_legal_entity},id_legal_entity.is.null`)
          .eq("name", "titolo")
          .maybeSingle()
      ]);

      console.log(`[${reqId}] Esito info query result:`, { esitoInfo, esitoErr });
      console.log(`[${reqId}] Titolo info query result:`, { titoloInfo, titoloErr });

      // Crea array per tutti i valori da inserire
      const allValuesToInsert = [];

      // Gestione esito (per ogni utente)
      if (esitoErr) {
        console.warn(`[${reqId}] Error fetching esito information:`, esitoErr.message);
      } else if (esitoInfo) {
        console.log(`[${reqId}] Found esito information:`, esitoInfo);
        console.log(`[${reqId}] Esito value from form:`, form.get("esito_value"));
        // Crea i valori di esito per ogni utente
        const esitoValues = usersRows.map((user) => {
          const esitoValue = {
            id_certification_information: esitoInfo.id_certification_information,
            id_certification: certRow.id_certification,
            id_certification_user: user.id_certification_user || null,
            value: form.get("esito_value") !== null && form.get("esito_value") !== undefined ? String(form.get("esito_value")) : "0"
          };
          console.log(`[${reqId}] Mapped esito value for user ${user.id_user}:`, esitoValue);
          return esitoValue;
        });
        allValuesToInsert.push(...esitoValues);
      }

      // Gestione titolo (una sola volta, senza id_certification_user)
      if (titoloErr) {
        console.warn(`[${reqId}] Error fetching titolo information:`, titoloErr.message);
      } else if (titoloInfo) {
        console.log(`[${reqId}] Found titolo information:`, titoloInfo);
        console.log(`[${reqId}] Titolo value from form:`, form.get("titolo_value"));
        const titoloValue = {
          id_certification_information: titoloInfo.id_certification_information,
          id_certification: certRow.id_certification,
          id_certification_user: null, // Titolo non ha id_certification_user
          value: form.get("titolo_value") !== null && form.get("titolo_value") !== undefined ? String(form.get("titolo_value")) : ""
        };
        console.log(`[${reqId}] Mapped titolo value:`, titoloValue);
        allValuesToInsert.push(titoloValue);
      }

      if (allValuesToInsert.length > 0) {
        console.log(`[${reqId}] Prepared all values to insert:`, allValuesToInsert);

        // Inserisci tutti i valori uno alla volta
        console.log(`[${reqId}] Attempting to insert ${allValuesToInsert.length} values one by one...`);
        
        const insertedValues = [];
        
        for (let i = 0; i < allValuesToInsert.length; i++) {
          const val = allValuesToInsert[i];
          // Prova insert con valori espliciti nell'ordine corretto
          const singleInsertData = {
            value: val.value,
            id_certification_information: val.id_certification_information,
            id_certification: val.id_certification,
            id_certification_user: val.id_certification_user
          };
          
          console.log(`[${reqId}] ===== INSERTING VALUE ${i + 1}/${allValuesToInsert.length} =====`);
          console.log(`[${reqId}] Single insert data:`, singleInsertData);
          console.log(`[${reqId}] Value field specifically:`, val.value);
          console.log(`[${reqId}] About to insert into certification_information_value...`);
          
          // Prova insert con specifica esplicita dei campi nell'ordine corretto
          console.log(`[${reqId}] Inserting with explicit field order...`);
          
          const { data: singleInserted, error: singleError } = await admin
            .from("certification_information_value")
            .insert({
              id_certification_information: val.id_certification_information,
              id_certification: val.id_certification,
              id_certification_user: val.id_certification_user,
              value: val.value
            })
            .select("id_certification_information_value, id_certification_information, id_certification, id_certification_user, value, created_at, updated_at")
            .single();

          if (singleError) {
            console.error(`[${reqId}] Error inserting single value ${i + 1}:`, singleError);
            console.error(`[${reqId}] Error details:`, JSON.stringify(singleError, null, 2));
          } else {
            console.log(`[${reqId}] Successfully inserted single value ${i + 1}:`, singleInserted);
            console.log(`[${reqId}] Inserted value field:`, singleInserted?.value);
            console.log(`[${reqId}] Inserted ID field:`, singleInserted?.id_certification_information_value);
            insertedValues.push(singleInserted);
          }
        }
        
        informationValues = insertedValues;
        console.log(`[${reqId}] All values inserted. Total: ${insertedValues.length}`);
      } else {
        console.log(`[${reqId}] No certification information found for legal_entity: ${id_legal_entity}`);
        console.log(`[${reqId}] Skipping values creation - no certification_information found`);
      }

      // Gestione media titles dal media_metadata (multipart)
      const mediaMetadataStr = form.get("media_metadata");
      if (mediaMetadataStr) {
        try {
          const mediaMetadataArray = JSON.parse(String(mediaMetadataStr));
          if (Array.isArray(mediaMetadataArray)) {
            console.log(`[${reqId}] Processing media metadata for titles (multipart):`, mediaMetadataArray);
            
            // Cerca o crea una certification_information per i titoli dei media
            const { data: mediaTitleInfo, error: mediaTitleErr } = await admin
              .from("certification_information")
              .select("id_certification_information, name, label, type, scope")
              .or(`id_legal_entity.eq.${id_legal_entity},id_legal_entity.is.null`)
              .eq("name", "media_title")
              .maybeSingle();

            if (mediaTitleErr) {
              console.warn(`[${reqId}] Error fetching media_title information (multipart):`, mediaTitleErr.message);
            } else if (mediaTitleInfo) {
              console.log(`[${reqId}] Found media_title information (multipart):`, mediaTitleInfo);
              
              // Crea i valori per ogni titolo media
              const mediaTitleValues = mediaMetadataArray.map((metadata, index) => {
                const titleValue = {
                  id_certification_information: mediaTitleInfo.id_certification_information,
                  id_certification: certRow.id_certification,
                  id_certification_user: null, // Media title non ha id_certification_user
                  value: metadata.title || ""
                };
                console.log(`[${reqId}] Mapped media title value ${index} (multipart):`, titleValue);
                return titleValue;
              });

              // Inserisci i valori dei titoli media
              for (let i = 0; i < mediaTitleValues.length; i++) {
                const val = mediaTitleValues[i];
                console.log(`[${reqId}] Inserting media title value ${i + 1} (multipart):`, val);
                
                const { data: insertedTitle, error: titleError } = await admin
                  .from("certification_information_value")
                  .insert({
                    id_certification_information: val.id_certification_information,
                    id_certification: val.id_certification,
                    id_certification_user: val.id_certification_user,
                    value: val.value
                  })
                  .select("id_certification_information_value, id_certification_information, id_certification, id_certification_user, value, created_at, updated_at")
                  .single();

                if (titleError) {
                  console.error(`[${reqId}] Error inserting media title value ${i + 1} (multipart):`, titleError);
                } else {
                  console.log(`[${reqId}] Successfully inserted media title value ${i + 1} (multipart):`, insertedTitle);
                  informationValues.push(insertedTitle);
                }
              }
            } else {
              console.log(`[${reqId}] No media_title certification_information found, skipping media title values (multipart)`);
            }
          }
        } catch (e) {
          console.warn(`[${reqId}] Failed to parse media metadata (multipart):`, e);
        }
      } else {
        console.log(`[${reqId}] No media metadata provided, skipping media title processing (multipart)`);
      }
    }
    // Files upload
    const files = form.getAll("files").filter(Boolean);
    const single = form.get("file");
    if (!files.length && single) files.push(single);
    const acquisition_type = String(form.get("acquisition_type") || "deferred");
    const file_type_override = form.get("file_type") ? String(form.get("file_type")) : undefined;
    const captured_at_str = String(form.get("captured_at") || "");
    const id_location_media = form.get("id_location_media") ? String(form.get("id_location_media")) : null;
    const description = form.get("description") ? String(form.get("description")) : null;
    const title = form.get("title") ? String(form.get("title")) : null;
    const wantSigned = qbool(String(form.get("return_signed_url") || ""));
    let mediaRows: any[] = [];
    if (files.length) {
      const bucket = admin.storage.from("media");
      const nowStr = nowIso();
      mediaRows = await Promise.all(files.map(async (file, index) => {
        const bytes = new Uint8Array(await file.arrayBuffer());
        const hash = await sha256Hex(bytes);
        const safeName = file.name?.replace(/[^\w.\- ]+/g, "_") || "file";
        const key = `${certRow.id_certification}/${hash}-${safeName}`;
        const { error: upErr } = await bucket.upload(key, bytes, {
          contentType: file.type || "application/octet-stream",
          upsert: false
        });
        if (upErr && !String(upErr.message || "").includes("The resource already exists")) throw upErr;
        const file_type = file_type_override || inferFileType(file.type);
        const captured_at = captured_at_str ? new Date(captured_at_str).toISOString() : nowStr;
        
        // Get media metadata for this specific file
        const mediaMetadataStr = form.get("media_metadata");
        let fileDescription = description;
        
        if (mediaMetadataStr) {
          try {
            const metadataArray = JSON.parse(String(mediaMetadataStr));
            if (Array.isArray(metadataArray) && metadataArray[index]) {
              const metadata = metadataArray[index];
              fileDescription = metadata.description || description;
            }
          } catch (e) {
            console.warn(`[${reqId}] Failed to parse media metadata:`, e);
          }
        }
        
        const { data: mRow, error: insErr } = await admin.from("certification_media").insert({
          id_media_hash: hash,
          id_certification: certRow.id_certification,
          name: key,
          description: fileDescription,
          acquisition_type,
          captured_at,
          id_location: id_location_media,
          file_type
        }).select("*").single();
        if (insErr) throw insErr;
        
        // Determine if this is context media or user media based on per-file metadata
        const isUserMedia = form.get(`is_user_media_${index}`) ? qbool(String(form.get(`is_user_media_${index}`))) : false;
        const userId = form.get(`user_id_${index}`) ? String(form.get(`user_id_${index}`)) : null;
        
        console.log(`[${reqId}] File ${index}: isUserMedia=${isUserMedia}, userId=${userId}`);
        
        if (isUserMedia && userId) {
          // Find the certification_user record for this user
          const { data: certUser } = await admin.from("certification_user")
            .select("id_certification_user")
            .eq("id_certification", certRow.id_certification)
            .eq("id_user", userId)
            .maybeSingle();
            
          console.log(`[${reqId}] Found certification_user for user ${userId}:`, certUser);
            
          if (certUser) {
            // Insert into certification_has_media with both id_certification and id_certification_user
            await admin.from("certification_has_media").insert({
              id_certification: certRow.id_certification,
              id_certification_user: certUser.id_certification_user,
              id_certification_media: mRow.id_certification_media
            });
            console.log(`[${reqId}] Linked user media to certification_user ${certUser.id_certification_user}`);
          } else {
            // Fallback: insert only with id_certification
            console.warn(`[${reqId}] No certification_user found for user ${userId}, linking as context media`);
            await admin.from("certification_has_media").insert({
              id_certification: certRow.id_certification,
              id_certification_media: mRow.id_certification_media
            });
          }
        } else {
          // Context media: insert only with id_certification
          console.log(`[${reqId}] Linking as context media`);
          await admin.from("certification_has_media").insert({
            id_certification: certRow.id_certification,
            id_certification_media: mRow.id_certification_media
          });
        }
        
        let signed_url = null;
        if (wantSigned) {
          const { data: s } = await bucket.createSignedUrl(key, 60 * 60);
          signed_url = s?.signedUrl ?? null;
        }
        return {
          ...mRow,
          signed_url
        };
      }));
    }
    return new Response(JSON.stringify({
      data: {
        ...certRow,
        users: usersRows,
        media: mediaRows,
        information_values: informationValues
      }
    }), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders()
      },
      status: 201
    });
  } catch (err) {
    console.error(`[${reqId}] Uncaught`, err?.message || err, {
      stack: err?.stack
    });
    const status = err?._http409 ? 409 : 500;
    return new Response(JSON.stringify({
      error: err?.message ?? "Unexpected error"
    }), {
      headers: {
        "Content-Type": "application/json",
        ...corsHeaders()
      },
      status
    });
  } finally {
    console.log(`[${reqId}] ===== Completed in ${Date.now() - t0}ms =====`);
  }
});
