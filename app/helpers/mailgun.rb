require 'net/http'

class REST
  module Mailgun
    # Send email with Mailgun
    # Mailgun.send({
    #   from: 'Acani Chats <support@chats.acani.com>',
    #   to: email,
    #   subject: 'Signup Code',
    #   text: '1234'
    # })
    # curl -ik -d from='Acani Chats <support@chats.acani.com>' -d to=email -d subject='Signup Code' -d text=1234 https://api.mailgun.net/v2/abc123/messages
    def self.send(params)
      # Send email with Mailgun API
      # http://documentation.mailgun.com/api-sending.html#sending
      http = Net::HTTP.new('api.mailgun.net', 443)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      begin
        http.start do |http|
          request = Net::HTTP::Post.new("/v3/#{ENV['MAILGUN_DOMAIN_NAME']}/messages")
          request.basic_auth('api', ENV['MAILGUN_API_KEY'])
          request.form_data = params
          http.request(request).code.to_i
        end
      rescue SocketError
        502 # Bad Gateway
      end
    end
  end
end
