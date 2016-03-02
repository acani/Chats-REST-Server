eval(File.read(File.join(File.dirname(__FILE__), 'base.rb')))

port = ENV['PORT'] || 3000
cert = File.join('config', 'ssl', 'server.crt')
key  = File.join('config', 'ssl', 'server.key')
ssl_bind '0.0.0.0', port, {cert: cert, key: key}
