class Chats
  # Create or update login code
  # curl -i -X PUT -d phone=user1@gmail.com http://localhost:5100/signup_codes
  def post_codes
    if !client_authorized?
      [404, '']
    else
      phone = Rack::Request.new(@env).POST['phone']
      bad_phone_response = [404, '{"message":"No user exists with that phone."}']
      if phone_invalid_message(phone)
        bad_phone_response
      else
        POSTGRES.exec_params('SELECT * FROM code($1)', [phone]) do |r|
          if r.num_tuples == 0
            bad_phone_response
          # elsif TextBelt.send({
          #   from: 'support@osperm.com',
          #   to: phone,
          #   subject: 'Login Code',
          #   text: r.getvalue(0, 1)
          #   }).code.to_i != 200
          #   [500, '{"message":"Could not send phone."}']
          else
            [200, '{"id":'+r.getvalue(0, 0)+'}']
          end
        end
      end
    end
  end
end
