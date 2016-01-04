class REST
  # Create or update signup code with first_name, last_name, and email
  # curl -ik -d first_name=Sally -d last_name=Davis -d email=sally.davis@example.com https://localhost:5100/signup
  def signup_post
    params = Rack::Request.new(@env).POST

    # Validate first_name
    first_name = params['first_name'].to_s
    first_name.strip!
    error = first_name_invalid_response(first_name)
    return error if error

    # Validate last_name
    last_name = params['last_name'].to_s
    last_name.strip!
    error = last_name_invalid_response(last_name)
    return error if error

    # Validate email
    email = params['email'].to_s
    email.strip!
    error = email_invalid_response(email)
    return error if error

    $pg.with do |pg|
      pg.exec_params('SELECT * FROM signup_post($1,$2,$3)', [first_name, last_name, email]) do |r|
        if r.num_tuples == 0
          ALREADY_SIGNED_UP_RESPONSE
        else
          code = Mailgun.send({
            from: EMAIL_FROM_ADDRESS,
            to: email,
            subject: 'Signup Code',
            text: r.getvalue(0, 0).rjust(4, '0')
          })
          SEND_EMAIL_ERROR_RESPONSE unless code == 200
        end
      end
    end
  end
end
