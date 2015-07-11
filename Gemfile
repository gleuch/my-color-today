source 'https://rubygems.org'

# --- CORE REQUIREMENTS ---
gem 'rails',                          '4.2.3'
gem 'therubyracer',                   '0.12.2',       platforms: :ruby
gem 'turbolinks',                     '2.5.3'
gem 'jbuilder',                       '2.3.1'
gem 'unf',                            '0.1.4'
# gem 'asset_sync',                     '1.1.0'
gem 'mysql2',                         '0.3.18'
gem 'bcrypt',                         '3.1.10'


# --- MODELS & CONTROLLERS ---
gem 'paperclip',                      '4.3.0'
gem 'paperclip-compression',          '0.3.7'
gem 'friendly_id',                    '5.1.0'
gem 'will_paginate',                  '3.0.7'
gem 'authlogic',                      '3.4.5'
gem 'sanitize',                       '4.0.0'
gem 'addressabler',                   '0.1.2'


# --- FORMATTING, STYLING, DISPLAY ---
gem 'haml',                           '4.0.6'
gem 'sass-rails',                     '5.0.3'
gem 'uglifier',                       '2.7.1'
gem 'coffee-rails',                   '4.1.0'
gem 'jquery-rails',                   '4.0.4'
gem 'jquery-ui-rails',                '5.0.5'
gem 'will_paginate-bootstrap',        '1.0.1'
gem 'bootstrap-sass',                 '3.3.5.1'
gem 'bourbon',                        '4.2.3'
gem 'react-rails',                    '1.1.0'


# --- REDIS / SIDEKIQ ---
gem 'sidekiq',                        '3.4.1'
gem 'sidekiq-unique-jobs',            '3.0.14'
gem 'redis',                          '3.2.1'
gem 'redis-rails',                    '4.0.0'


# --- FORM & RENDER HELPERS ---
gem 'simple_form',                    '3.1.0'


# --- GENERAL HELPERS ---
gem 'browser',                        '0.8.0'
gem 'rails-timeago',                  '2.12.0'
# gem 'momentjs-rails',                 '2.8.3'
# gem 'chartkick',                      '1.3.2'
# gem 'sitemap_generator',              '5.0.5',        require: false


# --- MONITORING / PERFORMANCE ---
gem 'rails-settings-cached',          '0.4.1'
# gem 'airbrake',                       '4.2.0'
# gem 'newrelic_rpm',                   '3.9.5.251'
# gem 'whenever',                       '0.9.4',        require: false
# gem 'split',                          '1.0.0',        require: 'split/dashboard'


# --- OAUTH / APIS ---
gem 'aws-sdk',                        '2.1.2'
gem 'rest-client',                    '1.8.0'
gem 'twitter',                        '5.14.0'
gem 'fb_graph',                       '2.7.17'
gem 'omniauth-facebook',              '2.0.1'
gem 'omniauth-twitter',               '1.2.0'
# gem 'omniauth-google-oauth2',         '0.2.4'


# --- WEBSOCKETS ---
gem 'websocket-rails',                '0.7.0'



# --- DEVELOPMENT & TEST ---

group :development do
  gem 'unicorn',                      '4.9.0'
  gem 'bullet',                       '4.14.4'

  # Capistrano deployment
  gem 'capistrano',                   '3.4.0'
  gem 'capistrano-rvm',               '0.1.2'
  gem 'capistrano-rails',             '1.1.3'
  gem 'capistrano-bundler',           '1.1.4'
  gem 'capistrano-sidekiq',           '0.5.2'
  gem 'quiet_assets',                 '1.1.0'

  # gem 'sinatra',                      '1.4.5',        require: false
  gem 'slim',                         '3.0.3'
end

group :test do
  gem 'capybara',                     '2.4.4'
  gem 'capybara-webkit',              '1.5.0'
  gem 'simplecov',                    '0.9.2',        require: false
  gem 'selenium-webdriver',           '2.45.0'
  gem 'sqlite3',                      '1.3.10'
end

group :development, :test do
  gem 'rspec-rails',                  '3.2.3'
  gem 'database_cleaner',             '1.4.1'
  gem 'ffaker',                       '2.0.0'
  gem 'factory_girl_rails',           '4.5.0'
end


# group :doc do
#   # bundle exec rake doc:rails generates the API under doc/api.
#   gem 'sdoc',                         '0.4.1',        require: false
# end
