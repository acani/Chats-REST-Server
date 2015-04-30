class Chats
  # Log in: Create or get login session
  # curl -i  http://localhost:5100/sessions/1/123456
  def sessions_post(user_id, code)
    if !client_authorized?
      [404, '']
    else
      POSTGRES.exec("SELECT login(#{user_id}, #{code})") do |r|
        if r.num_tuples == 0
          [401, '{"message":"Incorrect or expired code."}']
        else
          [200, '{"access_token":"'+r.getvalue(0, 0)+'"}']
        end
      end
    end
  end

  # Log out: Delete a user's login session
  # curl -i -X DELETE -H 'Authorization: Bearer 123456789012345678901234567890121' http://localhost:5100/sessions
  def sessions_delete
    user_id, session_id = parse_access_token
    if !user_id
      [404, '']
    else
      POSTGRES.exec_params("SELECT logout(#{user_id}, $1)", [session_id]) do |r|
        [r.num_tuples == 0 ? 401 : 200, '']
      end
    end
  end
end
