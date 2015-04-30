# require 'test_helper'
#
# class MeTest < ChatsTest
#   def test_get_me
#     authorize_client do
#       post '/users', {phone: 'user2@gmail.com'}
#       post '/users', {phone: 'user3@gmail.com'}
#     end
#
#     authorize_user(@access_token) do
#        get '/me'
#        assert_return [200, '{"id":1}']
#
#        message_create(from: 2, to: 1, body: '2 -> 1')
#        2.times { message_create(from: 3, to: 1, body: '3 -> 1') }
#        message_create(from: 2, to: 3, body: '2 -> 3')
#        message_create(from: 3, to: 2, body: '3 -> 2')
#
#        get '/me'
#        assert_return [200, '{"id":1,"chats":3}']
#
#        get '/messages/2'
#        get '/me'
#        assert_return [200, '{"id":1,"chats":2}']
#
#        get '/messages/3'
#        get '/me'
#        assert_return [200, '{"id":1}']
#     end
#   end
#
#   def test_put_me
#     # Create another user
#     authorize_client { post '/users', {phone: 'user2@gmail.com'} }
#
#     # Test invalid `access_token`
#     authorize_user('invalid-access_token') { put '/me', {phone: 'user3@gmail.com'} }
#     assert_return 404
#
#     # Test incorrect `access_token`
#     authorize_user('123456789012345678901234567890123') { put '/me', {phone: 'user3@gmail.com'} }
#     assert_return 401
#
#     authorize_user(@access_token) do
#       # Test empty phone
#       put '/me', {phone: ''}
#       assert_return [400, '{"message":"phone is required."}']
#
#       # Test long phone
#       put '/me', {phone: 'phone-255.characters@123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234'}
#       assert_return [400, '{"message":"phone exceeds 254 characters."}']
#
#       # Test invalid phone
#       put '/me', {phone: 'no-at-sign'}
#       assert_return [400, '{"message":"phone is invalid."}']
#
#       # Test taken phone (case-insensitive)
#       put '/me', {phone: 'uSeR2@gmail.com'}
#       assert_return [409, '{"message":"phone is taken."}']
#
#       # Test same phone
#       put '/me', {phone: 'user1@gmail.com'}
#       assert_return 204
#
#       # Test different phone
#       put '/me', {phone: 'user3@gmail.com'}
#       assert_return 204
#     end
#
#     # Confirm phone-change
#     authorize_client { Chats::TextBelt.mock { post '/signup_codes', {phone: 'user3@gmail.com'} } }
#     assert_return [200, '{"id":1}']
#   end
#
#   def test_delete_me
#     # Test no access token
#     delete '/me'
#     assert_return 404
#
#     # Test user not found
#     authorize_user('123456789012345678901234567890122') { delete '/me' }
#     assert_return 401
#
#     # Test unauthorized
#     authorize_user('123456789012345678901234567890121') { delete '/me' }
#     assert_return 401
#
#     # Test successful delete
#     authorize_user(@access_token) { delete '/me' }
#     assert_return 200
#     authorize_client { get '/users' }
#     assert_return [200, '[]']
#   end
# end
