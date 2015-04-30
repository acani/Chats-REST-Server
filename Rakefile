require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

task :psql do
  sh "psql postgres -f db/chats.sql"
  run_psql('functions', 'helpers')
  ['tables', 'functions'].each do |d|
    run_psql_each(d, [
      'users',
      'signup_codes',
      'login_codes',
      'sessions'
    ])
  end
  run_psql('functions', 'me')
end

# Helpers

def run_psql(dirname, filename)
  sh "psql chats -f db/#{dirname}/#{filename}.sql"
end

def run_psql_each(dirname, filenames)
  filenames.each do |f|
    sh "psql chats -f db/#{dirname}/#{f}.sql"
  end
end
