# require_relative 'const_mock'
#
# class RESTTest
#   module TextBelt
#     def self.mock(retval, args=[Hash])
#       mock = MiniTest::Mock.new
#       mock.expect(:send, retval, args)
#
#       REST.const_mock(:TextBelt, mock) do
#         yield
#       end
#
#       mock.verify
#     end
#   end
# end
