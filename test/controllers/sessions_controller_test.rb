require 'test_helper'

class SessionsTest < ChatsTest
  def test_sessions_post
    # Create login code
    Chats::TextBelt.mock({'success' => true}) do
      post '/codes', {phone: @phone}
    end
    code = get_code(@phone)

    # Test no code
    post '/sessions'
    assert_return [400, '{"message":"Code is required."}']

    # Test empty code
    post '/sessions', {code: ''}
    assert_return [400, '{"message":"Code is required."}']

    # Test invalid code
    post '/sessions', {code: '123456'}
    assert_return [400, '{"message":"Code is invalid."}']

    # Test no phone
    post '/sessions', {code: '1234'}
    assert_return [400, '{"message":"Phone is required."}']

    # Test empty phone
    post '/sessions', {phone: '', code: '1234'}
    assert_return [400, '{"message":"Phone is required."}']

    # Test invalid phone
    post '/sessions', {phone: '1234567890', code: '1234'}
    assert_return [400, '{"message":"Phone is invalid."}']

    # Test incorrect code
    incorrect_code = (code == '1234' ? '1235' : '1234')
    post '/sessions', {phone: @phone, code: incorrect_code}
    assert_return [403, '{"message":"Code is incorrect or expired."}']

    # Test incorrect phone
    post '/sessions', {phone: '2345678902', code: code}
    assert_return [403, '{"message":"Code is incorrect or expired."}']

    # Test correct phone & code
    post '/sessions', {phone: @phone, code: code}
    assert_return [201, /\A\{"access_token":"1\|[0-9a-f]{32}"\}\z/]

    # Test that code only works once
    post '/sessions', {phone: @phone, code: code}
    assert_return [403, '{"message":"Code is incorrect or expired."}']
  end
end
