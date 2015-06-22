class Chats
  # Get all users
  # curl -i http://localhost:5100/users
  def users_get
    $pg.with do |pg|
      pg.exec('SELECT * FROM users_get()') do |r|
        users = []
        r.each_row do |t|
          user = {id: Integer(t[0]), name: {first: t[2], last: t[3]}}
          user[:picture_id] = t[1] if t[1]
          users.push(user)
        end
        [200, users.to_json]
      end
    end
  end

  # Sign up: Create user with phone, key, first_name, and last_name
  # curl -i -d phone=2102390602 -d key=abc123 -d first_name=Matt -d last_name='Di Pasquale' http://localhost:5100/users
  def users_post
    params = Rack::Request.new(@env).POST
    phone = params['phone']
    key = params['key']

    if phone_valid?(phone) && key_valid?(key)
      # Require first_name & last_name
      first_name = params['first_name']
      last_name = params['last_name']
      if string_is_blank_after_strip!(first_name)
        return [400, '{"message":"First name is required."}']
      end
      if string_is_blank_after_strip!(last_name)
        return [400, '{"message":"Last name is required."}']
      end

      $pg.with do |pg|
        pg.exec_params('SELECT * FROM users_post($1, $2, $3, $4)', [phone, key, first_name, last_name]) do |r|
          if r.num_tuples == 1
            access_token = build_access_token(r.getvalue(0, 0), key)
            return [201, '{"access_token":"'+access_token+'"}']
          end
        end
      end
    end
    set_www_authenticate_header
    [401, '{"message":"Incorrect phone or key."}']
  end
end
