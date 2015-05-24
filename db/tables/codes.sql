\c chats

CREATE TABLE codes (
    phone char(10) PRIMARY KEY,
    code int NOT NULL DEFAULT trunc(random()*8999)+1000, -- 1000..9999
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
