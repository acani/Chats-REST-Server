require 'test_helper'

class SignupControllerTest < RESTTest
  def test_signup_post
    # Test invalid first_name
    post '/signup'
    assert_return REST::FIRST_NAME_INVALID_RESPONSE
    post '/signup', {first_name: ''}
    assert_return REST::FIRST_NAME_INVALID_RESPONSE
    post '/signup', {first_name: TOO_LONG_NAME}
    assert_return REST::FIRST_NAME_INVALID_RESPONSE

    # Test invalid last_name
    valid_fields = {first_name: 'Sally'}
    post '/signup', valid_fields
    assert_return REST::LAST_NAME_INVALID_RESPONSE
    post '/signup', valid_fields.merge({last_name: ''})
    assert_return REST::LAST_NAME_INVALID_RESPONSE
    post '/signup', valid_fields.merge({last_name: TOO_LONG_NAME})
    assert_return REST::LAST_NAME_INVALID_RESPONSE

    # Test invalid email
    valid_fields[:last_name] = 'Davis'
    post '/signup', valid_fields
    assert_return REST::EMAIL_INVALID_RESPONSE
    post '/signup', valid_fields.merge({email: ''})
    assert_return REST::EMAIL_INVALID_RESPONSE
    post '/signup', valid_fields.merge({email: 'invalid_email'})
    assert_return REST::EMAIL_INVALID_RESPONSE

    # Test registered email
    post '/signup', valid_fields.merge({email: @email})
    assert_return REST::ALREADY_SIGNED_UP_RESPONSE

    # Test unregistered email, success sending email
    unregistered_email = 'unregistered@example.com'
    valid_fields[:email] = unregistered_email
    Mailgun.mock(200) do
      post '/signup', valid_fields
    end
    assert_return 200
    code = get_and_assert_code('signup', unregistered_email)

    # Test unregistered email update, error sending email
    Mailgun.mock(500) do
      post '/signup', valid_fields
    end
    assert_return REST::SEND_EMAIL_ERROR_RESPONSE
    code_new = get_and_assert_code('signup', unregistered_email)
    assert code != code_new
  end
end
