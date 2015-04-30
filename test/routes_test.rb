require 'test_helper'

class RoutesTest < ChatsTest
  def test_not_found
    get '/users/1'
    assert_return 404
    post '/users/1'
    assert_return 404

    put '/signup_codes/1'
    assert_return 404
    post '/sessions'
    assert_return 404
    delete '/sessions/1'
    assert_return 404

    put '/me/1'
    assert_return 404
    delete '/me/1'
    assert_return 404

    assert_raises(URI::InvalidURIError) { get "/users/\n/cool" }
  end
end
