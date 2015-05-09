# Command below tests a specific test method
# RUBYLIB=test ruby test/users_test.rb --name test_post_users

ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = 'postgres://localhost/chats'
ENV['AWS_REGION'] = 'region'
ENV['AWS_ACCESS_KEY_ID'] = 'AWS_ACCESS_KEY_ID'
ENV['AWS_SECRET_ACCESS_KEY'] = 'AWS_SECRET_ACCESS_KEY'

require 'minitest/autorun'
require 'rack/test'
require './config/application'

class ChatsTest < MiniTest::Test
  include Rack::Test::Methods

  APP = Rack::Builder.parse_file('config.ru')[0]
  def app
    APP
  end

  def setup
    # Create a user
    @phone = '3525700299'
    @access_token = create_user(SecureRandom.hex, 'Matt', 'Di Pasquale', @phone)
  end

  def teardown
    Chats::POSTGRES.exec('BEGIN').clear
    delete_from_query = 'SELECT \'DELETE FROM "\' || tablename || \'";\' FROM pg_tables WHERE schemaname = \'public\''
    alter_sequence_query = 'SELECT \'ALTER SEQUENCE "\' || relname || \'" RESTART WITH 1;\' FROM pg_class WHERE relkind = \'S\''
    Chats::POSTGRES.exec(delete_from_query + ' UNION ' + alter_sequence_query) do |result|
      result.each_row { |t| Chats::POSTGRES.exec(t[0]).clear }
    end
    Chats::POSTGRES.exec('COMMIT').clear
  end

  def authorize_user(access_token)
    header('Authorization', "Bearer #{access_token}")
    yield
    header 'Authorization', nil
  end

  def assert_return(return_value)
    status, headers, body = parse_return(return_value)
    assert_equal status, last_response.status
    assert_equal headers, last_response.headers
    if String === body
      assert_equal body, last_response.body
    else # Regexp
      assert_match body, last_response.body
    end
  end

  private

  def parse_return(return_value)
    status, headers, body = 200, {}, ''
    case return_value
    when Fixnum
      status = return_value
    when String, Regexp
      body = return_value
    else # Array
      if return_value.count == 2
        status, body = return_value
      else
        status, headers, body = return_value
      end
    end
    [status, headers_base.merge(headers), body]
  end

  def headers_base
    headers_base = {}
    content_length = last_response.headers['Content-Length']
    headers_base['Content-Length'] = content_length if content_length
    if last_response.headers.include?('Content-Type')
      headers_base['Content-Type'] = 'application/json'
    end
    headers_base
  end

  def create_user(picture_id, first_name, last_name, phone)
    Chats::POSTGRES.exec('INSERT INTO users (picture_id, first_name, last_name, phone) VALUES ($1, $2, $3, $4) RETURNING id', [picture_id, first_name, last_name, phone]) do |r|
      user_id = r.getvalue(0, 0)
      Chats::POSTGRES.exec('INSERT INTO sessions VALUES ($1) RETURNING strip_hyphens(id)', [user_id]) do |r|
        user_id+'|'+r.getvalue(0, 0)
      end
    end
  end

  def get_code(type, phone)
    Chats::POSTGRES.exec_params("SELECT code FROM #{type}_codes WHERE phone = '#{phone}'") do |r|
      r.getvalue(0, 0)
    end
  end
end

require './test/helpers/text_belt_mock'
