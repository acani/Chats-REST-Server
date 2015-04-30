require 'test_helper'

class UsersTest < ChatsTest
  def test_post_and_get_users
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

    # # Test good phone
    # post '/users', {phone: '2025550179'}
    # assert_return [201, /\A\{"id":2,"access_token":"2\|[0-9a-f]{32}"\}\z/]
    #
    # # Confirm previous user creation
    # get '/users'
    # assert_return '[1,2]'
  end
end
