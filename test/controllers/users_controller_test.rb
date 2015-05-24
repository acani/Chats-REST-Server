require 'test_helper'

class UsersTest < ChatsTest
  def test_users_get
    get '/users'
    assert_return /\A\[\{"id":1,"name":\{"first":"Matt","last":"Di Pasquale"\},"picture_id":"[0-9a-f]{32}"\}\]\z/
  end

  def test_users_post
    # Create code
    phone = '2102390603'
    Chats::TextBelt.mock({'success' => true}) do
      post '/codes', {phone: phone}
    end
    code = get_code(phone)

    # Create key
    post '/keys', {phone: phone, code: code}
    key = get_key(phone)

    valid_params = {first_name: 'John', last_name: 'Appleseed'}
    unauthorized_response = [
      401,
      {'WWW-Authenticate' => 'Basic realm="Chats"'},
      '{"title":"Unauthorized","message":"Please reverify your phone and try again."}'
    ]

    # Test invalid access_token
    authorize_user('invalid-access_token') do
      post '/users'
      assert_return unauthorized_response
    end

    authorize_user(phone+'|'+key) do
      # Test no first_name
      post '/users'
      assert_return [400, '{"message":"First name is required."}']

      # Test empty first_name
      post '/users', {first_name: ''}
      assert_return [400, '{"message":"First name is required."}']

      # Test no last_name
      post '/users', {first_name: 'Matt'}
      assert_return [400, '{"message":"Last name is required."}']

      # Test empty last_name
      post '/users', {first_name: 'Matt', last_name: ''}
      assert_return [400, '{"message":"Last name is required."}']
    end

    # Test incorrect key
    authorize_user(phone+'|'+SecureRandom.hex) do
      post '/users', valid_params
      assert_return unauthorized_response
    end

    # Test incorrect phone
    authorize_user('2345678902|'+key) do
      post '/users', valid_params
      assert_return unauthorized_response
    end

    # Test correct phone & key
    authorize_user(phone+'|'+key) do
      post '/users', valid_params
      assert_return [201, /\A\{"access_token":"2\|[0-9a-f]{32}"\}\z/]
    end

    # Confirm previous user creation
    get '/users'
    assert_return /\A\[\{"id":1,"name":\{"first":"Matt","last":"Di Pasquale"\},"picture_id":"[0-9a-f]{32}"\},\{"id":2,"name":\{"first":"John","last":"Appleseed"\}\}\]\z/

    # Test that key only works once
    authorize_user(phone+'|'+key) do
      post '/users', valid_params
      assert_return unauthorized_response
    end
  end
end
