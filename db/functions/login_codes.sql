\c chats

-- Enter phone. Create code.
CREATE FUNCTION login_codes_post(char(10)) RETURNS SETOF int AS
$$
    WITH p AS (
        -- Confirm that user with phone exists
        SELECT 1
        FROM users
        WHERE phone = $1
    ), u AS (
        UPDATE login_codes c
        SET code = DEFAULT, created_at = DEFAULT
        WHERE EXISTS (SELECT 1 FROM p)
        AND phone = $1
        RETURNING code
    ), i AS (
        INSERT INTO login_codes
        SELECT $1
        WHERE EXISTS (SELECT 1 FROM p)
        AND NOT EXISTS (SELECT 1 FROM u)
        RETURNING code
    )
    SELECT code FROM u UNION ALL SELECT code FROM i;
$$
LANGUAGE SQL;
