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

    # Test good phone (case-insensitive)
    assert Chats::TextBelt.respond_to?(:send)
    Chats::TextBelt.mock({'success' => true}) do
      post '/signup_codes', {phone: '3525700299'}
    end
    assert_return [200, '']

    # Get signup code
    code = code(user_id: 1)
    assert 0 < code && code < 1000000

    # # Test invalid user_id
    # post "/sessions/e/#{code}"
    # assert_return [401, '{"message":"Incorrect or expired code."}']
    #
    # # Test incorrect user_id
    # post "/sessions/2/#{code}"
    # assert_return [401, '{"message":"Incorrect or expired code."}']
    #
    # # Test invalid code
    # post "/sessions/1/d"
    # assert_return [401, '{"message":"Incorrect or expired code."}']
    #
    # # Test incorrect code
    # post "/sessions/1/#{code == 1 ? code + 1 : code - 1}"
    # assert_return [401, '{"message":"Incorrect or expired code."}']
    #
    # # Test correct user_id & code
    # post "/sessions/1/#{code}"
    # assert_return [200, /\A\{"access_token":"#{@access_token}"\}\z/]
    #
    # # Test logout
    # authorize_user(@access_token) do
    #   delete '/sessions'
    #   assert_return 200
    #   get '/chats'
    #   assert_return 401
    # end
    #
    # # Test login
    # assert Chats::TextBelt.respond_to?(:send)
    # Chats::TextBelt.mock { post '/signup_codes', {phone: 'user1@gmail.com'} }
    # assert_return [200, '{"id":1}']
    #
    # post "/sessions/1/#{code(user_id: 1)}"
    # assert_return [200, /\A\{"access_token":"[0-9a-f]{32}1"\}\z/]
    #
    # access_token = JSON.parse(last_response.body)['access_token']
    # refute_equal @access_token, access_token
    #
    # # Confirm that we're logged in
    # authorize_user(access_token) do
    #   get '/chats'
    #   assert_return '[]'
    # end
  end

  private

  def code(phone)
    Chats::POSTGRES.exec_params("SELECT code FROM signup_codes WHERE phone = #{phone}") do |r|
      r.getvalue(0, 0).to_i
    end
  end
end
