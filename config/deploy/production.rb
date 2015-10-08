# PRODUCTION CONFIG
set :rails_env, :production

role :app, %w{mycolor.today}
role :web, %w{mycolor.today}
role :db,  %w{mycolor.today}

server 'mycolor.today', user: 'colorcamp', roles: %w{web app db}

set :deploy_to, '/home/colorcamp/color.camp'


# WHENEVER
set :whenever_roles, -> { [:db] }
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:production)}" }

# SIDEKIQ
set :sidekiq_processes, 2

# WEBSOCKET_RAILS STANDALONE SERVER
set :websocket_rails_server_role, :app
set :websocket_rails_args, ''