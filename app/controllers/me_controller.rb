class Chats
  # Get me: `id`, `pciture_id`, `first_name`, `last_name`
  # curl -i -H 'Authorization: Bearer 1|12345678901234567890123456789012' http://localhost:5100/me
  def me_get
    user_id, session_id = parse_authorization_header
    if user_id
      POSTGRES.exec_params('SELECT * FROM me_get($1, $2)', [user_id, session_id]) do |r|
        if r.num_tuples == 1
          values = r.values[0]
          return [200, '{"id":'+values[0]+'","picture_id":"'+values[1]+'","name":{"first":"'+values[2]+'","last":"'+values[3]+'"}']
        end
      end
    end
    set_www_authenticate_header
    [401, '']
  end

  # Update me: `first_name`, `last_name`, `pciture_url`
  # curl -i -X PATCH -H 'Authorization: Bearer 1|12345678901234567890123456789012' http://localhost:5100/me
  def me_patch
    user_id, session_id = parse_access_token
    if user_id
      params = Rack::Request.new(@env).POST
      picture_id = params['picture_id']
      first_name = params['first_name']
      last_name = params['last_name']
      POSTGRES.exec_params('SELECT me_patch($1, $2, $3, $4, $5)', [user_id, session_id, picture_id, first_name, last_name]) do |r|
        if r.num_tuples == 1
          return [200, '']
        end
      end
    end
    set_www_authenticate_header
    [401, '']
  end

  # Create a presigned post
  # https://devcenter.heroku.com/articles/direct-to-s3-image-uploads-in-rails#pre-signed-post
  # curl -i -X POST -H 'Authorization: Bearer 1|12345678901234567890123456789012' http://localhost:5100/presigned_posts
  def presigned_posts_post
    user_id, session_id = parse_access_token
    if user_id
      post = AWS_S3_BUCKET.presigned_post({
        key: "/users/#{SecureRandom.hex}/${filename}",
        acl: 'public-read'
      })
      return [200, '{"url":"'+post.url+'","fields":'+post.fields.to_json+'}']
    end
    set_www_authenticate_header
    [401, '']
  end


  # Delete my account
  # curl -i -X DELETE -H 'Authorization: Bearer 1|12345678901234567890123456789012' http://localhost:5100/me
  def me_delete
    user_id, session_id = parse_authorization_header
    if user_id
      POSTGRES.exec_params('SELECT me_delete($1, $2)', [user_id, session_id]) do |r|
        if r.num_tuples == 1
          return [200, '']
        end
      end
    end
    set_www_authenticate_header
    [401, '']
  end
end
