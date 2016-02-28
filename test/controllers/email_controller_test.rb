require 'test_helper'

class EmailControllerTest < RESTTest
  def test_email_post
    registered_email = 'john.appleseed@example.com'
    create_user('John', 'Appleseed', 'john.appleseed@example.com')

    # Test invalid access_token
    authorize_user('invalid-access_token') do
      post '/email'
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end

    unregistered_email = 'unregistered@example.com'

    # Test incorrect access_token
    authorize_user('1.0123456789abcdef0123456789abcdef') do
      # Test invalid email
      post '/email'
      assert_return REST::EMAIL_INVALID_RESPONSE
      post '/email', {email: ''}
      assert_return REST::EMAIL_INVALID_RESPONSE
      post '/email', {email: 'invalid_email'}
      assert_return REST::EMAIL_INVALID_RESPONSE

      # Test registered email
      post '/email', {email: @email}
      assert_return REST::WWW_AUTHENTICATE_RESPONSE

      # Test unregistered email
      post '/email', {email: unregistered_email}
      assert_return REST::WWW_AUTHENTICATE_RESPONSE
    end

    # Test correct access_token
    authorize_user(@access_token) do
      # Test same email
      post '/email', {email: @email}
      assert_return REST::EMAIL_NO_CHANGES_RESPONSE

      # Test registered email
      post '/email', {email: registered_email}
      assert_return REST::ALREADY_SIGNED_UP_RESPONSE

      # Test unregistered email, success sending email
      Mailgun.mock(200) do
        post '/email', {email: unregistered_email}
      end
      assert_return 200
      code = get_and_assert_code('email', unregistered_email)

      # Test unregistered email update, error sending email
      Mailgun.mock(500) do
        post '/email', {email: unregistered_email}
      end
      assert_return REST::SEND_EMAIL_ERROR_RESPONSE
      code_new = get_and_assert_code('email', unregistered_email)
      assert code != code_new
    end
  end

  def test_email_put
    # Create code
    email = 'unregistered@example.com'
    authorize_user(@access_token) do
      Mailgun.mock(200) do
        post '/email', {email: email}
      end
    end
    code = get_code('email', email)

    # Test invalid email
    put '/email'
    assert_return REST::EMAIL_INVALID_RESPONSE
    put '/email', {email: ''}
    assert_return REST::EMAIL_INVALID_RESPONSE
    put '/email', {email: 'invalid_email'}
    assert_return REST::EMAIL_INVALID_RESPONSE

    # Test invalid code
    put '/email', {email: email}
    assert_return REST::CODE_INVALID_RESPONSE
    put '/email', {email: email, code: ''}
    assert_return REST::CODE_INVALID_RESPONSE
    put '/email', {email: email, code: 'invalid_code'}
    assert_return REST::CODE_INVALID_RESPONSE

    # Test incorrect email & code
    put '/email', {email: 'incorrect@example.com', code: code}
    assert_return REST::CODE_INCORRECT_RESPONSE
    put '/email', {email: email, code: '1234'}
    assert_return REST::CODE_INCORRECT_RESPONSE

    # Test correct email & code
    Mailgun.mock(200, [{
      from: REST::EMAIL_FROM_ADDRESS,
      to: @email,
      subject: 'Email Changed',
      text: REST::EMAIL_CHANGED_TEXT % email
    }]) do
      put '/email', {email: email, code: code}
      assert_return 200
    end

    # Confirm email was updated
    authorize_user(@access_token) do
      get '/me'
      assert_return /\A\{"id":"1","name":\{"first":"Sally","last":"Davis"\},"email":"#{email}"\}\z/
    end

    # Test that code only works once
    put '/email', {email: email, code: code}
    assert_return REST::CODE_INCORRECT_RESPONSE
  end
end
