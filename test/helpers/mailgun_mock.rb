require_relative 'const_mock'

class REST
  module Mailgun
    def self.mock(code)
      response_mock = MiniTest::Mock.new
      response_mock.expect(:code, code)

      mailgun_mock = MiniTest::Mock.new
      mailgun_mock.expect(:send, response_mock, [Hash])

      REST.const_mock(:Mailgun, mailgun_mock) do
        yield
      end

      mailgun_mock.verify
      response_mock.verify
    end
  end
end
