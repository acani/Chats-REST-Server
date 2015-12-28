class REST
  def routes
    request_method = @env['REQUEST_METHOD']

    # if @env['HTTP_ORIGIN']
    #   @response_headers['Access-Control-Allow-Origin'] = '*'
    # end
    #
    # if request_method == 'OPTIONS'
    #   return cors_options
    # end

    case @env['PATH_INFO']
    when '/email'
      case request_method
      when 'POST' then email_post
      when 'PUT' then email_put
      end
    when '/login'
      case request_method
      when 'POST' then login_post
      end
    when '/me'
      case request_method
      when 'GET' then me_get
      when 'PATCH' then me_patch
      when 'DELETE' then me_delete
      end
    when '/sessions'
      case request_method
      when 'POST' then sessions_post
      when 'DELETE' then sessions_delete
      end
    when '/signup'
      case request_method
      when 'POST' then signup_post
      end
    when '/users'
      case request_method
      when 'GET' then users_get
      when 'POST' then users_post
      end
    else
      404
    end
  end
end
