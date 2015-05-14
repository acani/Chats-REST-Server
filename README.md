# Chats-Server-REST

A REST server for [Chats][1]

![Signup-Login Flow][2]

## Instructions

To install & test locally:

1. Install & update Homebrew
2. `brew install postgresql`
3. `brew install ruby`
4. `gem install foreman`
3. All from the project's `server` directory:
    * `bundle install`
    * Start PostgreSQL: `postgres -D /usr/local/var/postgres`
    * In a new tab: `rake psql`
    * Switch back to tab 1
    * Kill PostgreSQL (Command-.)
    * `cp .env.example .env`
    * `foreman start`
    * Switch back to tab 2
    * `rake test`


  [1]: https://github.com/acani/Chats
  [2]: https://github.com/acani/Chats-Server-REST/raw/master/Documentation/SignupLoginFlow/SignupLoginFlow.jpg
