class Chats
  # Get all users
  # curl -i http://localhost:5100/users
  def users_get
    [200, "[#{POSTGRES.exec('SELECT * FROM users_get()') { |r| r.column_values(0) }.join(',')}]"]
  end

  # Sign up: Verify phone and create a user
  # curl -i -d phone=3525700299 code=1234 http://localhost:5100/users
  def users_post
    # Validate code & phone
    params = Rack::Request.new(@env).POST
    code = params['code']
    code_invalid_message = code_invalid_message(code)
    if code_invalid_message
      return [400, '{"message":"'+code_invalid_message+'"}']
    end
    phone = params['phone']
    phone_invalid_message = phone_invalid_message(phone)
    if phone_invalid_message
      return [400, '{"message":"'+phone_invalid_message+'"}']
    end

    POSTGRES.exec_params("SELECT * FROM users_post($1, $2)", [phone, code]) do |r|
      if r.num_tuples == 0
        [403, '{"message":"Code is incorrect or expired."}']
      else
        user_id = r.getvalue(0, 0)
        access_token = "#{user_id}|#{r.getvalue(0, 1)}"
        [201, '{"id":'+user_id+',"access_token":"'+access_token+'"}']
      end
    end
  end
end
