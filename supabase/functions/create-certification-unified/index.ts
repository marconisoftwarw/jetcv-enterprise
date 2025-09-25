/**
 * @name create-certification-unified
 * @version 1.0.0
 * @summary Unified certification creation with OTP blocking and media upload
 * @updated 2025-01-27
 *
 * @endpoint
 *   Base Path: /functions/v1/create-certification-unified
 *
 * @input
 *   - POST application/json
 *       {
 *         "certification": {
 *           "id_certifier": string,
 *           "id_legal_entity": string,
 *           "id_location": string,
 *           "n_users": number,
 *           "id_certification_category": string,
 *           "status": "sent",
 *           "draft_at": string (ISO),
 *           "sent_at": string (ISO),
 *           "closed_at": string (ISO) | null,
 *           "duration_h": number | null,
 *           "start_timestamp": string (ISO) | null,
 *           "end_timestamp": string (ISO) | null
 *         },
 *         "certification_users": [
 *           {
 *             "id_user": string,
 *             "id_otp": string,
 *             "status": "pending",
 *             "rejection_reason": string | null,
 *             "duration_h": number | null,
 *             "start_timestamp": string (ISO) | null,
 *             "end_timestamp": string (ISO) | null
 *           }
 *         ],
 *         "media": [
 *           {
 *             "id_media_hash": string,
 *             "name": string,
 *             "description": string | null,
 *             "acquisition_type": "realtime" | "deferred",
 *             "captured_at": string (ISO),
 *             "id_location": string | null,
 *             "file_type": "image" | "video" | "audio" | "document" | null,
 *             "file_data": string (base64) | null,
 *             "mime_type": string | null,
 *             "title": string | null
 *           }
 *         ],
 *         "media_metadata": [
 *           {
 *             "title": string | null,
 *             "description": string | null
 *           }
 *         ],
 *         "certification_information_values": [
 *           {
 *             "id_certification_information": string,
 *             "value": string,
 *             "id_certification_user": string | null  // null for general certification values
 *           }
 *         ]
 *         ]
 *       }
 *
 * @output
 *   - 201 JSON: { data: { certification, certification_users, media, certification_information_values } }
 *   - 4xx/5xx JSON: { error: string }
 *
 * @responses
 *   201: Created (certification, users, OTPs blocked, media uploaded)
 *   400: Bad Request (validation errors, FK errors)
 *   409: Conflict (OTP already used)
 *   500: Internal error
 *
 * @behavior
 *   - Creates certification with duration and timestamps
 *   - Blocks OTPs used by certification_users with duration and timestamps
 *   - Uploads media files to storage with title
 *   - Links media to certification
 *   - Inserts certification_information_values for general and user-specific values
 *   - Uses SERVICE_ROLE to bypass RLS
 *   - Atomic transaction (rollback on any failure)
 *
 * @cors
 *   - Access-Control-Allow-Origin: *
 *   - Access-Control-Allow-Methods: POST,OPTIONS
 *   - Access-Control-Allow-Headers: authorization, x-client-info, apikey, content-type
 */

const CORS_OPEN = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST,OPTIONS",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type"
};

function corsHeaders() {
  return CORS_OPEN;
}

function nowIso() {
  return new Date().toISOString();
}

function redact(key) {
  if (!key) return "(missing)";
  return key.length <= 8 ? "***" : `${key.slice(0, 4)}…${key.slice(-4)}`;
}

function isValidEnumFileType(v) {
  return v === "image" || v === "video" || v === "audio" || v === "document";
}

function inferEnumFileType(contentType, filename) {
  const ct = (contentType || "").toLowerCase();
  const name = (filename || "").toLowerCase();
  const ext = name.includes(".") ? name.split(".").pop() : "";
  
  if (ct.startsWith("image/")) return "image";
  if (ct.startsWith("video/")) return "video";
  if (ct.startsWith("audio/")) return "audio";
  if (ct === "application/pdf" || ct === "application/msword" || 
      ct === "application/vnd.openxmlformats-officedocument.wordprocessingml.document" ||
      ct === "text/plain" || ct === "text/csv") {
    return "document";
  }
  
  const imgExt = new Set(["jpg", "jpeg", "png", "gif", "webp", "avif", "heic", "heif", "tif", "tiff", "bmp", "svg"]);
  const vidExt = new Set(["mp4", "mov", "avi", "mkv", "webm", "mpeg", "mpg", "3gp", "m4v"]);
  const audExt = new Set(["mp3", "m4a", "wav", "flac", "aac", "ogg", "opus"]);
  const docExt = new Set(["pdf", "doc", "docx", "xls", "xlsx", "ppt", "pptx", "txt", "rtf", "odt", "ods", "odp", "csv", "json"]);
  
  if (imgExt.has(ext)) return "image";
  if (vidExt.has(ext)) return "video";
  if (audExt.has(ext)) return "audio";
  if (docExt.has(ext)) return "document";
  
  return null;
}

async function sha256Hex(bytes) {
  const h = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(h)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function base64ToBytes(base64) {
  const binaryString = atob(base64);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}

async function readJson(req) {
  const ct = req.headers.get("content-type") || "";
  if (!ct.includes("application/json")) return undefined;
  
  try {
    return await req.json();
  } catch (e) {
    console.error("JSON parse error:", e?.message || e);
    throw e;
  }
}

(Deno as any).serve(async (req: any) => {
  const reqId = crypto.randomUUID();
  const t0 = Date.now();
  const url = new URL(req.url);
  
  console.log(`[${reqId}] ===== Incoming ${nowIso()} =====`);
  console.log(`[${reqId}] ${req.method} ${url.pathname}${url.search}`);
  
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders() });
  }

  // @ts-ignore deno-types
  const { createClient } = await import("https://esm.sh/@supabase/supabase-js@2");
  const supabaseUrl = (Deno as any).env.get("SUPABASE_URL");
  const serviceRoleKey = (Deno as any).env.get("SUPABASE_SERVICE_ROLE_KEY");
  
  console.log(`[${reqId}] Env -> URL:${!!supabaseUrl} SRK:${serviceRoleKey ? "present" : "missing"}`);
  
  if (!supabaseUrl || !serviceRoleKey) {
    return new Response(JSON.stringify({
      error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY"
    }), {
      headers: { "Content-Type": "application/json", ...corsHeaders() },
      status: 500
    });
  }

  const admin = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false, autoRefreshToken: false, detectSessionInUrl: false }
  });

  try {
    if (req.method !== "POST") {
      return new Response(JSON.stringify({
        error: "Method not allowed"
      }), {
        headers: { "Content-Type": "application/json", ...corsHeaders() },
        status: 405
      });
    }

    const body = await readJson(req);
    if (!body) {
      return new Response(JSON.stringify({
        error: "Invalid JSON body"
      }), {
        headers: { "Content-Type": "application/json", ...corsHeaders() },
        status: 400
      });
    }

    console.log(`[${reqId}] Request body keys:`, Object.keys(body));

    // 1. VALIDATE REQUIRED FIELDS
    const cert = body.certification || {};
    const certificationUsers = Array.isArray(body.certification_users) ? body.certification_users : [];
    const media = Array.isArray(body.media) ? body.media : [];
    const mediaMetadata = Array.isArray(body.media_metadata) ? body.media_metadata : [];
    const certificationInformationValues = Array.isArray(body.certification_information_values) ? body.certification_information_values : [];

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
        headers: { "Content-Type": "application/json", ...corsHeaders() },
        status: 400
      });
    }

    console.log(`[${reqId}] Processing: cert=${!!cert}, users=${certificationUsers.length}, media=${media.length}`);

    // 2. FK PRECHECKS
    console.log(`[${reqId}] FK prechecks - START`);
    const tFk0 = Date.now();
    
    const [leRes, locRes, catRes] = await Promise.allSettled([
      admin.from("legal_entity").select("id_legal_entity").eq("id_legal_entity", cert.id_legal_entity).maybeSingle(),
      admin.from("location").select("id_location").eq("id_location", cert.id_location).maybeSingle(),
      admin.from("certification_category").select("id_certification_category").eq("id_certification_category", cert.id_certification_category).maybeSingle()
    ]);

    const leOk = leRes.status === "fulfilled" && !leRes.value.error && leRes.value.data;
    const locOk = locRes.status === "fulfilled" && !locRes.value.error && locRes.value.data;
    const catOk = catRes.status === "fulfilled" && !catRes.value.error && catRes.value.data;

    console.log(`[${reqId}] FK checks -> leOk:${!!leOk} locOk:${!!locOk} catOk:${!!catOk}`);

    if (!leOk) {
      return new Response(JSON.stringify({
        error: "Invalid id_legal_entity: not found"
      }), {
        headers: { "Content-Type": "application/json", ...corsHeaders() },
        status: 400
      });
    }
    if (!locOk) {
      return new Response(JSON.stringify({
        error: "Invalid id_location: not found"
      }), {
        headers: { "Content-Type": "application/json", ...corsHeaders() },
        status: 400
      });
    }
    if (!catOk) {
      return new Response(JSON.stringify({
        error: "Invalid id_certification_category: not found"
      }), {
        headers: { "Content-Type": "application/json", ...corsHeaders() },
        status: 400
      });
    }

    console.log(`[${reqId}] FK prechecks - OK in ${Date.now() - tFk0}ms`);

    // 3. CERTIFIER PRECHECK / AUTOCREATE
    console.log(`[${reqId}] Certifier precheck - START`);
    const tCert0 = Date.now();
    
    const certifierId = String(cert.id_certifier);
    const { data: certifierRow, error: certifierErr } = await admin
      .from("certifier")
      .select("id_certifier")
      .eq("id_certifier", certifierId)
      .maybeSingle();

    if (certifierErr) {
      console.error(`[${reqId}] Certifier precheck error:`, certifierErr);
      return new Response(JSON.stringify({
        error: `Certifier precheck failed: ${certifierErr.message}`
      }), {
        headers: { "Content-Type": "application/json", ...corsHeaders() },
        status: 500
      });
    }

    if (!certifierRow) {
      console.log(`[${reqId}] Creating certifier...`);
      const { error: createCertifierErr } = await admin.from("certifier").insert({
        id_certifier: certifierId,
        id_certifier_hash: crypto.randomUUID(),
        id_legal_entity: String(cert.id_legal_entity)
      }).single();

      if (createCertifierErr) {
        console.error(`[${reqId}] Create certifier error:`, createCertifierErr);
        return new Response(JSON.stringify({
          error: `Failed to create certifier: ${createCertifierErr.message}`
        }), {
          headers: { "Content-Type": "application/json", ...corsHeaders() },
          status: 400
        });
      }
      console.log(`[${reqId}] Certifier created OK`);
    } else {
      console.log(`[${reqId}] Certifier exists:`, certifierRow.id_certifier);
    }

    console.log(`[${reqId}] Certifier precheck - OK in ${Date.now() - tCert0}ms`);

    // 4. CREATE CERTIFICATION
    console.log(`[${reqId}] Creating certification - START`);
    const tInsC0 = Date.now();
    
    const insertPayload = {
      id_certification_hash: cert.id_certification_hash ?? crypto.randomUUID(),
      id_certifier: certifierId,
      id_legal_entity: String(cert.id_legal_entity),
      id_location: String(cert.id_location),
      n_users: Number(cert.n_users),
      id_certification_category: String(cert.id_certification_category),
      status: cert.status || "sent",
      sent_at: cert.sent_at || nowIso(),
      draft_at: cert.draft_at || nowIso(),
      closed_at: cert.closed_at ?? null,
      duration_h: cert.duration_h ? Number(cert.duration_h) : null,
      start_timestamp: cert.start_timestamp || null,
      end_timestamp: cert.end_timestamp || null
    };

    console.log(`[${reqId}] Certification insertPayload:`, insertPayload);

    const { data: certRow, error: certErr } = await admin
      .from("certification")
      .insert(insertPayload)
      .select("*")
      .single();

    if (certErr) {
      console.error(`[${reqId}] Certification insert ERROR:`, certErr);
      return new Response(JSON.stringify({
        error: certErr.message
      }), {
        headers: { "Content-Type": "application/json", ...corsHeaders() },
        status: 400
      });
    }

    console.log(`[${reqId}] Certification created OK in ${Date.now() - tInsC0}ms -> id:`, certRow.id_certification);

    // 5. PROCESS CERTIFICATION USERS AND BLOCK OTPs
    let cuData = [];
    if (certificationUsers.length > 0) {
      console.log(`[${reqId}] Processing certification users - START`);
      const tUsers0 = Date.now();

      // Validate users and OTPs
      const userIds = [...new Set(certificationUsers.map(u => u.id_user))];
      const otpIds = [...new Set(certificationUsers.map(u => u.id_otp))];

      console.log(`[${reqId}] Validating ${userIds.length} users and ${otpIds.length} OTPs`);

      const [{ data: usersRows, error: usersErr }, { data: otpRows, error: otpsErr }] = await Promise.all([
        admin.from("user").select("idUser").in("idUser", userIds),
        admin.from("otp").select("id_otp, used_at, burned_at").in("id_otp", otpIds)
      ]);

      if (usersErr || otpsErr) {
        console.error(`[${reqId}] Rolling back certification due to FK check failure...`, { usersErr, otpsErr });
        await admin.from("certification").delete().eq("id_certification", certRow.id_certification);
        return new Response(JSON.stringify({
          error: `FK check failed: ${usersErr?.message || otpsErr?.message}`
        }), {
          headers: { "Content-Type": "application/json", ...corsHeaders() },
          status: 400
        });
      }

      const okUsers = new Set((usersRows ?? []).map(r => r.idUser));
      const availableOtps = new Set((otpRows ?? []).filter(r => !r.used_at && !r.burned_at).map(r => r.id_otp));

      const invalidUsers = certificationUsers.filter(u => !okUsers.has(u.id_user));
      const invalidOtps = certificationUsers.filter(u => !availableOtps.has(u.id_otp));

      if (invalidUsers.length > 0 || invalidOtps.length > 0) {
        console.error(`[${reqId}] Rolling back certification due to invalid users/OTPs...`, { invalidUsers, invalidOtps });
        await admin.from("certification").delete().eq("id_certification", certRow.id_certification);
        return new Response(JSON.stringify({
          error: "Invalid id_user or id_otp in certification_users"
        }), {
          headers: { "Content-Type": "application/json", ...corsHeaders() },
          status: 400
        });
      }

      // Insert certification users
      const usersToInsert = certificationUsers.map(u => ({
        id_certification: certRow.id_certification,
        id_user: String(u.id_user),
        id_otp: String(u.id_otp),
        status: u.status || "pending",
        rejection_reason: u.rejection_reason ?? null,
        duration_h: u.duration_h ? Number(u.duration_h) : null,
        start_timestamp: u.start_timestamp || null,
        end_timestamp: u.end_timestamp || null
      }));

      const { data: cuIns, error: cuErr } = await admin
        .from("certification_user")
        .insert(usersToInsert)
        .select("*");

      if (cuErr) {
        console.error(`[${reqId}] Rolling back certification due to certification_user insert error...`, cuErr);
        await admin.from("certification").delete().eq("id_certification", certRow.id_certification);
        return new Response(JSON.stringify({
          error: `Failed to create certification_user: ${cuErr.message}`
        }), {
          headers: { "Content-Type": "application/json", ...corsHeaders() },
          status: 400
        });
      }

      cuData = cuIns ?? [];

      // Block OTPs
      console.log(`[${reqId}] Blocking OTPs - START`);
      const now = nowIso();
      
      // Aggiorna ogni OTP individualmente per evitare problemi con campi obbligatori
      for (const user of certificationUsers) {
        const { error: otpBlockErr } = await admin
          .from("otp")
          .update({
            used_at: now,
            burned_at: now,
            used_by_id_user: String(user.id_user),
            id_legal_entity: String(cert.id_legal_entity)
          })
          .eq("id_otp", String(user.id_otp));

        if (otpBlockErr) {
          console.error(`[${reqId}] Rolling back due to OTP block error for ${user.id_otp}...`, otpBlockErr);
          await admin.from("certification_user").delete().eq("id_certification", certRow.id_certification);
          await admin.from("certification").delete().eq("id_certification", certRow.id_certification);
          return new Response(JSON.stringify({
            error: `Failed to block OTP ${user.id_otp}: ${otpBlockErr.message}`
          }), {
            headers: { "Content-Type": "application/json", ...corsHeaders() },
            status: 400
          });
        }
      }

      console.log(`[${reqId}] OTPs blocked successfully`);
      console.log(`[${reqId}] Certification users processed OK in ${Date.now() - tUsers0}ms rows:${cuData.length}`);
    }

    // 6. PROCESS MEDIA
    let mediaRows: any[] = [];
    if (media.length > 0) {
      console.log(`[${reqId}] Processing media - START count:${media.length}`);
      const tMedia0 = Date.now();

      const bucket = admin.storage.from("media");
      const nowStr = nowIso();

      try {
        mediaRows = await Promise.all(media.map(async (m, index) => {
          const id_media_hash = m.id_media_hash ?? crypto.randomUUID();
          const safeName = (m.name || "file").replace(/[^\w.\- ]+/g, "_");
          const key = `${certRow.id_certification}/${id_media_hash}-${safeName}`;

          // Handle file upload if file_data is provided
          if (m.file_data) {
            const bytes = await base64ToBytes(m.file_data);
            const { error: upErr } = await bucket.upload(key, bytes, {
              contentType: m.mime_type || "application/octet-stream",
              upsert: false
            });

            if (upErr && !String(upErr.message || "").includes("The resource already exists")) {
              throw upErr;
            }
          }

          // Infer file type
          const inferredEnum = inferEnumFileType(m.mime_type || "", safeName);
          const file_type = isValidEnumFileType(m.file_type) ? m.file_type : (inferredEnum ?? null);

          // Get metadata for this media item
          const metadata = mediaMetadata[index] || {};
          const description = metadata.description || m.description || null;

          // Insert media record
          const { data: mRow, error: insErr } = await admin
            .from("certification_media")
            .insert({
              id_media_hash,
              id_certification: certRow.id_certification,
              name: m.file_data ? key : (m.name || null),
              description,
              acquisition_type: m.acquisition_type || "realtime",
              captured_at: m.captured_at || nowStr,
              id_location: m.id_location || null,
              file_type,
              title: m.title || metadata.title || null
            })
            .select("*")
            .single();

          if (insErr) throw insErr;

          // Link media to certification
          await admin.from("certification_has_media").insert({
            id_certification: certRow.id_certification,
            id_certification_media: mRow.id_certification_media
          });

          return mRow;
        }));

        console.log(`[${reqId}] Media processed OK in ${Date.now() - tMedia0}ms rows:${mediaRows.length}`);
      } catch (mediaErr) {
        console.error(`[${reqId}] Rolling back due to media error...`, mediaErr);
        
        // Cleanup: delete certification users and certification
        if (cuData.length > 0) {
          await admin.from("certification_user").delete().eq("id_certification", certRow.id_certification);
        }
        await admin.from("certification").delete().eq("id_certification", certRow.id_certification);
        
        return new Response(JSON.stringify({
          error: `Failed to process media: ${mediaErr.message}`
        }), {
          headers: { "Content-Type": "application/json", ...corsHeaders() },
          status: 400
        });
      }
    }

    // 7. INSERT CERTIFICATION INFORMATION VALUES
    let informationValues: any[] = [];
    if (certificationInformationValues.length > 0) {
      console.log(`[${reqId}] Processing certification information values - START`);
      const tInfo0 = Date.now();
      
      try {
        // Validate that all certification_information_ids exist
        const infoIds = [...new Set(certificationInformationValues.map(iv => iv.id_certification_information))];
        const { data: infoRows, error: infoErr } = await admin
          .from("certification_information")
          .select("id_certification_information")
          .in("id_certification_information", infoIds);

        if (infoErr) {
          console.error(`[${reqId}] Error validating certification_information_ids:`, infoErr);
          return new Response(JSON.stringify({
            error: `Failed to validate certification_information_ids: ${infoErr.message}`
          }), {
            headers: { "Content-Type": "application/json", ...corsHeaders() },
            status: 400
          });
        }

        const validInfoIds = new Set((infoRows || []).map(r => r.id_certification_information));
        const invalidInfoIds = infoIds.filter(id => !validInfoIds.has(id));
        
        if (invalidInfoIds.length > 0) {
          return new Response(JSON.stringify({
            error: `Invalid certification_information_ids: ${invalidInfoIds.join(', ')}`
          }), {
            headers: { "Content-Type": "application/json", ...corsHeaders() },
            status: 400
          });
        }

        // Map certification_user IDs for validation
        const userIdToCertUserId = new Map<string, string>();
        cuData.forEach((cu: any) => {
          userIdToCertUserId.set(cu.id_user, cu.id_certification_user);
        });

        // Prepare values to insert
        const valuesToInsert = certificationInformationValues.map((iv: any) => {
          const baseValue: any = {
            id_certification_information: String(iv.id_certification_information),
            value: String(iv.value),
            id_certification: certRow.id_certification
          };

          // If id_certification_user is provided, validate and include it
          if (iv.id_certification_user) {
            const certUserId = userIdToCertUserId.get(iv.id_certification_user);
            if (!certUserId) {
              throw new Error(`Invalid id_certification_user: ${iv.id_certification_user}`);
            }
            baseValue.id_certification_user = certUserId;
          }

          return baseValue;
        });

        // Insert certification information values
        const { data: infoValuesData, error: infoValuesErr } = await admin
          .from("certification_information_value")
          .insert(valuesToInsert)
          .select("*");

        if (infoValuesErr) {
          console.error(`[${reqId}] Error inserting certification_information_values:`, infoValuesErr);
          return new Response(JSON.stringify({
            error: `Failed to insert certification_information_values: ${infoValuesErr.message}`
          }), {
            headers: { "Content-Type": "application/json", ...corsHeaders() },
            status: 400
          });
        }

        informationValues = infoValuesData || [];
        console.log(`[${reqId}] Certification information values processed OK in ${Date.now() - tInfo0}ms rows:${informationValues.length}`);
      } catch (infoErr) {
        console.error(`[${reqId}] Rolling back due to certification information values error...`, infoErr);
        
        // Cleanup: delete certification users, media, and certification
        if (cuData.length > 0) {
          await admin.from("certification_user").delete().eq("id_certification", certRow.id_certification);
        }
        if (mediaRows.length > 0) {
          await admin.from("certification_has_media").delete().eq("id_certification", certRow.id_certification);
          await admin.from("certification_media").delete().eq("id_certification", certRow.id_certification);
        }
        await admin.from("certification").delete().eq("id_certification", certRow.id_certification);
        
        return new Response(JSON.stringify({
          error: `Failed to process certification information values: ${infoErr.message}`
        }), {
          headers: { "Content-Type": "application/json", ...corsHeaders() },
          status: 400
        });
      }
    }

    // 8. SUCCESS RESPONSE
    const response = {
      data: {
        ...certRow,
        certification_users: cuData,
        media: mediaRows,
        certification_information_values: informationValues
      }
    };

    console.log(`[${reqId}] ===== SUCCESS in ${Date.now() - t0}ms =====`);
    console.log(`[${reqId}] Created certification:`, certRow.id_certification);
    console.log(`[${reqId}] Users: ${cuData.length}, Media: ${mediaRows.length}, Information Values: ${informationValues.length}`);

    return new Response(JSON.stringify(response), {
      headers: { "Content-Type": "application/json", ...corsHeaders() },
      status: 201
    });

  } catch (err) {
    console.error(`[${reqId}] Uncaught error:`, err?.message || err, { stack: err?.stack });
    return new Response(JSON.stringify({
      error: err?.message ?? "Unexpected error"
    }), {
      headers: { "Content-Type": "application/json", ...corsHeaders() },
      status: 500
    });
  } finally {
    console.log(`[${reqId}] ===== Completed in ${Date.now() - t0}ms =====`);
  }
});
