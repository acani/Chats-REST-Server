require 'test_helper'

class MailgunTest < RESTTest
  def test_send
    assert REST::Mailgun.respond_to?(:send)
  end
end
