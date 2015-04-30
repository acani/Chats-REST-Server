# require 'test_helper'
#
# class SessionsTest < ChatsTest
#   def test_sessions
#     # Test client unauthorized
#     post '/signup_codes', {phone: 'user1@gmail.com'}
#     assert_return 404
#
#     authorize_client do
#       # Test empty phone
#       post '/signup_codes', {phone: ''}
#       assert_return [404, '{"message":"No user exists with that phone."}']
#
#       # Test long phone
#       post '/signup_codes', {phone: 'phone-255.characters@123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234'}
#       assert_return [404, '{"message":"No user exists with that phone."}']
#
#       # Test invalid phone
#       post '/signup_codes', {phone: 'no-at-sign'}
#       assert_return [404, '{"message":"No user exists with that phone."}']
#
#       # Test nonexistent phone
#       post '/signup_codes', {phone: 'user2@gmail.com'}
#       assert_return [404, '{"message":"No user exists with that phone."}']
#
#       # Test good phone (case-insensitive)
#       assert Chats::TextBelt.respond_to?(:send)
#       Chats::TextBelt.mock { post '/signup_codes', {phone: 'uSeR1@gmail.com'} }
#       assert_return [200, '{"id":1}']
#     end
#
#     # Get log-in code
#     code = code(user_id: 1)
#     assert 0 < code && code < 1000000
#
#     # Test client unauthorized
#     post "/sessions/1/#{code}"
#     assert_return 404
#
#     authorize_client do
#       # Test invalid user_id
#       post "/sessions/e/#{code}"
#       assert_return [401, '{"message":"Incorrect or expired code."}']
#
#       # Test incorrect user_id
#       post "/sessions/2/#{code}"
#       assert_return [401, '{"message":"Incorrect or expired code."}']
#
#       # Test invalid code
#       post "/sessions/1/d"
#       assert_return [401, '{"message":"Incorrect or expired code."}']
#
#       # Test incorrect code
#       post "/sessions/1/#{code == 1 ? code + 1 : code - 1}"
#       assert_return [401, '{"message":"Incorrect or expired code."}']
#
#       # Test correct user_id & code
#       post "/sessions/1/#{code}"
#       assert_return [200, /\A\{"access_token":"#{@access_token}"\}\z/]
#     end
#
#     # Test logout
#     authorize_user(@access_token) do
#       delete '/sessions'
#       assert_return 200
#       get '/chats'
#       assert_return 401
#     end
#
#     # Test login
#     authorize_client do
#       assert Chats::TextBelt.respond_to?(:send)
#       Chats::TextBelt.mock { post '/signup_codes', {phone: 'user1@gmail.com'} }
#       assert_return [200, '{"id":1}']
#     end
#     authorize_client do
#       post "/sessions/1/#{code(user_id: 1)}"
#       assert_return [200, /\A\{"access_token":"[0-9a-f]{32}1"\}\z/]
#     end
#     access_token = JSON.parse(last_response.body)['access_token']
#     refute_equal @access_token, access_token
#
#     # Confirm that we're logged in
#     authorize_user(access_token) do
#       get '/chats'
#       assert_return '[]'
#     end
#   end
#
#   private
#
#   def code(user_id:)
#     Chats::POSTGRES.exec_params("SELECT id FROM codes WHERE user_id = #{user_id}") do |r|
#       r.getvalue(0, 0).to_i
#     end
#   end
# end
