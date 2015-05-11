class Chats
  # Get all users
  # curl -i http://localhost:5100/users
  def users_get
    POSTGRES.exec('SELECT * FROM users_get()') do |r|
      users = []
      r.each_row do |t|
        user = {id: Integer(t[0]), name: {first: t[2], last: t[3]}}
        user[:picture_id] = t[1] if t[1]
        users.push(user)
      end
      [200, users.to_json]
    end
  end

  # Sign up: Create user with phone, key, first_name, and last_name
  # curl -i -H 'Authorization: Bearer 2102390602|12345678901234567890123456789012' -d first_name=Matt -d last_name='Di Pasquale' http://localhost:5100/users
  def users_post
    phone, key = parse_authorization_header
    if phone
      params = Rack::Request.new(@env).POST

      # Validate first_name
      first_name = params['first_name']
      if string_strip_blank?(first_name)
        return [400, '{"message":"First name is required."}']
      end

      # Validate last_name
      last_name = params['last_name']
      if string_strip_blank?(last_name)
        return [400, '{"message":"Last name is required."}']
      end

      POSTGRES.exec_params('SELECT * FROM users_post($1, $2, $3, $4)', [phone, key, first_name, last_name]) do |r|
        if r.num_tuples == 1
          access_token = build_access_token(r.getvalue(0, 0), key)
          return [201, '{"access_token":"'+access_token+'"}']
        end
      end
    end
    set_www_authenticate_header
    [401, '{"title":"Unauthorized","message":"Please reverify your phone and try again."}']
  end
end
