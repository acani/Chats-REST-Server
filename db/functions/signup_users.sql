\c chats

-- Sign up: Create user & session ID with phone & code
-- Responses:
--     Success: 1 row with user ID & session ID
--     0 Rows:  Code may be incorrect or expired
CREATE FUNCTION signup_users_post(varchar(15), int) RETURNS SETOF char(32) AS
$$
    WITH d AS (
        -- Delete matching phone & code
        DELETE FROM signup_codes
        WHERE phone = $1
        AND code = $2
        RETURNING created_at
    ), t AS (
        -- Confirm that code is still fresh
        SELECT 1
        FROM d
        WHERE age(now(), d.created_at) < '3 minutes'
    ) u AS (
        -- Update key if signup_user exists
        UPDATE signup_users
        SET key = DEFAULT
        WHERE EXISTS (SELECT 1 FROM t)
        AND phone = $1
        RETURNING strip_hyphens(key) as k
    ), i AS (
        -- Else, create signup_user with phone
        INSERT INTO signup_users
        SELECT $1
        FROM t
        WHERE NOT EXISTS (SELECT 1 FROM u)
        RETURNING strip_hyphens(key) as k
    )
    SELECT k FROM u UNION ALL SELECT k FROM i;
$$
LANGUAGE SQL;
