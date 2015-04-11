role :app, %w{color.camp}
role :web, %w{color.camp}
role :db,  %w{color.camp}

set :whenever_roles, -> { [:db] }
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

server 'color.camp', user: 'ubuntu', roles: %w{web app db}

set :deploy_to, '/home/gleuch/color.camp'

set :rails_env, :production
# set :sidekiq_processes, 2


set :ssh_options, { auth_methods: ["publickey"], keys: [File.join(File.expand_path('../../../.ssh', File.dirname(__FILE__)), "wt-app-web.pem")] }