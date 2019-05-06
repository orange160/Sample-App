workers 2
threads 1, 6
daemonize true
rails_env = ENV['RAILS_ENV'] || 'development'
environment rails_env
app_dir = File.expand_path("../..", __FILE__)
tmp_dir = "#{app_dir}/tmp"
bind "unix://#{tmp_dir}/sockets/puma.sock"
stdout_redirect "#{app_dir}/log/puma.stdout.log", 
  "#{app_dir}/log/puma.stderr.log"

pidfile "#{tmp_dir}/pids/puma.pid"
state_path "#{tmp_dir}/pids/puma.state"

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  #ActiveRecord::Base.establish_connection(YAML.load_file("${tmp_dir}/config/database.yml")[rails_env])
end
