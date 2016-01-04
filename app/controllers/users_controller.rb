class REST
  # Get all users
  # curl -ik https://localhost:5100/users
  def users_get
    $pg.with do |pg|
      pg.exec('SELECT * FROM users_get()') do |r|
        users = []
        r.each_row do |t|
          user = {id: Integer(t[0]), name: {first: t[1], last: t[2]}}
          users.push(user)
        end
        users.to_json
      end
    end
  end

  # Sign up: Create user with email & code
  # curl -ik -d email=sally.davis@example.com -d code=1234 https://localhost:5100/users
  def users_post
    params = Rack::Request.new(@env).POST

    # Validate email
    email = params['email'].to_s
    email.strip!
    error = email_invalid_response(email)
    return error if error

    # Validate code
    code = params['code']
    error = code_invalid_response(code)
    return error if error

    $pg.with do |pg|
      pg.exec_params('SELECT * FROM users_post($1,$2)', [email, code]) do |r|
        if r.num_tuples == 0
          CODE_INCORRECT_RESPONSE
        else
          user_id = r.getvalue(0, 0)
          session_id = r.getvalue(0, 1)
          body = {access_token: build_access_token(user_id, session_id)}
          [201, [body.to_json]]
        end
      end
    end
  end
end
