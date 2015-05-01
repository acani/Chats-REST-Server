class Chats
  # Log in: Verify phone; create/get session
  # curl -i -d phone=3525700299 -d code=1234 http://localhost:5100/sessions/1/123456
  def sessions_post
    params = Rack::Request.new(@env).POST

    # Validate code
    code = params['code']
    error = code_invalid_response(code)
    return error if error

    # Validate phone
    phone = params['phone']
    error = phone_invalid_response(phone)
    return error if error

    POSTGRES.exec_params("SELECT * FROM sessions_post($1, $2)", [phone, code]) do |r|
      if r.num_tuples == 0
        [403, '{"message":"Code is incorrect or expired."}']
      else
        access_token = build_access_token(r.getvalue(0, 0), r.getvalue(0, 1))
        [201, '{"access_token":"'+access_token+'"}']
      end
    end
  end

  # Log out: Delete a user's session
  # curl -i -X DELETE -H 'Authorization: Bearer 1|12345678901234567890123456789012' http://localhost:5100/sessions
  def sessions_delete
    user_id, session_id = parse_authorization_header
    if !user_id
      [401, '']
    else
      POSTGRES.exec_params("SELECT sessions_delete($1, $2)", [user_id, session_id]) do |r|
        if r.num_tuples == 0
          set_www_authenticate_header
          [401, '']
        else
          [200, '']
        end
      end
    end
  end
end
