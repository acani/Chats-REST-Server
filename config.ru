require_relative 'app/chats'
use Rack::Protection::PathTraversal
run Chats.new
