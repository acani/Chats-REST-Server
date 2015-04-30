require 'test_helper'

class SignupCodesTest < ChatsTest
  def test_signup_codes
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
    post '/signup_codes', {phone: '3525700299'}
    assert_return [403, '{"message":"A Chats account with that phone number already exists."}']

    # Test good phone
    phone = '2345678901'
    Chats::TextBelt.mock({'success' => true}) do
      post '/signup_codes', {phone: phone}
    end
    assert_return [200, '']
    assert_match /\A[1-9]\d{3}\z/, get_code('signup', phone)
  end
end
