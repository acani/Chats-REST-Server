# Chats-Server-REST

A REST server for [Chats][1]

## Passwordless Authentication

![Signup/Login Flow][2]

## Technology

* [Rack][3]: a [Ruby][4] web server
* [PostgreSQL][5] stores user data
* [Amazon S3][6] stores user pictures
* [TextBelt][7] sends SMS texts

## Instructions

To install & test locally:

1. Install & update Homebrew
2. `brew install postgresql`
3. `brew install ruby`
4. `gem install foreman`
3. All from the project's `Server` directory:
    * `bundle install`
    * Start PostgreSQL: `postgres -D /usr/local/var/postgres`
    * In a new tab: `rake psql`
    * Switch back to tab 1
    * Kill PostgreSQL (Command-.)
    * `cp .env.example .env`
    * `foreman start`
    * Switch back to tab 2
    * `rake test`

This project is released under the [Unlicense][8].


  [1]: https://github.com/acani/Chats
  [2]: doc/signup_login_flow/signup_login_flow.jpg
  [3]: http://rack.github.io
  [4]: https://www.ruby-lang.org
  [5]: http://www.postgresql.org
  [6]: http://aws.amazon.com/s3/
  [7]: http://textbelt.com
  [8]: http://unlicense.org
