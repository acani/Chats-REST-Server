class REST
  # Log in: Verify email & code and get/create session
  # curl -ik -d email=sally.davis@example.com -d code=1234 https://localhost:5100/sessions
  def sessions_post
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
      pg.exec_params('SELECT * FROM sessions_post($1,$2)', [email, code]) do |r|
        if r.num_tuples == 0
          CODE_INCORRECT_RESPONSE
        else
          values = r.values[0]
          access_token = build_access_token(values[0], values[1])
          '{"access_token":"'+access_token+'"}'
        end
      end
    end
  end

  # Log out: Delete a user's session
  # curl -ik -X DELETE -H 'Authorization: Bearer 1.0123456789abcdef0123456789abcdef' https://localhost:5100/sessions
  def sessions_delete
    user_id, session_id = parse_authorization_header
    if user_id && session_id
      $pg.with do |pg|
        pg.exec_params('SELECT sessions_delete($1,$2)', [user_id, session_id]) do |r|
          if r.num_tuples == 1
            return 200
          end
        end
      end
    end
    WWW_AUTHENTICATE_RESPONSE
  end
end
