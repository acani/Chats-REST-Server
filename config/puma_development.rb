workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

preload_app!

environment ENV['RACK_ENV'] || 'development'

port = ENV['PORT'] || 3000
key  = File.join('config', 'ssl', 'server.key')
cert = File.join('config', 'ssl', 'server.crt')
ssl_bind '0.0.0.0', port, {key: key, cert: cert}
