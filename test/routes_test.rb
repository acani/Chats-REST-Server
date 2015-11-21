require 'test_helper'

class RoutesTest < RESTTest
  def test_not_found
    get '/bad_path'
    assert_equal 404, last_response.status
    assert_equal({}, last_response.headers)
    assert_equal '', last_response.body

    get '/sessions' # bad method
    assert_equal 404, last_response.status
    assert_equal({}, last_response.headers)
    assert_equal '', last_response.body

    assert_raises(URI::InvalidURIError) { get "/users/\n/cool" }
  end
end
