class Chats
  def call(env)
    @env = env
    @response_headers = {'Content-Type' => 'application/json'}
    method = env['REQUEST_METHOD']

    return_value = case env['PATH_INFO']
    when '/sessions'
      case method
      when 'POST' then sessions_post
      when 'DELETE' then sessions_delete
      end
    when '/login_codes'
      case method
      when 'POST' then login_codes_post
      end
    when '/signup_codes'
      case method
      when 'POST' then signup_codes_post
      end
    when '/users'
      case method
      when 'GET' then users_get
      when 'POST' then users_post
      end
    end

    if return_value
      return_value[1] = [return_value[1]]
      return_value.insert(1, @response_headers)
    else
      [404, {}, []]
    end
  end
end
