class REST
  # Create or update login code with email
  # curl -ik -d email=sally.davis@example.com https://localhost:5100/login
  def login_post
    # Validate email
    email = Rack::Request.new(@env).POST['email'].to_s
    email.strip!
    error = email_invalid_response(email)
    return error if error

    $pg.with do |pg|
      pg.exec_params('SELECT * FROM login_post($1)', [email]) do |r|
        if r.num_tuples == 0
          NOT_YET_SIGNED_UP_RESPONSE
        else
          code = Mailgun.send({
            from: EMAIL_FROM_ADDRESS,
            to: email,
            subject: 'Login Code',
            text: r.getvalue(0, 0).rjust(4, '0')
          })
          SEND_EMAIL_ERROR_RESPONSE unless code == 200
        end
      end
    end
  end
end
