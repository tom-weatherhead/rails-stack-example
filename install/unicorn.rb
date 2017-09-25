# From https://www.linode.com/docs/development/ror/use-unicorn-and-nginx-on-ubuntu-14-04 :

# Set the path to the application:
base_dir = "/var/www/apps/rails-stack-example"
# app_dir git File.expand_path("../..", __FILE__)
# app_dir = "/var/www/apps/rails-stack-example"
app_dir = "#{base_dir}/current"
shared_dir = "#{base_dir}/shared"

log_dir = "#{shared_dir}/log"
# tmp_dir = "#{app_dir}/tmp"
tmp_dir = "#{shared_dir}/tmp"

working_directory app_dir

# Set the Unicorn options:
worker_processes 2
preload_app true
timeout 30

# Set the paths for logging:
stderr_path "#{log_dir}/unicorn.stderr.log"
stdout_path "#{log_dir}/unicorn.stdout.log"

# Set the path to the process ID file:
pid "#{tmp_dir}/pids/unicorn.pid"

# Set the path to the Unicorn socket:
listen "#{tmp_dir}/sockets/unicorn.sock", :backlog => 64
