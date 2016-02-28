require 'test_helper'

class MailgunTest < RESTTest
  def test_send
    assert Mailgun.respond_to?(:send)
  end
end
