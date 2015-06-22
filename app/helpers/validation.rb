class Chats
  def phone_invalid_response!(phone)
    unless phone_valid?(phone)
      return [400, '{"message":"Phone must be 10 digits."}']
    end
  end

  def code_invalid_response!(code)
    unless code_valid?(code)
      return [400, '{"message":"Code must be 4 digits."}']
    end
  end

  def phone_valid?(phone)
    return false unless phone
    phone.strip!
    !(phone !~ /\A[2-9]\d\d[2-9]\d{6}\z/)
  end

  def code_valid?(code)
    return false unless code
    code.strip!
    if code =~ /\A\d{4}\z/
      code.sub!(/\A0+/, '') # strips leading zeros
      true
    else
      false
    end
  end

  def key_valid?(key)
    return false unless key
    key.strip!
    !(key !~ /\A[0-9a-f]{32}\z/)
  end

  def string_is_blank_after_strip!(string)
    !string || (string.strip! || string).empty?
  end
end
