class Chats
  # Create or update login code with phone
  # curl -i -d phone=3525700299 http://localhost:5100/login_codes
  def login_codes_post
    # Validate phone
    phone = Rack::Request.new(@env).POST['phone']
    phone_invalid_message = phone_invalid_message(phone)
    if phone_invalid_message
      return [400, '{"message":"'+phone_invalid_message+'"}']
    end

    POSTGRES.exec_params('SELECT * FROM login_codes_post($1)', [phone]) do |r|
      if r.num_tuples == 0
        [403, '{"message":"No Chats account exists with that phone number."}']
      else
        result = TextBelt.send({
          number: phone,
          message: "Your Chats code is #{r.getvalue(0, 0)}."
        })
        if result['success']
          [200, '']
        else
          [500, '{"message":"'+result['message']+'"}']
        end
      end
    end
  end
end
