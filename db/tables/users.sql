\c chats

CREATE TABLE users (
    id bigserial PRIMARY KEY,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    picture_id char(32),
    first_name varchar(75) NOT NULL CHECK (first_name <> ''),
    last_name varchar(75) NOT NULL CHECK (last_name <> ''),
    phone varchar(15) NOT NULL UNIQUE
);
