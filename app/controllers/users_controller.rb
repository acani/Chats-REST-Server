class Chats
  # Get all users
  # curl -i http://localhost:5100/users
  def users_get
    [200, "[#{POSTGRES.exec('SELECT * FROM users_get()') { |r| r.column_values(0) }.join(',')}]"]
  end

  # Sign up: Verify phone; create user
  # curl -i -d phone=3525700299 -d code=1234 http://localhost:5100/users
  def users_post
    params = Rack::Request.new(@env).POST

    # Validate code
    code = params['code']
    error = code_invalid_response(code)
    return error if error

    # Validate phone
    phone = params['phone']
    error = phone_invalid_response(phone)
    return error if error

    POSTGRES.exec_params('SELECT * FROM users_post($1, $2)', [phone, code]) do |r|
      if r.num_tuples == 0
        [403, '{"message":"Code is incorrect or expired."}']
      else
        access_token = build_access_token(r.getvalue(0, 0), r.getvalue(0, 1))
        [201, '{"access_token":"'+access_token+'"}']
      end
    end
  end
end
