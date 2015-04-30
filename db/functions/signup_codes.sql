\c chats

-- Enter phone. Create code.
CREATE FUNCTION signup_codes_post(char(10)) RETURNS SETOF int AS
$$
    WITH p AS (
        -- Check if user with phone already exists
        SELECT 1
        FROM users
        WHERE phone = $1
    ), u AS (
        UPDATE signup_codes c
        SET code = DEFAULT, created_at = DEFAULT
        WHERE NOT EXISTS (SELECT 1 FROM p)
        AND phone = $1
        RETURNING code
    ), i AS (
        INSERT INTO signup_codes
        SELECT $1
        WHERE NOT EXISTS (SELECT 1 FROM p)
        AND NOT EXISTS (SELECT 1 FROM u)
        RETURNING code
    )
    SELECT code FROM u UNION ALL SELECT code FROM i;
$$
LANGUAGE SQL;
