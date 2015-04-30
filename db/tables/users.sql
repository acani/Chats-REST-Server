\c chats

CREATE TABLE users (
    id bigserial PRIMARY KEY,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    phone char(10) NOT NULL UNIQUE, -- U.S. only
    first_name varchar(75),
    last_name varchar(75)
);
CREATE UNIQUE INDEX on users (phone);
