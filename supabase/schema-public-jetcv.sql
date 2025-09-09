

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE TYPE "public"."certification_category_type" AS ENUM (
    'standard',
    'custom'
);


ALTER TYPE "public"."certification_category_type" OWNER TO "postgres";


CREATE TYPE "public"."certification_information_scope" AS ENUM (
    'certification',
    'certification_user'
);


ALTER TYPE "public"."certification_information_scope" OWNER TO "postgres";


CREATE TYPE "public"."certification_information_type" AS ENUM (
    'standard',
    'custom'
);


ALTER TYPE "public"."certification_information_type" OWNER TO "postgres";


CREATE TYPE "public"."certification_media_acquisition_type" AS ENUM (
    'realtime',
    'deferred'
);


ALTER TYPE "public"."certification_media_acquisition_type" OWNER TO "postgres";


CREATE TYPE "public"."certification_media_file_type" AS ENUM (
    'image',
    'video',
    'document'
);


ALTER TYPE "public"."certification_media_file_type" OWNER TO "postgres";


CREATE TYPE "public"."certification_status" AS ENUM (
    'draft',
    'sent',
    'closed'
);


ALTER TYPE "public"."certification_status" OWNER TO "postgres";


CREATE TYPE "public"."certification_user_status" AS ENUM (
    'draft',
    'pending',
    'accepted',
    'rejected'
);


ALTER TYPE "public"."certification_user_status" OWNER TO "postgres";


CREATE TYPE "public"."legal_entity_status" AS ENUM (
    'pending',
    'approved',
    'rejected'
);


ALTER TYPE "public"."legal_entity_status" OWNER TO "postgres";


CREATE TYPE "public"."user_gender" AS ENUM (
    'male',
    'female',
    'other',
    'prefer_not_to_say',
    'non_binary'
);


ALTER TYPE "public"."user_gender" OWNER TO "postgres";


CREATE TYPE "public"."user_type" AS ENUM (
    'user',
    'legal_entity',
    'certifier',
    'admin'
);


ALTER TYPE "public"."user_type" OWNER TO "postgres";


CREATE TYPE "public"."wallet_created_by" AS ENUM (
    'application',
    'user'
);


ALTER TYPE "public"."wallet_created_by" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."base36_10_readable"() RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
DECLARE
  b   bytea := gen_random_bytes(8); -- 64 bits of randomness
  val numeric := 0;
  chars text := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  code  text := '';
  i int;
  digit int;
BEGIN
  -- Convert 8 random bytes into a big integer
  FOR i IN 0..7 LOOP
    val := val * 256 + get_byte(b, i);
  END LOOP;

  -- Build 10 base36 digits (most significant padded by division chain)
  FOR i IN 1..10 LOOP
    digit := (val % 36)::int;
    code := substr(chars, digit + 1, 1) || code; -- prepend
    val := trunc(val / 36);
  END LOOP;

  RETURN substr(code, 1, 5) || '-' || substr(code, 6, 5);
END;
$$;


ALTER FUNCTION "public"."base36_10_readable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."base64url_encode"("input" "bytea") RETURNS "text"
    LANGUAGE "sql"
    AS $_$
  SELECT regexp_replace(
           replace(replace(encode($1, 'base64'), '+', '-'), '/', '_'),
           '=+$', ''
         )
$_$;


ALTER FUNCTION "public"."base64url_encode"("input" "bytea") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."create_user_row_on_auth"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    BEGIN
        INSERT INTO public."user"
            ("idUser", "fullName", "profilePicture", "email", "idUserHash")
        VALUES (
            NEW.id,
            COALESCE(jsonb_extract_path_text(NEW.raw_user_meta_data, 'full_name'), NULL),
            COALESCE(
                jsonb_extract_path_text(NEW.raw_user_meta_data, 'picture'),
                jsonb_extract_path_text(NEW.raw_user_meta_data, 'avatar_url'),
                NULL
            ),
            NEW.email,
            encode(extensions.digest(NEW.id::text, 'sha256'), 'hex')
        );
    EXCEPTION WHEN OTHERS THEN
        -- Log only errors
        RAISE LOG 'ERROR create_user_row_on_auth for NEW.id=%: % (SQLSTATE=%)',
            NEW.id, SQLERRM, SQLSTATE;
    END;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."create_user_row_on_auth"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."gen_codice_6"() RETURNS "text"
    LANGUAGE "sql"
    AS $$
  SELECT string_agg(
           substr('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
                  (trunc(random() * 36 + 1))::int, 1),
           ''
         )
  FROM generate_series(1,6);
$$;


ALTER FUNCTION "public"."gen_codice_6"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."gen_url_token_256"() RETURNS "text"
    LANGUAGE "sql"
    AS $$
  SELECT base64url_encode(gen_random_bytes(32))
$$;


ALTER FUNCTION "public"."gen_url_token_256"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_profile_picture_upload"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'storage', 'pg_temp'
    AS $$
declare
  base_url text := 'https://ammryjdbnqedwlguhqpv.supabase.co';
  file_path text := NEW.name;               -- es: "files/xyz.png"
  bucket    text := NEW.bucket_id;          -- es: "profilopictures"
  public_url text;
  target_user uuid;
  uuid_from_name uuid;
begin
  -- Considera solo il bucket/percorsi desiderati
  if bucket = 'profilopictures' and file_path like 'files/%' then

    -- 1) Prova a usare l’owner del file (utente che ha fatto l’upload)
    target_user := NEW.owner;

    -- 2) Fallback: se non c'è owner, prova a estrarre un UUID nel filename
    --    es. files/9f5d2b0b-1234-4a1b-9f3a-0a1b2c3d4e5f.png
    if target_user is null then
      select (regexp_matches(file_path,
              '([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-4[0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12})'))[1]::uuid
      into uuid_from_name;
      target_user := uuid_from_name;
    end if;

    -- Se abbiamo un utente valido, aggiorna la sua foto profilo
    if target_user is not null then
      public_url := base_url
        || '/storage/v1/object/public/'
        || bucket || '/' || file_path;

      update public."user"
         set "profilePicture" = public_url
       where id = target_user;
    end if;
  end if;

  return NEW;
end;
$$;


ALTER FUNCTION "public"."handle_profile_picture_upload"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."openbadge_denormalize"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.assertion_id   := COALESCE(NEW.assertion_json->>'id', NEW.assertion_id);
  NEW.badge_class_id := COALESCE(NEW.assertion_json->'badge'->>'id', NEW.badge_class_id);
  NEW.issuer_id      := COALESCE(NEW.assertion_json->'issuer'->>'id', NEW.issuer_id);

  -- issuedOn / expires come ISO8601 nel JSON
  IF (NEW.issued_at IS NULL) AND (NEW.assertion_json ? 'issuedOn') THEN
    NEW.issued_at := (NEW.assertion_json->>'issuedOn')::timestamptz;
  END IF;

  IF (NEW.expires_at IS NULL) AND (NEW.assertion_json ? 'expires') THEN
    NEW.expires_at := (NEW.assertion_json->>'expires')::timestamptz;
  END IF;

  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."openbadge_denormalize"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."otp_burn"("p_id_otp" "uuid", "p_id_user" "uuid" DEFAULT NULL::"uuid") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    -- Validate input
    IF p_id_otp IS NULL THEN
        RAISE EXCEPTION 'OTP ID cannot be null';
    END IF;
    
    -- Update the OTP to mark it as burned
    UPDATE public.otp
    SET 
        burned_at = NOW(),
        updated_at = NOW()
    WHERE public.otp.id_otp = p_id_otp
    AND (p_id_user IS NULL OR public.otp.id_user = p_id_user)
    AND public.otp.burned_at IS NULL;
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    
    RETURN v_updated_count > 0;
END;
$$;


ALTER FUNCTION "public"."otp_burn"("p_id_otp" "uuid", "p_id_user" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."otp_create"("p_id_user" "uuid" DEFAULT NULL::"uuid", "p_tag" "text" DEFAULT NULL::"text", "p_ttl_seconds" integer DEFAULT 300, "p_length" integer DEFAULT 6, "p_numeric_only" boolean DEFAULT true) RETURNS TABLE("id_otp" "uuid", "id_user" "uuid", "code" "text", "code_hash" "text", "tag" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "expires_at" timestamp with time zone, "used_at" timestamp with time zone, "used_by_id_user" "uuid", "burned_at" timestamp with time zone)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_code TEXT;
    v_code_hash TEXT;
    v_expires_at TIMESTAMPTZ;
    v_result RECORD;
    v_attempts INTEGER := 0;
    v_max_attempts INTEGER := 10;
BEGIN
    -- Validate input parameters
    IF p_length < 4 OR p_length > 10 THEN
        RAISE EXCEPTION 'OTP length must be between 4 and 10 characters';
    END IF;
    
    IF p_ttl_seconds < 60 OR p_ttl_seconds > 86400 THEN
        RAISE EXCEPTION 'TTL must be between 60 seconds and 24 hours';
    END IF;
    
    -- Generate unique code (retry if collision)
    LOOP
        v_attempts := v_attempts + 1;
        
        IF v_attempts > v_max_attempts THEN
            RAISE EXCEPTION 'Failed to generate unique OTP code after % attempts', v_max_attempts;
        END IF;
        
        -- Generate code based on parameters
        IF p_numeric_only THEN
            -- Generate numeric code
            v_code := LPAD(FLOOR(RANDOM() * POWER(10, p_length))::TEXT, p_length, '0');
        ELSE
            -- Generate alphanumeric code (uppercase letters and numbers)
            v_code := '';
            FOR i IN 1..p_length LOOP
                IF RANDOM() < 0.5 THEN
                    -- Add a number
                    v_code := v_code || FLOOR(RANDOM() * 10)::TEXT;
                ELSE
                    -- Add a letter
                    v_code := v_code || CHR(65 + FLOOR(RANDOM() * 26)::INTEGER);
                END IF;
            END LOOP;
        END IF;
        
        -- Hash the code
        v_code_hash := ENCODE(DIGEST(v_code, 'sha256'), 'hex');
        
        -- Check if this hash already exists and is still valid
        IF NOT EXISTS (
            SELECT 1 FROM public.otp 
            WHERE public.otp.code_hash = v_code_hash 
            AND public.otp.burned_at IS NULL 
            AND public.otp.used_at IS NULL 
            AND public.otp.expires_at > NOW()
        ) THEN
            EXIT; -- Unique code found
        END IF;
    END LOOP;
    
    -- Calculate expiration time
    v_expires_at := NOW() + (p_ttl_seconds || ' seconds')::INTERVAL;
    
    -- Insert the OTP
    INSERT INTO public.otp (
        id_user,
        code,
        code_hash,
        tag,
        created_at,
        updated_at,
        expires_at
    ) VALUES (
        p_id_user,
        v_code,
        v_code_hash,
        p_tag,
        NOW(),
        NOW(),
        v_expires_at
    ) RETURNING * INTO v_result;
    
    -- Return the created OTP
    RETURN QUERY SELECT 
        v_result.id_otp,
        v_result.id_user,
        v_result.code,
        v_result.code_hash,
        v_result.tag,
        v_result.created_at,
        v_result.updated_at,
        v_result.expires_at,
        v_result.used_at,
        v_result.used_by_id_user,
        v_result.burned_at;
END;
$$;


ALTER FUNCTION "public"."otp_create"("p_id_user" "uuid", "p_tag" "text", "p_ttl_seconds" integer, "p_length" integer, "p_numeric_only" boolean) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."otp_gc"("p_before" timestamp with time zone DEFAULT NULL::timestamp with time zone) RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_before TIMESTAMPTZ;
    v_burned_count INTEGER;
BEGIN
    -- Use provided time or default to now
    v_before := COALESCE(p_before, NOW());
    
    -- Mark expired OTPs as burned
    UPDATE public.otp
    SET 
        burned_at = NOW(),
        updated_at = NOW()
    WHERE public.otp.expires_at <= v_before
    AND public.otp.burned_at IS NULL;
    
    GET DIAGNOSTICS v_burned_count = ROW_COUNT;
    
    RETURN v_burned_count;
END;
$$;


ALTER FUNCTION "public"."otp_gc"("p_before" timestamp with time zone) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."otp_get_metadata"("p_id_otp" "uuid") RETURNS TABLE("id_otp" "uuid", "id_user" "uuid", "tag" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "expires_at" timestamp with time zone, "used_at" timestamp with time zone, "used_by_id_user" "uuid", "burned_at" timestamp with time zone, "is_expired" boolean, "is_used" boolean, "is_burned" boolean, "is_valid" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_otp RECORD;
BEGIN
    -- Validate input
    IF p_id_otp IS NULL THEN
        RAISE EXCEPTION 'OTP ID cannot be null';
    END IF;
    
    -- Get the OTP metadata
    SELECT 
        id_otp,
        id_user,
        tag,
        created_at,
        updated_at,
        expires_at,
        used_at,
        used_by_id_user,
        burned_at,
        (expires_at <= NOW()) as is_expired,
        (used_at IS NOT NULL) as is_used,
        (burned_at IS NOT NULL) as is_burned,
        (expires_at > NOW() AND used_at IS NULL AND burned_at IS NULL) as is_valid
    INTO v_otp
    FROM public.otp
    WHERE public.otp.id_otp = p_id_otp;
    
    -- Return the result
    RETURN QUERY SELECT 
        v_otp.id_otp,
        v_otp.id_user,
        v_otp.tag,
        v_otp.created_at,
        v_otp.updated_at,
        v_otp.expires_at,
        v_otp.used_at,
        v_otp.used_by_id_user,
        v_otp.burned_at,
        v_otp.is_expired,
        v_otp.is_used,
        v_otp.is_burned,
        v_otp.is_valid;
END;
$$;


ALTER FUNCTION "public"."otp_get_metadata"("p_id_otp" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."otp_list_user_otps"("p_id_user" "uuid", "p_limit" integer DEFAULT 50, "p_offset" integer DEFAULT 0) RETURNS TABLE("id_otp" "uuid", "id_user" "uuid", "tag" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "expires_at" timestamp with time zone, "used_at" timestamp with time zone, "used_by_id_user" "uuid", "burned_at" timestamp with time zone, "is_expired" boolean, "is_used" boolean, "is_burned" boolean, "is_valid" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    -- Validate input
    IF p_id_user IS NULL THEN
        RAISE EXCEPTION 'User ID cannot be null';
    END IF;
    
    IF p_limit < 1 OR p_limit > 100 THEN
        RAISE EXCEPTION 'Limit must be between 1 and 100';
    END IF;
    
    IF p_offset < 0 THEN
        RAISE EXCEPTION 'Offset cannot be negative';
    END IF;
    
    -- Return user's OTPs
    RETURN QUERY 
    SELECT 
        o.id_otp,
        o.id_user,
        o.tag,
        o.created_at,
        o.updated_at,
        o.expires_at,
        o.used_at,
        o.used_by_id_user,
        o.burned_at,
        (o.expires_at <= NOW()) as is_expired,
        (o.used_at IS NOT NULL) as is_used,
        (o.burned_at IS NOT NULL) as is_burned,
        (o.expires_at > NOW() AND o.used_at IS NULL AND o.burned_at IS NULL) as is_valid
    FROM public.otp o
    WHERE o.id_user = p_id_user
    ORDER BY o.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;


ALTER FUNCTION "public"."otp_list_user_otps"("p_id_user" "uuid", "p_limit" integer, "p_offset" integer) OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."otp_verify"("p_code" "text", "p_id_user" "uuid" DEFAULT NULL::"uuid", "p_tag" "text" DEFAULT NULL::"text", "p_mark_used" boolean DEFAULT true, "p_used_by" "uuid" DEFAULT NULL::"uuid") RETURNS TABLE("id_otp" "uuid", "id_user" "uuid", "code" "text", "code_hash" "text", "tag" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "expires_at" timestamp with time zone, "used_at" timestamp with time zone, "used_by_id_user" "uuid", "burned_at" timestamp with time zone, "is_valid" boolean)
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    v_otp RECORD;
    v_code_hash TEXT;
    v_is_valid BOOLEAN := FALSE;
BEGIN
    -- Validate input
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) = 0 THEN
        RAISE EXCEPTION 'OTP code cannot be empty';
    END IF;
    
    -- Hash the provided code
    v_code_hash := ENCODE(DIGEST(TRIM(p_code), 'sha256'), 'hex');
    
    -- Find the OTP
    SELECT * INTO v_otp
    FROM public.otp
    WHERE public.otp.code_hash = v_code_hash
    AND (p_id_user IS NULL OR public.otp.id_user = p_id_user)
    AND (p_tag IS NULL OR public.otp.tag = p_tag)
    AND public.otp.burned_at IS NULL
    AND public.otp.used_at IS NULL
    AND public.otp.expires_at > NOW()
    ORDER BY public.otp.created_at DESC
    LIMIT 1;
    
    -- Check if OTP was found and is valid
    IF v_otp.id_otp IS NOT NULL THEN
        v_is_valid := TRUE;
        
        -- Mark as used if requested
        IF p_mark_used THEN
            UPDATE public.otp
            SET 
                used_at = NOW(),
                used_by_id_user = p_used_by,
                updated_at = NOW()
            WHERE public.otp.id_otp = v_otp.id_otp;
            
            -- Update the record
            v_otp.used_at := NOW();
            v_otp.used_by_id_user := p_used_by;
            v_otp.updated_at := NOW();
        END IF;
    END IF;
    
    -- Return the result
    RETURN QUERY SELECT 
        v_otp.id_otp,
        v_otp.id_user,
        v_otp.code,
        v_otp.code_hash,
        v_otp.tag,
        v_otp.created_at,
        v_otp.updated_at,
        v_otp.expires_at,
        v_otp.used_at,
        v_otp.used_by_id_user,
        v_otp.burned_at,
        v_is_valid;
END;
$$;


ALTER FUNCTION "public"."otp_verify"("p_code" "text", "p_id_user" "uuid", "p_tag" "text", "p_mark_used" boolean, "p_used_by" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text" DEFAULT 'https://ammryjdbnqedwlguhqpv.supabase.co'::"text") RETURNS integer
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'storage', 'pg_temp'
    AS $_$
/*
  Aggiorna public."user".profilePicture con la public URL
  dell’ultima immagine (png/jpg/jpeg/webp/gif) trovata in:
    profilepictures / files / <user_id> / *
  Ritorna il numero di righe aggiornate.
*/
declare
  v_updated integer := 0;
begin
  -- Aggiorna in blocco tutti gli utenti che hanno almeno un file idoneo
  with latest_per_user as (
    select
      u.id as user_id,
      so.name as object_name,
      row_number() over (partition by u.id order by so.created_at desc) as rn
    from public."user" u
    join storage.objects so
      on so.bucket_id = 'profilepictures'
     and so.name like ('files/' || u.id::text || '/%')
     and lower(so.name) ~ '\.(png|jpe?g|webp|gif)$'
  )
  update public."user" u
     set "profilePicture" =
         p_base_url || '/storage/v1/object/public/profilepictures/' || l.object_name
  from latest_per_user l
  where l.user_id = u.id
    and l.rn = 1;  -- solo l'ultima immagine per utente

  get diagnostics v_updated = row_count;
  return v_updated;
end;
$_$;


ALTER FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."set_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."set_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_user_profile_picture"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
    public_url text;
BEGIN
    -- Check if the file is in the profilopictures/files/ bucket
    -- and the owner matches the currently authenticated user
    IF NEW.bucket_id = 'profilopictures' AND 
       NEW.name LIKE 'files/%' AND 
       NEW.owner_id = auth.uid()::text THEN
        
        -- Generate public URL for the uploaded file
        public_url := (
            SELECT url 
            FROM storage.objects 
            WHERE id = NEW.id
        );
        
        -- Update user's profile picture
        UPDATE public.user 
        SET "profilePicture" = public_url,
            "updatedAt" = NOW()
        WHERE "idUser" = auth.uid();
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_user_profile_picture"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."certification" (
    "id_certification" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_certification_hash" "text" NOT NULL,
    "id_certifier" "uuid" NOT NULL,
    "id_legal_entity" "uuid" NOT NULL,
    "status" "public"."certification_status" DEFAULT 'draft'::"public"."certification_status" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_t" timestamp with time zone,
    "serial_number" "text" DEFAULT "public"."base36_10_readable"() NOT NULL,
    "id_location" "uuid" NOT NULL,
    "n_users" smallint NOT NULL,
    "sent_at" timestamp with time zone,
    "draft_at" timestamp with time zone,
    "closed_at" timestamp with time zone,
    "id_certification_category" "uuid" NOT NULL,
    CONSTRAINT "cert_serial_number_format_ck" CHECK (("serial_number" ~ '^[A-Z0-9]{5}-[A-Z0-9]{5}$'::"text"))
);


ALTER TABLE "public"."certification" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_category" (
    "name" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "type" "public"."certification_category_type" NOT NULL,
    "order" smallint,
    "id_legal_entity" "uuid",
    "id_certification_category" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."certification_category" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_category_has_information" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "id_certification_category" "uuid" NOT NULL,
    "id_certification_information" "uuid" NOT NULL,
    "id_certification_category_has_information" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."certification_category_has_information" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_has_media" (
    "id_certification_has_media" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "id_certification" "uuid",
    "id_certification_user" "uuid",
    "id_certification_media" "uuid" NOT NULL
);


ALTER TABLE "public"."certification_has_media" OWNER TO "postgres";


ALTER TABLE "public"."certification_has_media" ALTER COLUMN "id_certification_has_media" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."certification_has_media_id_certification_has_media_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."certification_information" (
    "name" "text" NOT NULL,
    "order" smallint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "label" "text" NOT NULL,
    "type" "public"."certification_information_type",
    "id_certification_information" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_legal_entity" "uuid",
    "scope" "public"."certification_information_scope"
);


ALTER TABLE "public"."certification_information" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_information_value" (
    "id_certification_information_value" bigint NOT NULL,
    "id_certification_information" "uuid" NOT NULL,
    "value" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "id_certification" "uuid",
    "id_certification_user" "uuid"
);


ALTER TABLE "public"."certification_information_value" OWNER TO "postgres";


ALTER TABLE "public"."certification_information_value" ALTER COLUMN "id_certification_information_value" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."certification_information_val_id_certification_information__seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."certification_media" (
    "id_certification_media" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_media_hash" "text" NOT NULL,
    "id_certification" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "name" "text",
    "description" "text",
    "acquisition_type" "public"."certification_media_acquisition_type" NOT NULL,
    "captured_at" timestamp with time zone NOT NULL,
    "id_location" "uuid",
    "file_type" "public"."certification_media_file_type" NOT NULL
);


ALTER TABLE "public"."certification_media" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certification_user" (
    "id_certification" "uuid" NOT NULL,
    "id_user" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "status" "public"."certification_user_status" DEFAULT 'draft'::"public"."certification_user_status" NOT NULL,
    "id_certification_user" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "serial_number" "text" DEFAULT "public"."base36_10_readable"() NOT NULL,
    "rejection_reason" "text",
    "id_otp" "uuid" NOT NULL
);


ALTER TABLE "public"."certification_user" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."certifier" (
    "id_certifier" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_certifier_hash" "text" NOT NULL,
    "id_legal_entity" "uuid" NOT NULL,
    "id_user" "uuid",
    "active" boolean DEFAULT true NOT NULL,
    "role" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "invitation_token" "text" DEFAULT "public"."gen_url_token_256"(),
    "kyc_passed" boolean,
    "id_kyc_attempt" "uuid",
    CONSTRAINT "certifier_invitation_token_format_ck" CHECK (("invitation_token" ~ '^[A-Za-z0-9_-]{43}$'::"text"))
);


ALTER TABLE "public"."certifier" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."country" (
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "emoji" "text"
);


ALTER TABLE "public"."country" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."cv" (
    "idCv" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "idUser" "uuid" NOT NULL,
    "idWallet" "uuid" NOT NULL,
    "nftTokenId" "text",
    "nftMintTransactionUrl" "text",
    "nftMintTransactionHash" "text",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "firstName" "text",
    "firstNameHash" "text",
    "lastName" "text",
    "lastNameHash" "text",
    "email" "text",
    "emailHash" "text",
    "phone" "text",
    "phoneHash" "text",
    "dateOfBirth" "text",
    "dateOfBirthHash" "text",
    "address" "text",
    "addressHash" "text",
    "city" "text",
    "cityHash" "text",
    "state" "text",
    "stateHash" "text",
    "postalCode" "text",
    "postalCodeHash" "text",
    "countryCode" "text",
    "countryCodeHash" "text",
    "profilePicture" "text",
    "profilePictureHash" "text",
    "gender" "text",
    "genderHash" "text",
    "ipfsCid" "text",
    "ipfsUrl" "text",
    "idCvHash" "text",
    "firstNameSalt" "text",
    "lastNameSalt" "text",
    "emailSalt" "text",
    "phoneSalt" "text",
    "dateOfBirthSalt" "text",
    "addressSalt" "text",
    "citySalt" "text",
    "stateSalt" "text",
    "postalCodeSalt" "text",
    "countryCodeSalt" "text",
    "profilePictureSalt" "text",
    "genderSalt" "text",
    "publicId" "text",
    "serial_number" "text" DEFAULT "public"."base36_10_readable"() NOT NULL,
    "serial_number_hash" "text",
    "serial_number_salt" "text",
    "nationality_codes" "text"[],
    "nationality_codes_hash" "text"[],
    "nationality_codes_salt" "text"[],
    "language_codes" "text"[],
    "language_codes_hash" "text"[],
    "language_codes_salt" "text"[],
    CONSTRAINT "cv_serial_number_format_ck" CHECK (("serial_number" ~ '^[A-Z0-9]{5}-[A-Z0-9]{5}$'::"text"))
);


ALTER TABLE "public"."cv" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."debug_log" (
    "ts" timestamp with time zone DEFAULT "now"(),
    "message" "text",
    "id_debug_log" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."debug_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."kyc_attempt" (
    "id_user" "uuid" NOT NULL,
    "request_body" "text",
    "success" "text",
    "message" "text",
    "received_params" "text",
    "response_status" "text",
    "response_verification_id" "text",
    "response_verification_url" "text",
    "response_verification_session_token" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "session_id" "text",
    "verificated" boolean,
    "verificated_at" timestamp with time zone,
    "id_kyc_attempt" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."kyc_attempt" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."legal_entity" (
    "id_legal_entity" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_legal_entity_hash" "text" NOT NULL,
    "legal_name" "text",
    "identifier_code" "text",
    "operational_address" "text",
    "operational_city" "text",
    "operational_postal_code" "text",
    "operational_state" "text",
    "operational_country" "text",
    "headquarter_address" "text",
    "headquarter_city" "text",
    "headquarter_postal_code" "text",
    "headquarter_state" "text",
    "headquarter_country" "text",
    "legal_rapresentative" "text",
    "email" "text",
    "phone" "text",
    "pec" "text",
    "website" "text",
    "status" "public"."legal_entity_status" NOT NULL,
    "logo_picture" "text",
    "company_picture" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "created_by_id_user" "uuid" NOT NULL
);


ALTER TABLE "public"."legal_entity" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."legal_entity_invitation" (
    "id_legal_entity" "uuid" NOT NULL,
    "email" "text" NOT NULL,
    "invitation_token" "text" DEFAULT "public"."gen_url_token_256"() NOT NULL,
    "sent_at" timestamp with time zone,
    "expires_at" timestamp with time zone NOT NULL,
    "accepted_at" timestamp with time zone,
    "id_legal_entity_invitation" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "valid" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."legal_entity_invitation" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."location" (
    "id_location" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "aquired_at" timestamp with time zone NOT NULL,
    "latitude" double precision NOT NULL,
    "longitude" double precision NOT NULL,
    "accuracy_m" real,
    "is_moked" boolean,
    "altitude" double precision,
    "altitude_accuracy_m" real,
    "name" "text",
    "street" "text",
    "locality" "text",
    "sub_locality" "text",
    "administrative_area" "text",
    "sub_administrative_area" "text",
    "postal_code" "text",
    "iso_country_code" "text",
    "country" "text",
    "thoroughfare" "text",
    "sub_thoroughfare" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."location" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."openbadge" (
    "id_openbadge" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "assertion_json" "jsonb" NOT NULL,
    "assertion_id" "text",
    "badge_class_id" "text",
    "issuer_id" "text",
    "is_revoked" boolean DEFAULT false NOT NULL,
    "revoked_at" timestamp with time zone,
    "issued_at" timestamp with time zone,
    "expires_at" timestamp with time zone,
    "source" "text",
    "note" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    CONSTRAINT "openbadge_is_assertion_check" CHECK ((("assertion_json" ? '@context'::"text") AND ("assertion_json" ? 'type'::"text") AND ((("jsonb_typeof"(("assertion_json" -> 'type'::"text")) = 'string'::"text") AND (("assertion_json" ->> 'type'::"text") = 'Assertion'::"text")) OR (("jsonb_typeof"(("assertion_json" -> 'type'::"text")) = 'array'::"text") AND (("assertion_json" -> 'type'::"text") ? 'Assertion'::"text")))))
);


ALTER TABLE "public"."openbadge" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."otp" (
    "id_otp" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "id_user" "uuid" NOT NULL,
    "code" "text" NOT NULL,
    "code_hash" "text" NOT NULL,
    "tag" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone,
    "expires_at" timestamp with time zone NOT NULL,
    "used_at" timestamp with time zone,
    "used_by_id_user" "uuid",
    "burned_at" timestamp with time zone,
    "id_legal_entity" "uuid"
);


ALTER TABLE "public"."otp" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."user" (
    "idUser" "uuid" NOT NULL,
    "firstName" "text",
    "lastName" "text",
    "email" "text",
    "phone" "text",
    "dateOfBirth" "date",
    "address" "text",
    "city" "text",
    "state" "text",
    "postalCode" "text",
    "countryCode" "text",
    "profilePicture" "text",
    "gender" "public"."user_gender",
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "fullName" "text",
    "type" "public"."user_type",
    "hasWallet" boolean DEFAULT false NOT NULL,
    "idWallet" "uuid",
    "hasCv" boolean DEFAULT false NOT NULL,
    "idCv" "uuid",
    "idUserHash" "text" NOT NULL,
    "profileCompleted" boolean DEFAULT false NOT NULL,
    "languageCodeApp" "text",
    "nationalityCodes" "text"[],
    "languageCodes" "text"[]
);


ALTER TABLE "public"."user" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."wallet" (
    "idUser" "uuid" NOT NULL,
    "secretKey" "text" NOT NULL,
    "createdAt" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updatedAt" timestamp with time zone,
    "createdBy" "public"."wallet_created_by" NOT NULL,
    "publicAddress" "text" NOT NULL,
    "idWallet" "uuid" DEFAULT "gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."wallet" OWNER TO "postgres";


ALTER TABLE ONLY "public"."certification_category_has_information"
    ADD CONSTRAINT "certification_category_has_information_pkey" PRIMARY KEY ("id_certification_category_has_information");



ALTER TABLE ONLY "public"."certification_category"
    ADD CONSTRAINT "certification_category_id_cat_uuid_uc" UNIQUE ("id_certification_category");



ALTER TABLE ONLY "public"."certification_category"
    ADD CONSTRAINT "certification_category_pkey" PRIMARY KEY ("id_certification_category");



ALTER TABLE ONLY "public"."certification_has_media"
    ADD CONSTRAINT "certification_has_media_pkey" PRIMARY KEY ("id_certification_has_media");



ALTER TABLE ONLY "public"."certification_information"
    ADD CONSTRAINT "certification_information_pkey" PRIMARY KEY ("id_certification_information");



ALTER TABLE ONLY "public"."certification_information"
    ADD CONSTRAINT "certification_information_uuid_uc" UNIQUE ("id_certification_information");



ALTER TABLE ONLY "public"."certification_information_value"
    ADD CONSTRAINT "certification_information_value_pkey" PRIMARY KEY ("id_certification_information_value");



ALTER TABLE ONLY "public"."certification_media"
    ADD CONSTRAINT "certification_media_pkey" PRIMARY KEY ("id_certification_media");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_pkey" PRIMARY KEY ("id_certification");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_pkey" PRIMARY KEY ("id_certification_user");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_serial_key" UNIQUE ("serial_number");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_invitation_id_key" UNIQUE ("invitation_token");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_pkey1" PRIMARY KEY ("id_certifier");



ALTER TABLE ONLY "public"."country"
    ADD CONSTRAINT "country_pkey" PRIMARY KEY ("code");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_iduser_key" UNIQUE ("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_pkey" PRIMARY KEY ("idCv");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_serial_number_key" UNIQUE ("serial_number");



ALTER TABLE ONLY "public"."kyc_attempt"
    ADD CONSTRAINT "kyc_attempt_pkey" PRIMARY KEY ("id_kyc_attempt");



ALTER TABLE ONLY "public"."legal_entity_invitation"
    ADD CONSTRAINT "legal_entity_invitation_pkey" PRIMARY KEY ("id_legal_entity_invitation");



ALTER TABLE ONLY "public"."legal_entity_invitation"
    ADD CONSTRAINT "legal_entity_invitations_invitation_token_key" UNIQUE ("invitation_token");



ALTER TABLE ONLY "public"."legal_entity"
    ADD CONSTRAINT "legal_entity_pkey1" PRIMARY KEY ("id_legal_entity");



ALTER TABLE ONLY "public"."location"
    ADD CONSTRAINT "location_pkey" PRIMARY KEY ("id_location");



ALTER TABLE ONLY "public"."openbadge"
    ADD CONSTRAINT "openbadge_pkey" PRIMARY KEY ("id_openbadge");



ALTER TABLE ONLY "public"."openbadge"
    ADD CONSTRAINT "openbadge_user_assertion_unique" UNIQUE ("id_user", "assertion_id");



ALTER TABLE ONLY "public"."otp"
    ADD CONSTRAINT "otp_pkey" PRIMARY KEY ("id_otp");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_pkey" PRIMARY KEY ("idUser");



ALTER TABLE ONLY "public"."wallet"
    ADD CONSTRAINT "wallet_pkey" PRIMARY KEY ("idWallet");



ALTER TABLE ONLY "public"."wallet"
    ADD CONSTRAINT "wallet_publicaddress_key" UNIQUE ("publicAddress");



CREATE INDEX "legal_entity_invitations_email_idx" ON "public"."legal_entity_invitation" USING "btree" ("email");



CREATE INDEX "legal_entity_invitations_id_legal_entity_idx" ON "public"."legal_entity_invitation" USING "btree" ("id_legal_entity");



CREATE INDEX "openbadge_assertion_gin_idx" ON "public"."openbadge" USING "gin" ("assertion_json" "jsonb_path_ops");



CREATE INDEX "openbadge_expires_at_idx" ON "public"."openbadge" USING "btree" ("expires_at" DESC NULLS LAST);



CREATE INDEX "openbadge_id_user_idx" ON "public"."openbadge" USING "btree" ("id_user");



CREATE INDEX "openbadge_is_revoked_idx" ON "public"."openbadge" USING "btree" ("is_revoked");



CREATE INDEX "openbadge_issued_at_idx" ON "public"."openbadge" USING "btree" ("issued_at" DESC NULLS LAST);



CREATE OR REPLACE TRIGGER "trg_openbadge_denormalize_ins" BEFORE INSERT ON "public"."openbadge" FOR EACH ROW EXECUTE FUNCTION "public"."openbadge_denormalize"();



CREATE OR REPLACE TRIGGER "trg_openbadge_denormalize_upd" BEFORE UPDATE ON "public"."openbadge" FOR EACH ROW EXECUTE FUNCTION "public"."openbadge_denormalize"();



CREATE OR REPLACE TRIGGER "trg_openbadge_set_updated_at" BEFORE UPDATE ON "public"."openbadge" FOR EACH ROW EXECUTE FUNCTION "public"."set_updated_at"();



ALTER TABLE ONLY "public"."certification_category_has_information"
    ADD CONSTRAINT "certification_category_has_in_id_certification_information_fkey" FOREIGN KEY ("id_certification_information") REFERENCES "public"."certification_information"("id_certification_information");



ALTER TABLE ONLY "public"."certification_category_has_information"
    ADD CONSTRAINT "certification_category_has_infor_id_certification_category_fkey" FOREIGN KEY ("id_certification_category") REFERENCES "public"."certification_category"("id_certification_category");



ALTER TABLE ONLY "public"."certification_category"
    ADD CONSTRAINT "certification_category_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."certification_has_media"
    ADD CONSTRAINT "certification_has_media_id_certification_fkey" FOREIGN KEY ("id_certification") REFERENCES "public"."certification"("id_certification");



ALTER TABLE ONLY "public"."certification_has_media"
    ADD CONSTRAINT "certification_has_media_id_certification_media_fkey" FOREIGN KEY ("id_certification_media") REFERENCES "public"."certification_media"("id_certification_media");



ALTER TABLE ONLY "public"."certification_has_media"
    ADD CONSTRAINT "certification_has_media_id_certification_user_fkey" FOREIGN KEY ("id_certification_user") REFERENCES "public"."certification_user"("id_certification_user");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_id_certification_category_fkey" FOREIGN KEY ("id_certification_category") REFERENCES "public"."certification_category"("id_certification_category");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_id_certifier_fkey" FOREIGN KEY ("id_certifier") REFERENCES "public"."certifier"("id_certifier");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."certification"
    ADD CONSTRAINT "certification_id_location_fkey" FOREIGN KEY ("id_location") REFERENCES "public"."location"("id_location");



ALTER TABLE ONLY "public"."certification_information"
    ADD CONSTRAINT "certification_information_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."certification_information_value"
    ADD CONSTRAINT "certification_information_val_id_certification_information_fkey" FOREIGN KEY ("id_certification_information") REFERENCES "public"."certification_information"("id_certification_information");



ALTER TABLE ONLY "public"."certification_information_value"
    ADD CONSTRAINT "certification_information_value_id_certification_fkey" FOREIGN KEY ("id_certification") REFERENCES "public"."certification"("id_certification");



ALTER TABLE ONLY "public"."certification_information_value"
    ADD CONSTRAINT "certification_information_value_id_certification_user_fkey" FOREIGN KEY ("id_certification_user") REFERENCES "public"."certification_user"("id_certification_user");



ALTER TABLE ONLY "public"."certification_media"
    ADD CONSTRAINT "certification_media_id_location_fkey" FOREIGN KEY ("id_location") REFERENCES "public"."location"("id_location");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_id_certification_fkey" FOREIGN KEY ("id_certification") REFERENCES "public"."certification"("id_certification");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_id_otp_fkey" FOREIGN KEY ("id_otp") REFERENCES "public"."otp"("id_otp");



ALTER TABLE ONLY "public"."certification_user"
    ADD CONSTRAINT "certification_user_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_id_kyc_attempt_fkey" FOREIGN KEY ("id_kyc_attempt") REFERENCES "public"."kyc_attempt"("id_kyc_attempt");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."certifier"
    ADD CONSTRAINT "certifier_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."cv"
    ADD CONSTRAINT "cv_idWallet_fkey" FOREIGN KEY ("idWallet") REFERENCES "public"."wallet"("idWallet");



ALTER TABLE ONLY "public"."kyc_attempt"
    ADD CONSTRAINT "kyc_attempts_idUser_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."legal_entity"
    ADD CONSTRAINT "legal_entity_created_by_id_user_fkey" FOREIGN KEY ("created_by_id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."legal_entity_invitation"
    ADD CONSTRAINT "legal_entity_invitations_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."location"
    ADD CONSTRAINT "location_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."certification_media"
    ADD CONSTRAINT "media_id_certification_fkey" FOREIGN KEY ("id_certification") REFERENCES "public"."certification"("id_certification");



ALTER TABLE ONLY "public"."openbadge"
    ADD CONSTRAINT "openbadge_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."otp"
    ADD CONSTRAINT "otp_id_legal_entity_fkey" FOREIGN KEY ("id_legal_entity") REFERENCES "public"."legal_entity"("id_legal_entity");



ALTER TABLE ONLY "public"."otp"
    ADD CONSTRAINT "otp_id_user_fkey" FOREIGN KEY ("id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."otp"
    ADD CONSTRAINT "otp_used_by_id_user_fkey" FOREIGN KEY ("used_by_id_user") REFERENCES "public"."user"("idUser");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_countryCode_fkey" FOREIGN KEY ("countryCode") REFERENCES "public"."country"("code");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_idCv_fkey" FOREIGN KEY ("idCv") REFERENCES "public"."cv"("idCv");



ALTER TABLE ONLY "public"."user"
    ADD CONSTRAINT "user_idWallet_fkey" FOREIGN KEY ("idWallet") REFERENCES "public"."wallet"("idWallet");



ALTER TABLE ONLY "public"."wallet"
    ADD CONSTRAINT "wallet_idUser_fkey" FOREIGN KEY ("idUser") REFERENCES "public"."user"("idUser");



ALTER TABLE "public"."certification" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_category_has_information" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_has_media" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_information" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_information_value" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_media" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certification_user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."certifier" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."country" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."cv" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."debug_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."kyc_attempt" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_entity" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_entity_invitation" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."location" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."otp" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."wallet" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."base36_10_readable"() TO "anon";
GRANT ALL ON FUNCTION "public"."base36_10_readable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."base36_10_readable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."base64url_encode"("input" "bytea") TO "anon";
GRANT ALL ON FUNCTION "public"."base64url_encode"("input" "bytea") TO "authenticated";
GRANT ALL ON FUNCTION "public"."base64url_encode"("input" "bytea") TO "service_role";



GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user_row_on_auth"() TO "service_role";



GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "anon";
GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."gen_codice_6"() TO "service_role";



GRANT ALL ON FUNCTION "public"."gen_url_token_256"() TO "anon";
GRANT ALL ON FUNCTION "public"."gen_url_token_256"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."gen_url_token_256"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_profile_picture_upload"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_profile_picture_upload"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_profile_picture_upload"() TO "service_role";



GRANT ALL ON FUNCTION "public"."openbadge_denormalize"() TO "anon";
GRANT ALL ON FUNCTION "public"."openbadge_denormalize"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."openbadge_denormalize"() TO "service_role";



GRANT ALL ON FUNCTION "public"."otp_burn"("p_id_otp" "uuid", "p_id_user" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."otp_burn"("p_id_otp" "uuid", "p_id_user" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."otp_burn"("p_id_otp" "uuid", "p_id_user" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."otp_create"("p_id_user" "uuid", "p_tag" "text", "p_ttl_seconds" integer, "p_length" integer, "p_numeric_only" boolean) TO "anon";
GRANT ALL ON FUNCTION "public"."otp_create"("p_id_user" "uuid", "p_tag" "text", "p_ttl_seconds" integer, "p_length" integer, "p_numeric_only" boolean) TO "authenticated";
GRANT ALL ON FUNCTION "public"."otp_create"("p_id_user" "uuid", "p_tag" "text", "p_ttl_seconds" integer, "p_length" integer, "p_numeric_only" boolean) TO "service_role";



GRANT ALL ON FUNCTION "public"."otp_gc"("p_before" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."otp_gc"("p_before" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."otp_gc"("p_before" timestamp with time zone) TO "service_role";



GRANT ALL ON FUNCTION "public"."otp_get_metadata"("p_id_otp" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."otp_get_metadata"("p_id_otp" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."otp_get_metadata"("p_id_otp" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."otp_list_user_otps"("p_id_user" "uuid", "p_limit" integer, "p_offset" integer) TO "anon";
GRANT ALL ON FUNCTION "public"."otp_list_user_otps"("p_id_user" "uuid", "p_limit" integer, "p_offset" integer) TO "authenticated";
GRANT ALL ON FUNCTION "public"."otp_list_user_otps"("p_id_user" "uuid", "p_limit" integer, "p_offset" integer) TO "service_role";



GRANT ALL ON FUNCTION "public"."otp_verify"("p_code" "text", "p_id_user" "uuid", "p_tag" "text", "p_mark_used" boolean, "p_used_by" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."otp_verify"("p_code" "text", "p_id_user" "uuid", "p_tag" "text", "p_mark_used" boolean, "p_used_by" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."otp_verify"("p_code" "text", "p_id_user" "uuid", "p_tag" "text", "p_mark_used" boolean, "p_used_by" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."refresh_user_profile_pictures"("p_base_url" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."set_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_user_profile_picture"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_user_profile_picture"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_user_profile_picture"() TO "service_role";



GRANT ALL ON TABLE "public"."certification" TO "anon";
GRANT ALL ON TABLE "public"."certification" TO "authenticated";
GRANT ALL ON TABLE "public"."certification" TO "service_role";



GRANT ALL ON TABLE "public"."certification_category" TO "anon";
GRANT ALL ON TABLE "public"."certification_category" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_category" TO "service_role";



GRANT ALL ON TABLE "public"."certification_category_has_information" TO "anon";
GRANT ALL ON TABLE "public"."certification_category_has_information" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_category_has_information" TO "service_role";



GRANT ALL ON TABLE "public"."certification_has_media" TO "anon";
GRANT ALL ON TABLE "public"."certification_has_media" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_has_media" TO "service_role";



GRANT ALL ON SEQUENCE "public"."certification_has_media_id_certification_has_media_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."certification_has_media_id_certification_has_media_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."certification_has_media_id_certification_has_media_seq" TO "service_role";



GRANT ALL ON TABLE "public"."certification_information" TO "anon";
GRANT ALL ON TABLE "public"."certification_information" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_information" TO "service_role";



GRANT ALL ON TABLE "public"."certification_information_value" TO "anon";
GRANT ALL ON TABLE "public"."certification_information_value" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_information_value" TO "service_role";



GRANT ALL ON SEQUENCE "public"."certification_information_val_id_certification_information__seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."certification_information_val_id_certification_information__seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."certification_information_val_id_certification_information__seq" TO "service_role";



GRANT ALL ON TABLE "public"."certification_media" TO "anon";
GRANT ALL ON TABLE "public"."certification_media" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_media" TO "service_role";



GRANT ALL ON TABLE "public"."certification_user" TO "anon";
GRANT ALL ON TABLE "public"."certification_user" TO "authenticated";
GRANT ALL ON TABLE "public"."certification_user" TO "service_role";



GRANT ALL ON TABLE "public"."certifier" TO "anon";
GRANT ALL ON TABLE "public"."certifier" TO "authenticated";
GRANT ALL ON TABLE "public"."certifier" TO "service_role";



GRANT ALL ON TABLE "public"."country" TO "anon";
GRANT ALL ON TABLE "public"."country" TO "authenticated";
GRANT ALL ON TABLE "public"."country" TO "service_role";



GRANT ALL ON TABLE "public"."cv" TO "anon";
GRANT ALL ON TABLE "public"."cv" TO "authenticated";
GRANT ALL ON TABLE "public"."cv" TO "service_role";



GRANT ALL ON TABLE "public"."debug_log" TO "anon";
GRANT ALL ON TABLE "public"."debug_log" TO "authenticated";
GRANT ALL ON TABLE "public"."debug_log" TO "service_role";



GRANT ALL ON TABLE "public"."kyc_attempt" TO "anon";
GRANT ALL ON TABLE "public"."kyc_attempt" TO "authenticated";
GRANT ALL ON TABLE "public"."kyc_attempt" TO "service_role";



GRANT ALL ON TABLE "public"."legal_entity" TO "anon";
GRANT ALL ON TABLE "public"."legal_entity" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_entity" TO "service_role";



GRANT ALL ON TABLE "public"."legal_entity_invitation" TO "anon";
GRANT ALL ON TABLE "public"."legal_entity_invitation" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_entity_invitation" TO "service_role";



GRANT ALL ON TABLE "public"."location" TO "anon";
GRANT ALL ON TABLE "public"."location" TO "authenticated";
GRANT ALL ON TABLE "public"."location" TO "service_role";



GRANT ALL ON TABLE "public"."openbadge" TO "anon";
GRANT ALL ON TABLE "public"."openbadge" TO "authenticated";
GRANT ALL ON TABLE "public"."openbadge" TO "service_role";



GRANT ALL ON TABLE "public"."otp" TO "anon";
GRANT ALL ON TABLE "public"."otp" TO "authenticated";
GRANT ALL ON TABLE "public"."otp" TO "service_role";



GRANT ALL ON TABLE "public"."user" TO "anon";
GRANT ALL ON TABLE "public"."user" TO "authenticated";
GRANT ALL ON TABLE "public"."user" TO "service_role";



GRANT ALL ON TABLE "public"."wallet" TO "anon";
GRANT ALL ON TABLE "public"."wallet" TO "authenticated";
GRANT ALL ON TABLE "public"."wallet" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";






RESET ALL;
