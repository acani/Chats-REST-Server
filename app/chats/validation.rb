class Chats
  def code_invalid_message(code)
    if string_strip_blank?(code)
      'Code is required.'
    elsif code !~ /\A[1-9]\d{3}\z/
      'Code is invalid.'
    end
  end

  def phone_invalid_message(phone)
    if string_strip_blank?(phone)
      'Phone is required.'
    elsif phone !~ /\A[2-9]\d\d[2-9]\d{6}\z/
      'Phone is invalid.'
    end
  end

  def string_strip_blank?(string)
    !string || string.strip! && false || string.empty?
  end
end
