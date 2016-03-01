# Command below tests a specific test method
# RUBYLIB=test ruby test/users_test.rb --name test_post_users

ENV['RACK_ENV'] = 'test'
ENV['DATABASE_URL'] = 'postgres://localhost/acani_chats_test'

require 'minitest/autorun'
require 'rack/test'
require 'securerandom'
require './config/application'

class RESTTest < MiniTest::Test
  include Rack::Test::Methods

  TOO_LONG_NAME = '123456789.123456789.123456789.123456789.123456789.1'

  def app
    REST.new
  end

  def setup
    # Create a user
    @email = 'sally.davis@example.com'
    @access_token = create_user('Sally', 'Davis', @email)
  end

  def teardown
    $pg.with do |pg|
      pg.exec('BEGIN').clear
      delete_from_query = 'SELECT \'DELETE FROM "\' || tablename || \'";\' FROM pg_tables WHERE schemaname = \'public\''
      alter_sequence_query = 'SELECT \'ALTER SEQUENCE "\' || relname || \'" RESTART WITH 1;\' FROM pg_class WHERE relkind = \'S\''
      pg.exec(delete_from_query + ' UNION ' + alter_sequence_query) do |result|
        result.each_row { |t| pg.exec(t[0]).clear }
      end
      pg.exec('COMMIT').clear
    end
  end

  def authorize_user(access_token)
    header('Authorization', "Bearer #{access_token}")
    yield
    header 'Authorization', nil
  end

  def assert_return(return_value)
    status, headers, body = app.formulate_response(return_value)

    assert_equal status, last_response.status

    last_response.headers.delete('Content-Length')
    assert_equal headers, last_response.headers

    bodyString = body[0] || ''
    if String === bodyString
      assert_equal bodyString, last_response.body
    else # Regexp
      assert_match bodyString, last_response.body
    end
  end

  def create_user(first_name, last_name, email)
    $pg.with do |pg|
      pg.exec_params('INSERT INTO users (first_name, last_name, email) VALUES ($1, $2, $3) RETURNING id', [first_name, last_name, email]) do |r|
        user_id = r.getvalue(0, 0)
        pg.exec_params('INSERT INTO sessions VALUES ($1) RETURNING strip_hyphens(id)', [user_id]) do |r|
          user_id+'.'+r.getvalue(0, 0)
        end
      end
    end
  end

  def get_code(type, email)
    $pg.with do |pg|
      pg.exec_params("SELECT code FROM #{type} WHERE email = $1", [email]) do |r|
        r.getvalue(0, 0).rjust(4, '0')
      end
    end
  end

  def get_and_assert_code(type, email)
    code = get_code(type, email)
    assert_match /\A\d{4}\z/, code
    code
  end
end

require './test/helpers/mailgun'
# require './test/helpers/text_belt'
