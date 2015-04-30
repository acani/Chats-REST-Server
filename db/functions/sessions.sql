\c chats

-- Log in: Get or create session ID with `phone` & `code`
-- Reuse one session per user across multiple devices.
-- Responses:
--     Success: 1 row with uuid
--     0 Rows:  Incorrect or Expired Code
CREATE FUNCTION sessions_post(char(10), int) RETURNS SETOF uuid AS
$$
    WITH d AS (
        -- Verify code and then delete
        DELETE FROM login_codes
        WHERE phone = $1
        AND code = $2
        RETURNING created_at
    ), p AS (
        -- Get user ID from phone
        SELECT id
        FROM users
        WHERE EXISTS (SELECT 1 FROM d)
        AND phone = $1
    ), g AS (
        -- Get session ID
        SELECT s.id
        FROM sessions s, p
        WHERE EXISTS (SELECT 1 FROM d)
        AND s.user_id = p.id
    ), i AS (
        -- Create session ID if one doesn't exist
        INSERT INTO sessions
        SELECT id
        FROM p, d
        WHERE NOT EXISTS (SELECT 1 FROM g)
        AND age(now(), d.created_at) < '3 minutes'
        RETURNING id
    )
    SELECT id FROM g UNION ALL SELECT id FROM i;
$$
LANGUAGE SQL;

-- Log out: Delete session ID with `user_id` & `session_id`
CREATE FUNCTION logout(bigint, uuid) RETURNS SETOF boolean AS
$$
    DELETE FROM sessions
    WHERE user_id = $1
    AND id = $2
    RETURNING TRUE;
$$
LANGUAGE SQL;
