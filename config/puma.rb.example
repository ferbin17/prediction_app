# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
# threads_count = 32
# threads 4, 32
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 1 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
# port 8888
port        ENV.fetch("PORT") { 3017 }

# Specifies the `environment` that Puma will run in.
#
# environment "production"
environment ENV.fetch("RAILS_ENV") { "production" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers 8
workers ENV.fetch("WEB_CONCURRENCY") { 1 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
#
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Directory configuration - make sure app_dir points to where source code is located
app_dir = ''
directory app_dir
rackup "#{app_dir}/config.ru"

# Shared directory setup for service logs and sockets. subfolders logm pids and sockets should be present
shared_dir = "#{app_dir}/shared"
bind "unix://#{shared_dir}/sockets/puma.sock"
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"

# whether the process should be daemonized or not
daemonize true

preload_app!

before_fork do
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end


on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end