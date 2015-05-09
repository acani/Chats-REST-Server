\c chats

-- Get user with `user_id` & `session_id`
CREATE FUNCTION me_get(bigint, uuid) RETURNS TABLE(u bigint, p char(32), f varchar(75), l varchar(75), m varchar(15)) AS
$$
    SELECT u.id, picture_id, first_name, last_name, phone
    FROM users u, sessions s
    WHERE u.id = $1
    AND s.user_id = u.id
    AND s.id = $2;
$$
LANGUAGE SQL;

-- Patch user with `user_id` & `session_id`
-- Returns TRUE if authorized
CREATE FUNCTION me_patch(bigint, uuid, char(32), varchar(75), varchar(75)) RETURNS SETOF boolean AS
$$
    WITH s AS (
        SELECT 1
        FROM sessions
        WHERE user_id = $1
        AND id = $2
    ), u AS (
        UPDATE users
        SET
            picture_id = COALESCE($3, picture_id),
            first_name = COALESCE($4, first_name),
            last_name = COALESCE($5, last_name)
        WHERE EXISTS (SELECT 1 FROM s)
        AND id = $1
        -- Avoid an empty UPDATE
        -- http://stackoverflow.com/questions/13305878/dont-update-column-if-update-value-is-null
        AND ($3 IS NOT NULL AND $3 IS DISTINCT FROM picture_id OR
             $4 IS NOT NULL AND $4 IS DISTINCT FROM first_name OR
             $5 IS NOT NULL AND $5 IS DISTINCT FROM last_name)
        RETURNING 1
    )
    SELECT TRUE WHERE EXISTS (SELECT 1 FROM s)
$$
LANGUAGE SQL;

-- -- Change email with `user_id`, `session_id`, and `email`
-- CREATE FUNCTION email_set(bigint, uuid, text) RETURNS SETOF boolean AS
-- $$
--     WITH s AS (
--         SELECT 1
--         FROM sessions
--         WHERE user_id = $1
--         AND id = $2
--     ), u AS (
--         UPDATE users
--         SET email = $3
--         WHERE EXISTS (SELECT 1 FROM s)
--         AND id = $1
--         AND NOT EXISTS (SELECT 1 FROM users WHERE lower(email) = lower($3) AND id != $1)
--         RETURNING 1
--     )
--     SELECT EXISTS (SELECT 1 FROM u) WHERE EXISTS (SELECT 1 FROM s)
-- $$
-- LANGUAGE SQL;

-- Delete user with `user_id` & `session_id`
CREATE FUNCTION me_delete(bigint, uuid) RETURNS SETOF boolean AS
$$
    DELETE FROM users u
    USING sessions s
    WHERE u.id = $1
    AND s.user_id = u.id
    AND s.id = $2
    RETURNING TRUE;
$$
LANGUAGE SQL;
