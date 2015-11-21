#!/bin/sh

# Create a Self-Signed SSL Certificate
openssl genrsa -aes256 -passout pass:x -out server.pass.key 2048
openssl rsa -passin pass:x -in server.pass.key -out server.key
rm server.pass.key
openssl req -new -sha256 -key server.key -out server.csr -subj /CN=localhost
openssl x509 -req -sha512 -days 365 -in server.csr -signkey server.key -out server.crt
