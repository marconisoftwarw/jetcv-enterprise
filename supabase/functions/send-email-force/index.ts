// * @name send-email-force
// * @version 1.0.0
// * @input JSON body: { to: string, subject: string, text?: string, html?: string, from?: string }
// * @output JSON: { ok: boolean, status: number, message: string, requestId: string }
// * @responses
// *   200: { ok: true, status: 200, message: "Email sent", requestId }
// *   204: (OPTIONS preflight)
// *   400: Invalid JSON body
// *   405: Method not allowed (only POST, OPTIONS)
// *   415: Unsupported Media Type (expect application/json)
// *   422: Validation error (missing/invalid fields)
// *   500: Server error
// *   502/503: Email service unreachable or failed
// * @updated 2025-09-25
// * @summary Invia un'email generica prendendo to/subject/text/html/from dal body.
// * @notes
// *   - Usa SOLO l'API esterna di invio email (nessun accesso DB).
// *   - Nessun dato personale in log (niente indirizzi, oggetti, contenuti).
// *   - Richiede almeno uno tra `text` o `html`.
// *   - `from` opzionale, con default sicuro configurabile via env.
// * @environment
// *   - CORS_ALLOWED_ORIGINS: CSV opzionale (es: "https://app.example.com,https://admin.example.com")
// *   - DEFAULT_FROM_EMAIL: opzionale; fallback se `from` non è passato
// *   - EMAIL_SENDER_URL: URL del servizio invio (es: "http://18.102.14.247:4000/api/email/send")
// * @cors
// *   - Gestisce preflight e imposta Access-Control-Allow-* con reflection della Origin (o "*").
// * @example cURL
// *   curl -X POST \
// *     -H "Content-Type: application/json" \
// *     -d '{
// *           "to":"riccardo@pirani.it",
// *           "subject":"JetCV Enterprise - Link di Registrazione Entità Legale",
// *           "text":"...",
// *           "html":"...",
// *           "from":"jjectcvuser@gmail.com"
// *         }' \
// *     "https://<YOUR-PROJECT-REF>.functions.supabase.co/send-email-force"

// ---------------------- Utilities ---------------------------
/** CORS headers builder with optional allowlist reflection. */
function buildCorsHeaders(req: Request) {
  const allowlistCsv = Deno.env.get("CORS_ALLOWED_ORIGINS") ?? "";
  const allowlist = new Set(
    allowlistCsv.split(",").map((s) => s.trim()).filter(Boolean),
  );
  const reqOrigin = req.headers.get("Origin") ?? "*";
  const allowOrigin =
    allowlist.size === 0 ? "*" : allowlist.has(reqOrigin) ? reqOrigin : "null";

  const headers = new Headers();
  headers.set("Access-Control-Allow-Origin", allowOrigin);
  headers.set("Vary", "Origin");
  headers.set("Access-Control-Allow-Methods", "POST, OPTIONS");
  headers.set(
    "Access-Control-Allow-Headers",
    "authorization, x-client-info, apikey, content-type",
  );
  headers.set("Access-Control-Max-Age", "86400");
  return headers;
}

/** JSON response helper (adds CORS + content-type). */
function jsonResponse(req: Request, status: number, body: unknown) {
  const headers = buildCorsHeaders(req);
  headers.set("Content-Type", "application/json; charset=utf-8");
  return new Response(JSON.stringify(body), { status, headers });
}

/** Basic email format validation. */
function isValidEmail(email: unknown) {
  if (typeof email !== "string") return false;
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email.trim());
}

/** Perform a POST with timeout using AbortController. */
async function postWithTimeout(url: string, body: unknown, timeoutMs = 10000) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetch(url, {
      method: "POST",
      headers: { accept: "application/json", "Content-Type": "application/json" },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
    return res;
  } finally {
    clearTimeout(timer);
  }
}

// ---------------------- HTTP Handler ------------------------
Deno.serve(async (req: Request) => {
  const trace = crypto.randomUUID();

  // CORS preflight
  if (req.method === "OPTIONS") {
    const headers = buildCorsHeaders(req);
    console.log(`[${trace}] 🌀 CORS preflight handled`);
    return new Response(null, { status: 204, headers });
  }

  // Method guard
  if (req.method !== "POST") {
    console.warn(`[${trace}] 🚫 Method not allowed: ${req.method}`);
    return jsonResponse(req, 405, {
      ok: false,
      status: 405,
      message: "Method not allowed. Use POST.",
      requestId: trace,
    });
  }

  // Content-Type guard
  const contentType = req.headers.get("content-type") || "";
  if (!contentType.toLowerCase().includes("application/json")) {
    console.warn(`[${trace}] 🎯 Unsupported Media Type: ${contentType}`);
    return jsonResponse(req, 415, {
      ok: false,
      status: 415,
      message: "Unsupported Media Type. Expect application/json.",
      requestId: trace,
    });
  }

  // Parse body
  let payload: any;
  try {
    payload = await req.json();
  } catch {
    console.warn(`[${trace}] 📦 Invalid JSON body`);
    return jsonResponse(req, 400, {
      ok: false,
      status: 400,
      message: "Invalid JSON body.",
      requestId: trace,
    });
  }

  // Extract & validate fields
  const to = payload?.to;
  const subject = typeof payload?.subject === "string" ? payload.subject.trim() : "";
  const text = typeof payload?.text === "string" ? payload.text : undefined;
  const html = typeof payload?.html === "string" ? payload.html : undefined;

  // prefer body.from, else env DEFAULT_FROM_EMAIL (optional)
  const fromInput = payload?.from;
  const defaultFrom = Deno.env.get("DEFAULT_FROM_EMAIL") ?? "";
  const from = typeof fromInput === "string" && fromInput.trim()
    ? fromInput.trim()
    : defaultFrom;

  // Basic validations (no PII in logs)
  const hasContent = (text && text.trim().length > 0) || (html && html.trim().length > 0);
  const subjectOK = subject.length > 0 && subject.length <= 512;
  const toOK = isValidEmail(to);
  const fromOK = from ? isValidEmail(from) : true;

  if (!toOK || !subjectOK || !hasContent || !fromOK) {
    console.warn(`[${trace}] 🧪 Validation failed (invalid to/subject/content/from)`);
    return jsonResponse(req, 422, {
      ok: false,
      status: 422,
      message:
        "Validation error: provide valid 'to', non-empty 'subject' (<=512 chars), and at least one among 'text' or 'html'. If provided, 'from' must be a valid email.",
      requestId: trace,
    });
  }

  // Compose payload for external email sender
  const senderUrl =
    Deno.env.get("EMAIL_SENDER_URL") ?? "http://18.102.14.247:4000/api/email/send";

  // DO NOT LOG PII
  console.log(`[${trace}] 📨 Sending email via external API (no PII)`);

  // Build minimal payload accepted by the sender
  const emailPayload: Record<string, unknown> = {
    to,
    subject,
    from: from || undefined,
    ...(text ? { text } : {}),
    ...(html ? { html } : {}),
  };

  // Send
  let emailRes: Response;
  try {
    emailRes = await postWithTimeout(senderUrl, emailPayload, 10000);
  } catch (e) {
    console.error(`[${trace}] 🌐 Email service timeout/error: ${String(e)}`);
    return jsonResponse(req, 503, {
      ok: false,
      status: 503,
      message: "Email service unavailable or timed out.",
      requestId: trace,
    });
  }

  if (!emailRes.ok) {
    // DO NOT expose body/PII
    console.error(`[${trace}] ❌ Email service failed with status ${emailRes.status}`);
    return jsonResponse(req, 502, {
      ok: false,
      status: 502,
      message: "Failed to send email.",
      requestId: trace,
    });
  }

  console.log(`[${trace}] ✅ Email sent successfully`);
  return jsonResponse(req, 200, {
    ok: true,
    status: 200,
    message: "Email sent",
    requestId: trace,
  });
});
