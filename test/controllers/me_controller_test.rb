require 'test_helper'

class MeControllerTest < RESTTest
  def test_me_get
    # Test invalid access_token
    authorize_user('invalid-access_token') do
      get '/me'
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end

    # Test incorrect access_token
    authorize_user('1.0123456789abcdef0123456789abcdef') do
      get '/me'
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end

    # Test correct access_token
    authorize_user(@access_token) do
       get '/me'
       assert_return /\A\{"id":"1","name":\{"first":"Sally","last":"Davis"\},"email":"sally.davis@example.com"\}\z/
    end
  end

  def test_patch_me
    # Test invalid access_token
    authorize_user('invalid-access_token') do
      patch '/me', {first_name: 'Sal', last_name: 'D'}
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end

    # Test incorrect access_token
    authorize_user('1.0123456789abcdef0123456789abcdef') do
      patch '/me', {first_name: 'Sal', last_name: 'D'}
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end

    authorize_user(@access_token) do
      # Test invalid names
      patch '/me'
      assert_return REST::ME_NO_CHANGES_RESPONSE
      patch '/me', {first_name: ''}
      assert_return REST::FIRST_NAME_INVALID_RESPONSE
      patch '/me', {last_name: ''}
      assert_return REST::LAST_NAME_INVALID_RESPONSE
      patch '/me', {first_name: TOO_LONG_NAME}
      assert_return REST::FIRST_NAME_INVALID_RESPONSE
      patch '/me', {last_name: TOO_LONG_NAME}
      assert_return REST::LAST_NAME_INVALID_RESPONSE

      # Test first_name only
      patch '/me', {first_name: 'Sal'}
      assert_return 200
      get '/me'
      assert_equal({'first' => 'Sal', 'last' => 'Davis'}, JSON.parse(last_response.body)['name'])

      # Test last_name only
      patch '/me', {last_name: 'D'}
      assert_return 200
      get '/me'
      assert_equal({'first' => 'Sal', 'last' => 'D'}, JSON.parse(last_response.body)['name'])

      # Test both names
      patch '/me', {first_name: 'Sally', last_name: 'Davis'}
      assert_return 200
      get '/me'
      assert_equal({'first' => 'Sally', 'last' => 'Davis'}, JSON.parse(last_response.body)['name'])
    end
  end

  # def test_delete_me
  #   # Test nil access token
  #   delete '/me'
  #   assert_return 404
  #
  #   # Test user not found
  #   authorize_user('2.0123456789abcdef0123456789abcdef') { delete '/me' }
  #   assert_return 401
  #
  #   # Test unauthorized
  #   authorize_user('1.0123456789abcdef0123456789abcdef') { delete '/me' }
  #   assert_return 401
  #
  #   # Test successful delete
  #   authorize_user(@access_token) { delete '/me' }
  #   assert_return 200
  #   authorize_client { get '/users' }
  #   assert_return '[]'
  # end
end
