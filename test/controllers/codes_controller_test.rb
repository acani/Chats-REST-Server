require 'test_helper'

class CodesTest < ChatsTest
  def test_codes_post
    # Test no phone
    post '/codes'
    assert_return [400, '{"message":"Phone is required."}']

    # Test empty phone
    post '/codes', {phone: ''}
    assert_return [400, '{"message":"Phone is required."}']

    # Test invalid phone
    post '/codes', {phone: '1234567890'}
    assert_return [400, '{"message":"Phone is invalid."}']

    # # Test unregistered phone
    # post '/codes', {phone: '2345678901'}
    # assert_return [403, '{"message":"No Chats account exists with that phone number."}']

    # Test registered phone, success sending text
    Chats::TextBelt.mock({'success' => true}) do
      post '/codes', {phone: @phone}
    end
    assert_return [200, '']
    code = Integer(get_code(@phone))
    assert code.between?(1000, 9999)

    # Test registered phone update, error sending text
    Chats::TextBelt.mock({'success' => false, 'message' => "Error!"}) do
      post '/codes', {phone: @phone}
    end
    assert_return [500, '{"message":"Error!"}']
    code_new = Integer(get_code(@phone))
    assert code_new.between?(1000, 9999)
    assert code != code_new
  end
end
