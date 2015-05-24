require 'sidekiq/api'

redis_options = YAML.load_file(File.join(Rails.root, 'config', 'redis.yml'))[::Rails.env] rescue nil

if redis_options.present?
  Sidekiq.configure_server do |config|
    config.redis = {url: redis_options['url'], namespace: "queue-#{Rails.env}"}
  end

  Sidekiq.configure_client do |config|
    config.redis = {url: redis_options['url'], namespace: "queue-#{Rails.env}"}
  end
end