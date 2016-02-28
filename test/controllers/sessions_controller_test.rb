require 'test_helper'

class SessionsControllerTest < RESTTest
  def test_sessions_post
    # Create code
    Mailgun.mock(200) do
      post '/login', {email: @email}
    end
    code = get_code('login', @email)

    # Test invalid email
    post '/sessions'
    assert_return REST::EMAIL_INVALID_RESPONSE
    post '/sessions', {email: ''}
    assert_return REST::EMAIL_INVALID_RESPONSE
    post '/sessions', {email: 'invalid_email'}
    assert_return REST::EMAIL_INVALID_RESPONSE

    # Test invalid code
    post '/sessions', {email: @email}
    assert_return REST::CODE_INVALID_RESPONSE
    post '/sessions', {email: @email, code: ''}
    assert_return REST::CODE_INVALID_RESPONSE
    post '/sessions', {email: @email, code: 'invalid_code'}
    assert_return REST::CODE_INVALID_RESPONSE

    # Test incorrect email & code
    post '/sessions', {email: 'incorrect@example.com', code: code}
    assert_return REST::CODE_INCORRECT_RESPONSE
    post '/sessions', {email: @email, code: (code == '1234' ? '1235' : '1234')}
    assert_return REST::CODE_INCORRECT_RESPONSE

    # Test correct email & code
    post '/sessions', {email: @email, code: code}
    assert_return /\A\{"access_token":"1\.[0-9a-f]{32}"\}\z/

    # Confirm user was logged in
    authorize_user(JSON.parse(last_response.body)['access_token']) do
      delete '/sessions'
      assert_return 200
    end

    # Test that code only works once
    post '/sessions', {email: @email, code: code}
    assert_return REST::CODE_INCORRECT_RESPONSE
  end

  def test_sessions_delete
    # Test invalid access_token
    authorize_user('invalid-access_token') do
      delete '/sessions'
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end

    # Test incorrect access_token
    authorize_user('2.0123456789abcdef0123456789abcdef') do
      delete '/sessions'
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end

    # Test correct access_token
    authorize_user(@access_token) do
      delete '/sessions'
      assert_return 200
      get '/me'
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end
  end
end
