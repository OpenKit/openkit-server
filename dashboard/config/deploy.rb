set :application,  'openkit'
set :repo_url,     'git@github.com:OpenKit/openkit-server.git'
set :deploy_to,    "/var/www/#{fetch(:application)}"
set :git_strategy, GitStrategy
set :subdir,       'dashboard'
set :branch,       'lzell-provisioning'

set :ssh_options,  {
   keys:            %w(~/.ssh/openkit.pub),
   user:            'ec2-user',
   forward_agent:   true,
   auth_methods:    %w(publickey)
}

set :log_level,  :debug   # :info
set :pty,        true
set :format,     :pretty

set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 10

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

namespace :deploy do
  after :finishing, 'deploy:cleanup'
end
