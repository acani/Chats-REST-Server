class REST
  # PICTURE_ID_INVALID_RESPONSE = [403, ['{"message":"Picture ID must be 32 lowercase hexidecimal digits."}']]
  FIRST_NAME_INVALID_RESPONSE = [403, ['{"message":"First name must be between 1 & 50 characters."}']]
  LAST_NAME_INVALID_RESPONSE  = [403, ['{"message":"Last name must be between 1 & 50 characters."}']]
  EMAIL_INVALID_RESPONSE      = [403, ['{"message":"Email must contain an at sign (@) and be between 3 & 254 characters."}']]
  # PHONE_INVALID_RESPONSE      = [403, ['{"message":"Phone must be 10 digits."}']]
  CODE_INVALID_RESPONSE       = [403, ['{"message":"Code must have between 1 & 4 digits."}']]
  CODE_INCORRECT_RESPONSE     = [403, ['{"message":"Code is incorrect or expired."}']]
  ALREADY_SIGNED_UP_RESPONSE  = [403, ['{"message":"An Acani Chats account already exists with that email address."}']]
  NOT_YET_SIGNED_UP_RESPONSE  = [403, ['{"message":"No Acani Chats account exists with that email address."}']]
  SEND_EMAIL_ERROR_RESPONSE   = [500, ['{"message":"Could not send email."}']]
  ME_NO_CHANGES_RESPONSE      = [403, ['{"message":"No changes requested."}']]
  EMAIL_NO_CHANGES_RESPONSE   = [403, ['{"message":"That\'s your email already. No changes made."}']]
  WWW_AUTHENTICATE_RESPONSE   = [401, {'WWW-Authenticate' => 'Bearer realm="Acani Chats"'}, []]
  EMAIL_FROM_ADDRESS = 'Acani Chats <support@chats.acani.com>'
  EMAIL_CHANGED_TEXT = 'Your email has been changed to %s. If you didn\'t make this change, please contact support@chats.acani.com immediately. Thank you.'

  # def picture_id_invalid_response(picture_id)
  #   if picture_id && !uuid_valid?(picture_id)
  #     PICID_INVALID_RESPONSE
  #   end
  # end

  def first_name_invalid_response(first_name)
    unless first_name.length.between?(1, 50)
      FIRST_NAME_INVALID_RESPONSE
    end
  end

  def last_name_invalid_response(last_name)
    unless last_name.length.between?(1, 50)
      LAST_NAME_INVALID_RESPONSE
    end
  end

  def email_invalid_response(email)
    unless email.length.between?(3, 254) && email.include?('@')
      EMAIL_INVALID_RESPONSE
    end
  end

  # def phone_invalid_response(phone)
  #   unless phone =~ /\A[2-9]\d\d[2-9]\d{6}\z/
  #     PHONE_INVALID_RESPONSE
  #   end
  # end

  def code_invalid_response(code)
    unless code =~ /\A\d{1,4}\z/
      CODE_INVALID_RESPONSE
    end
  end

  # def uuid_valid?(uuid)
  #   !(uuid !~ /\A[0-9a-f]{32}\z/)
  # end
end
