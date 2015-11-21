TEST := test/**/*_test.rb

.PHONY : test

test :
	ruby -Itest -e 'ARGV.each { |f| require "./#{f}" }' $(TEST)
