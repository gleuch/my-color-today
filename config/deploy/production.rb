# PRODUCTION CONFIG
set :rails_env, :production

role :app, %w{color.camp}
role :web, %w{color.camp}
role :db,  %w{color.camp}

server 'color.camp', user: 'colorcamp', roles: %w{web app db}

set :deploy_to, '/home/colorcamp/color.camp'


# WHENEVER
# set :whenever_roles, -> { [:db] }
# set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:production)}" }

# SIDEKIQ
# set :sidekiq_processes, 2

# WEBSOCKET_RAILS STANDALONE SERVER