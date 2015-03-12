source 'https://rubygems.org'

# --- CORE REQUIREMENTS ---
gem 'rails',                          '4.1.8'
gem 'therubyracer',                   '0.12.1',       platforms: :ruby
gem 'turbolinks',                     '2.5.3'
gem 'jbuilder',                       '2.2.5'
gem 'unf',                            '0.1.4'
gem 'asset_sync',                     '1.1.0'
gem 'mysql2',                         '0.3.17'
gem 'scrypt',                         '1.2.1'


# --- MODELS & CONTROLLERS ---
gem 'paperclip',                      '4.2.1'
gem 'paperclip-compression',          '0.3.6'
gem 'friendly_id',                    '5.0.4'
# gem 'impressionist',                  '1.5.1'
gem 'will_paginate',                  '3.0.7'
gem 'authlogic',                      '3.4.3'
gem 'sanitize',                       '3.0.3'
gem 'addressabler',                   '0.1.1',      git: 'https://github.com/gleuch/addressabler.git'


# --- FORMATTING, STYLING, DISPLAY ---
gem 'haml',                           '4.0.6'
gem 'sass-rails',                     '4.0.5'
gem 'uglifier',                       '2.6.0'
gem 'coffee-rails',                   '4.1.0'
gem 'jquery-rails',                   '3.1.2'
gem 'jquery-ui-rails',                '5.0.3'
gem 'will_paginate-bootstrap',        '1.0.1'
gem 'bootstrap-sass',                 '3.3.1.0'
gem 'bourbon',                        '3.2.3'


# --- REDIS / SIDEKIQ ---
gem 'sidekiq',                        '3.3.0'
gem 'redis',                          '3.1.0'
gem 'redis-rails',                    '4.0.0'


# --- FORM & RENDER HELPERS ---
gem 'simple_form',                    '3.1.0'


# --- GENERAL HELPERS ---
gem 'browser',                        '0.8.0'
gem 'rails-timeago',                  '2.11.1'
gem 'momentjs-rails',                 '2.8.3'
gem 'chartkick',                      '1.3.2'
gem 'sitemap_generator',              '5.0.5',        require: false


# --- MONITORING / PERFORMANCE ---
gem 'rails-settings-cached',          '0.4.1'
gem 'airbrake',                       '4.1.0'
# gem 'newrelic_rpm',                   '3.9.5.251'
gem 'whenever',                       '0.9.4',        require: false
gem 'split',                          '1.0.0',        require: 'split/dashboard'


# --- OAUTH / APIS ---
gem 'aws-sdk',                        '1.59.1'
gem 'rest-client',                    '1.7.2'
gem 'twitter',                        '5.13.0'
gem 'fb_graph',                       '2.7.17'
gem 'omniauth-facebook',              '2.0.0'
gem 'omniauth-twitter',               '1.1.0'
# gem 'omniauth-google-oauth2',         '0.2.4'


# --- WEBSOCKETS ---
gem 'websocket-rails',                '0.7.0'



# --- DEVELOPMENT & TEST ---

group :development do
  gem 'unicorn',                      '4.8.3'
  gem 'bullet',                       '4.14.0'

  # Capistrano deployment
  gem 'capistrano',                   '3.2.1'
  gem 'capistrano-rvm',               '0.1.2'
  gem 'capistrano-rails',             '1.1.2'
  gem 'capistrano-bundler',           '1.1.3'
  gem 'capistrano-sidekiq',           '0.3.8'
  gem 'quiet_assets',                 '1.0.3'

  gem 'sinatra',                      '1.4.5',        require: false
  gem 'slim',                         '2.0.3'
end

group :test do
  gem 'capybara',                     '2.4.4'
  gem 'capybara-webkit',              '1.3.0'
  gem 'simplecov',                    '0.9.1',        require: false
  gem 'selenium-webdriver',           '2.43.0'
  gem 'sqlite3',                      '1.3.9'
end

group :development, :test do
  gem 'rspec-rails',                  '2.14.2'        # TODO : upgrade to 3.0.1
  gem 'database_cleaner',             '1.3.0'
  gem 'ffaker',                       '1.25.0'
  gem 'factory_girl_rails',           '4.4.1'
end


group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc',                         '0.4.1',        require: false
end
