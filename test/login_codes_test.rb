require 'test_helper'

class LoginCodesTest < ChatsTest
  def test_login_codes
    # Test no phone
    post '/login_codes'
    assert_return [400, '{"message":"Phone is required."}']

    # Test empty phone
    post '/login_codes', {phone: ''}
    assert_return [400, '{"message":"Phone is required."}']

    # Test invalid phone
    post '/login_codes', {phone: '1234567890'}
    assert_return [400, '{"message":"Phone is invalid."}']

    # Test unregistered phone
    post '/login_codes', {phone: '2345678901'}
    assert_return [403, '{"message":"No Chats account exists with that phone number."}']

    # Test registered phone, success sending text
    Chats::TextBelt.mock({'success' => true}) do
      post '/login_codes', {phone: @phone}
    end
    assert_return [200, '']
    assert_match /\A[1-9]\d{3}\z/, get_code('login', @phone)

    # Test registered phone update, error sending text
    Chats::TextBelt.mock({'success' => false, 'message' => "Error!"}) do
      post '/login_codes', {phone: @phone}
    end
    assert_return [500, '{"message":"Error!"}']
    assert_match /\A[1-9]\d{3}\z/, get_code('login', @phone)
  end
end
