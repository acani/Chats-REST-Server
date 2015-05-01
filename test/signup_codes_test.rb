require 'test_helper'

class SignupCodesTest < ChatsTest
  def test_signup_codes_post
    # Test no phone
    post '/signup_codes'
    assert_return [400, '{"message":"Phone is required."}']

    # Test empty phone
    post '/signup_codes', {phone: ''}
    assert_return [400, '{"message":"Phone is required."}']

    # Test invalid phone
    post '/signup_codes', {phone: '1234567890'}
    assert_return [400, '{"message":"Phone is invalid."}']

    # Test registered phone
    post '/signup_codes', {phone: @phone}
    assert_return [403, '{"message":"A Chats account already exists with that phone number."}']

    # Test unregistered phone, success sending text
    phone = '2345678901'
    Chats::TextBelt.mock({'success' => true}) do
      post '/signup_codes', {phone: phone}
    end
    assert_return [200, '']
    assert_match /\A[1-9]\d{3}\z/, get_code('signup', phone)

    # Test unregistered phone update, error sending text
    Chats::TextBelt.mock({'success' => false, 'message' => "Error!"}) do
      post '/signup_codes', {phone: phone}
    end
    assert_return [500, '{"message":"Error!"}']
    assert_match /\A[1-9]\d{3}\z/, get_code('signup', phone)
  end
end
