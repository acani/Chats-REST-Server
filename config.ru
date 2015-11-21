require './config/application'
use Rack::Protection::PathTraversal
run REST.new
