# Chats-Server-REST

A REST server for [Chats][1]

## Instructions

To install & test locally:

1. Install & update Homebrew
2. `brew install postgresql`
3. `brew install ruby`
4. `gem install rerun foreman`
3. All from the project's root directory:
    * `bundle install`
    * Start PostgreSQL
    * In a new tab: `rake psql`
    * Switch back to tab 1
    * Kill PostgreSQL
    * `echo DATABASE_URL=postgres://localhost/chats > .env`
    * `rerun foreman start`
    * Switch back to tab 2
    * `rake test`


  [1]: https://github.com/acani/Chats
