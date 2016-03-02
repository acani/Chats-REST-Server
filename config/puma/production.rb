instance_eval(File.read(File.join(File.dirname(__FILE__), 'base.rb')))

port ENV['PORT'] || 3000
