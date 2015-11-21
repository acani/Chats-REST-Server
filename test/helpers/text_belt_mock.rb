# require_relative 'const_mock'
#
# class REST
#   module TextBelt
#     def self.mock(result)
#       mock = MiniTest::Mock.new
#       mock.expect(:send, result, [Hash])
#
#       REST.const_mock(:TextBelt, mock) do
#         yield
#       end
#
#       mock.verify
#     end
#   end
# end
