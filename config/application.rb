require 'aws-sdk'
require 'json'
require 'pg'
require 'rack/protection'
require 'securerandom'

class Chats
  uri = URI.parse(ENV['DATABASE_URL'])
  POSTGRES = PG.connect(uri.host, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
  AWS_S3_BUCKET = Aws::S3::Resource.new.bucket('acani-chats')
end

require './config/routes'

require './app/controllers/login_codes_controller'
require './app/controllers/me_controller'
require './app/controllers/sessions_controller'
require './app/controllers/signup_codes_controller'
require './app/controllers/users_controller'

require './app/helpers/authorization'
require './app/helpers/text_belt'
require './app/helpers/validation'
