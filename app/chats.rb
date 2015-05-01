require 'json'
require 'pg'
require 'rack/protection'

class Chats
  uri = URI.parse(ENV['POSTGRES_URL'])
  POSTGRES = PG.connect(uri.host, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
end

require_relative 'chats/authorization'
require_relative 'chats/login_codes'
require_relative 'chats/routes'
require_relative 'chats/sessions'
require_relative 'chats/signup_codes'
require_relative 'chats/text_belt'
require_relative 'chats/users'
require_relative 'chats/validation'
