class REST
  def call(env)
    @env = env
    formulate_response(routes)
  end

  def formulate_response(return_value)
    status, headers, body = 200, {}, []

    case return_value
    when Fixnum
      status = return_value
    when String, Regexp
      body.push(return_value)
    when Array
      if return_value.count == 2
        status, body = return_value
      else # return_value.count == 3
        status, headers, body = return_value
        headers = headers.dup
      end
    end

    unless body.empty?
      headers['Content-Type'] = 'application/json'
    end

    [status, headers, body]
  end
end
