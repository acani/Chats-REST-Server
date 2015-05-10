\c chats

-- Get all users
CREATE FUNCTION users_get() RETURNS TABLE(u bigint, p char(32), f varchar(75), l varchar(75)) AS
$$
    SELECT id, strip_hyphens(picture_id), first_name, last_name
    FROM users
    LIMIT 20;
$$
LANGUAGE SQL STABLE;

-- Sign up: Create user & session ID with `phone` & `code`
-- Responses:
--     Success: 1 row with user ID & session ID
--     0 Rows:  Code may be incorrect or expired
CREATE FUNCTION users_post(char(10), int) RETURNS TABLE(u bigint, s char(32)) AS
$$
    WITH d AS (
        -- Verify code and then delete
        DELETE FROM codes
        WHERE phone = $1
        AND code = $2
        RETURNING created_at
    ), u AS (
        -- Create user with phone
        INSERT INTO users (phone)
        SELECT $1
        FROM d
        WHERE age(now(), d.created_at) < '3 minutes'
        RETURNING id
    )
    -- Create session
    INSERT INTO sessions SELECT id FROM u
    RETURNING user_id, strip_hyphens(id);
$$
LANGUAGE SQL;
