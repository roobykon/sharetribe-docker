app_dir = File.expand_path("../..", __FILE__)

rails_env = ENV['RAILS_ENV'] || "development"
environment rails_env

workers 0

if ["development"].include?(rails_env)
  threads 1, 3
else
  threads 3, 10
  stdout_redirect "#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true
end

bind "tcp://0.0.0.0:3000"

pidfile "#{app_dir}/tmp/pids/puma.pid"
state_path "#{app_dir}/tmp/pids/puma.state"

activate_control_app
  
on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end
