require 'test_helper'

class LoginControllerTest < RESTTest
  def test_login_post
    # Test invalid email
    post '/login'
    assert_return REST::EMAIL_INVALID_RESPONSE
    post '/login', {email: ''}
    assert_return REST::EMAIL_INVALID_RESPONSE
    post '/login', {email: 'invalid_email'}
    assert_return REST::EMAIL_INVALID_RESPONSE

    # Test unregistered email
    post '/login', {email: 'unregistered@example.com'}
    assert_return REST::NOT_YET_SIGNED_UP_RESPONSE

    # Test registered email, success sending email
    Mailgun.mock(200) do
      post '/login', {email: @email}
    end
    assert_return 200
    code = get_and_assert_code('login', @email)

    # Test registered email update, error sending email
    Mailgun.mock(500) do
      post '/login', {email: @email}
    end
    assert_return REST::SEND_EMAIL_ERROR_RESPONSE
    code_new = get_and_assert_code('login', @email)
    assert code != code_new
  end
end
