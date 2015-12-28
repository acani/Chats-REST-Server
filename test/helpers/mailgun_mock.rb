require_relative 'const_mock'

class REST
  module Mailgun
    def self.mock(code)
      mock = MiniTest::Mock.new
      mock.expect(:send, code, [Hash])

      REST.const_mock(:Mailgun, mock) do
        yield
      end

      mock.verify
    end
  end
end
