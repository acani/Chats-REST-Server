require 'net/http'

class Chats
  module TextBelt
    # Send SMS with TextBelt
    # TextBelt.send({
    #   to: '3525700299',
    #   body: 'Hello, World!'
    # })
    def self.send(params)
      uri = URI('http://textbelt.com/text')
      response = Net::HTTP.post_form(uri, params)
      if response.code == 200
        JSON.parse(response.body)
      else
        {'success' => false, 'message' => "Couldn't send text message."}
      end
    end
  end
end
