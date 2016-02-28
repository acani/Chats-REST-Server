require 'test_helper'

class UsersControllerTest < RESTTest
  def test_users_get
    get '/users'
    assert_return /\A\[\{"id":1,"name":\{"first":"Sally","last":"Davis"\}\}\]\z/
  end

  def test_users_post
    # Create code
    email = 'unregistered@example.com'
    Mailgun.mock(200) do
      post '/signup', {first_name: 'John', last_name: 'Appleseed', email: email}
    end
    code = get_code('signup', email)

    # Test invalid email
    post '/users'
    assert_return REST::EMAIL_INVALID_RESPONSE
    post '/users', {email: ''}
    assert_return REST::EMAIL_INVALID_RESPONSE
    post '/users', {email: 'invalid_email'}
    assert_return REST::EMAIL_INVALID_RESPONSE

    # Test invalid code
    post '/users', {email: email}
    assert_return REST::CODE_INVALID_RESPONSE
    post '/users', {email: email, code: ''}
    assert_return REST::CODE_INVALID_RESPONSE
    post '/users', {email: email, code: 'invalid_code'}
    assert_return REST::CODE_INVALID_RESPONSE

    # Test incorrect email & code
    post '/users', {email: 'incorrect@example.com', code: code}
    assert_return REST::CODE_INCORRECT_RESPONSE
    post '/users', {email: email, code: '1234'}
    assert_return REST::CODE_INCORRECT_RESPONSE

    # Test correct email & code
    post '/users', {email: email, code: code}
    assert_return [201, [/\A\{"access_token":"2\.[0-9a-f]{32}"\}\z/]]

    # Confirm user was created
    get '/users'
    assert_return /\A\[\{"id":1,"name":\{"first":"Sally","last":"Davis"\}\},\{"id":2,"name":\{"first":"John","last":"Appleseed"\}\}\]\z/

    # Test that code only works once
    post '/users', {email: email, code: code}
    assert_return REST::CODE_INCORRECT_RESPONSE
  end
end
