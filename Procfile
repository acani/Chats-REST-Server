postgres: postgres -D /usr/local/var/postgres
web: bundle exec env POSTGRES_URL=postgres://localhost/chats rackup config.ru -p $PORT
