require 'test_helper'

class UsersTest < ChatsTest
  def test_users_get
    get '/users'
    assert_return '[1]'
  end

  def test_users_post
    # Create signup code
    phone = '2345678901'
    Chats::TextBelt.mock({'success' => true}) do
      post '/signup_codes', {phone: phone}
    end
    code = get_code('signup', phone)

    # Test no code
    post '/users'
    assert_return [400, '{"message":"Code is required."}']

    # Test empty code
    post '/users', {code: ''}
    assert_return [400, '{"message":"Code is required."}']

    # Test invalid code
    post '/users', {code: '123456'}
    assert_return [400, '{"message":"Code is invalid."}']

    # Test no phone
    post '/users', {code: '1234'}
    assert_return [400, '{"message":"Phone is required."}']

    # Test empty phone
    post '/users', {phone: '', code: '1234'}
    assert_return [400, '{"message":"Phone is required."}']

    # Test invalid phone
    post '/users', {phone: '1234567890', code: '1234'}
    assert_return [400, '{"message":"Phone is invalid."}']

    # Test incorrect code
    incorrect_code = (code == '1234' ? '1235' : '1234')
    post '/users', {phone: phone, code: incorrect_code}
    assert_return [403, '{"message":"Code is incorrect or expired."}']

    # Test incorrect phone
    post '/users', {phone: '2345678902', code: code}
    assert_return [403, '{"message":"Code is incorrect or expired."}']

    # Test correct phone & code
    post '/users', {phone: phone, code: code}
    assert_return [201, /\A\{"access_token":"2\|[0-9a-f]{32}"\}\z/]

    # Confirm previous user creation
    get '/users'
    assert_return '[1,2]'

    # Test that code only works once
    post '/users', {phone: @phone, code: code}
    assert_return [403, '{"message":"Code is incorrect or expired."}']
  end
end
