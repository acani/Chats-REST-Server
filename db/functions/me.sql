\c chats

-- Delete user with `user_id` & `session_id`
CREATE FUNCTION me_delete(bigint, uuid) RETURNS SETOF boolean AS
$$
    DELETE FROM users u
    USING sessions s
    WHERE u.id = s.user_id
    AND u.id = $1
    AND s.id = $2
    RETURNING TRUE;
$$
LANGUAGE SQL;
