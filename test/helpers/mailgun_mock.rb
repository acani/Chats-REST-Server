require_relative 'const_mock'

class RESTTest
  module Mailgun
    def self.mock(retval, args=[Hash])
      mock = MiniTest::Mock.new
      mock.expect(:send, retval, args)

      REST.const_mock(:Mailgun, mock) do
        yield
      end

      mock.verify
    end
  end
end
