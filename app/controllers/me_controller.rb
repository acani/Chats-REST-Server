class REST
  # Get me: id, first_name, last_name
  # curl -ik -H 'Authorization: Bearer 1.0123456789abcdef0123456789abcdef' https://localhost:5100/me
  def me_get
    user_id, session_id = parse_authorization_header
    if user_id && session_id
      $pg.with do |pg|
        pg.exec_params('SELECT * FROM me_get($1,$2)', [user_id, session_id]) do |r|
          if r.num_tuples == 1
            values = r.values[0]
            return '{"id":"'+values[0]+'","name":{"first":"'+values[1]+'","last":"'+values[2]+'"},"email":"'+values[3]+'"}'
          end
        end
      end
    end
    WWW_AUTHENTICATE_RESPONSE
  end

  # Update me: first_name, last_name
  # curl -ik -X PATCH -H 'Authorization: Bearer 1.0123456789abcdef0123456789abcdef' -d first_name=John -d last_name='Appleseed' https://localhost:5100/me
  def me_patch
    user_id, session_id = parse_authorization_header
    if user_id && session_id
      params = Rack::Request.new(@env).POST
      first_name = params['first_name']
      last_name = params['last_name']

      # No change requested
      unless first_name || last_name
        return ME_NO_CHANGES_RESPONSE
      end

      # Reject blank strings
      if first_name
        first_name.strip!
        error = first_name_invalid_response(first_name)
        return error if error
      end
      if last_name
        last_name.strip!
        error = last_name_invalid_response(last_name)
        return error if error
      end

      $pg.with do |pg|
        pg.exec_params('SELECT me_patch($1,$2,$3,$4)', [user_id, session_id, first_name, last_name]) do |r|
          if r.num_tuples == 1
            return 200
          end
        end
      end
    end
    WWW_AUTHENTICATE_RESPONSE
  end

  # Delete my account
  # curl -ik -X DELETE -H 'Authorization: Bearer 1.0123456789abcdef0123456789abcdef' https://localhost:5100/me
  def me_delete
    user_id, session_id = parse_authorization_header
    if user_id && session_id
      $pg.with do |pg|
        pg.exec_params('SELECT me_delete($1,$2)', [user_id, session_id]) do |r|
          if r.num_tuples == 1
            return 200
          end
        end
      end
    end
    WWW_AUTHENTICATE_RESPONSE
  end
end
