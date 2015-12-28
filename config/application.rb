require 'connection_pool'
require 'json'
require 'pg'
require 'rack'
require 'rack/protection'

uri = URI.parse(ENV['DATABASE_URL'])
$pg = ConnectionPool.new { PG.connect(uri.host, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password) }

require './config/handler'
require './config/routes'

# require './app/controllers/cors_controller'
require './app/controllers/email_controller'
require './app/controllers/login_controller'
require './app/controllers/me_controller'
require './app/controllers/sessions_controller'
require './app/controllers/signup_controller'
require './app/controllers/users_controller'

require './app/helpers/authorization'
require './app/helpers/mailgun'
# require './app/helpers/text_belt'
require './app/helpers/validation'
