-- Funzione SQL per cercare utenti
CREATE OR REPLACE FUNCTION search_users(search_term TEXT, limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    id_user UUID,
    email TEXT,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        u.id_user,
        u.email,
        u.first_name,
        u.last_name,
        u.phone,
        u.address,
        u.city,
        u.created_at,
        u.updated_at
    FROM "user" u
    WHERE 
        (u.first_name ILIKE '%' || search_term || '%' OR
         u.last_name ILIKE '%' || search_term || '%' OR
         u.email ILIKE '%' || search_term || '%' OR
         u.phone ILIKE '%' || search_term || '%' OR
         u.id_user::text ILIKE '%' || search_term || '%')
    ORDER BY 
        CASE 
            WHEN u.email ILIKE search_term || '%' THEN 1
            WHEN u.first_name ILIKE search_term || '%' THEN 2
            WHEN u.last_name ILIKE search_term || '%' THEN 3
            ELSE 4
        END,
        u.created_at DESC
    LIMIT limit_count;
END;
$$;
