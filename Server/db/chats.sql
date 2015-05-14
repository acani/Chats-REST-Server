-- Run this script with the command:
-- rake psql

DROP DATABASE IF EXISTS chats;
CREATE DATABASE chats;

\c chats

CREATE EXTENSION "uuid-ossp";
