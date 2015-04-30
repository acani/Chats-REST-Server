class Chats
  # Create or update signup code with phone
  # curl -i -d phone=3525700299 http://localhost:5100/signup_codes
  def signup_codes_post
    # Validate phone
    phone = Rack::Request.new(@env).POST['phone']
    phone_invalid_message = phone_invalid_message(phone)
    if phone_invalid_message
      return [400, '{"message":"'+phone_invalid_message+'"}']
    end

    POSTGRES.exec_params('SELECT * FROM signup_codes_post($1)', [phone]) do |r|
      if r.num_tuples == 0
        [403, '{"message":"A Chats account already exists with that phone number."}']
      else
        result = TextBelt.send({
          to: phone,
          body: "Your Chats code is #{r.getvalue(0, 0)}."
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
