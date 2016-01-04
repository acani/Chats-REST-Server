class REST
  # Create or update email code
  # curl -ik -d email=sally.davis@example.com https://localhost:5100/email
  def email_post
    user_id, session_id = parse_authorization_header
    if user_id && session_id
      # Validate email
      email = Rack::Request.new(@env).POST['email'].to_s
      email.strip!
      error = email_invalid_response(email)
      return error if error

      $pg.with do |pg|
        pg.exec_params('SELECT * FROM email_post($1,$2,$3)', [user_id, session_id, email]) do |r|
          if r.num_tuples == 1
            value = r.getvalue(0, 0)
            return EMAIL_NO_CHANGES_RESPONSE  if value == '-1'
            return ALREADY_SIGNED_UP_RESPONSE if value == '-2'

            code = Mailgun.send({
              from: EMAIL_FROM_ADDRESS,
              to: email,
              subject: 'Email Code',
              text: value.rjust(4, '0')
            })
            return code == 200 ? 200 : SEND_EMAIL_ERROR_RESPONSE
          end
        end
      end
    end
    WWW_AUTHENTICATE_RESPONSE
  end

  # Update email with email & code
  # curl -ik -X PUT -d email=sally.davis@example.com -d code=1234 https://localhost:5100/email
  def email_put
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
      pg.exec_params('SELECT * FROM email_put($1,$2)', [email, code]) do |r|
        if r.num_tuples == 0
          CODE_INCORRECT_RESPONSE
        else
          Mailgun.send({
            from: EMAIL_FROM_ADDRESS,
            to: r.getvalue(0, 0),
            subject: 'Email Changed',
            text: EMAIL_CHANGED_TEXT % email
          })
        end
      end
    end
  end
end
