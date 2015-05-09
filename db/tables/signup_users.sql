\c chats

CREATE TABLE signup_users (
    phone varchar(15) PRIMARY KEY,
    key uuid NOT NULL DEFAULT uuid_generate_v4()
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
