OmniAuth.config.logger = Rails.logger
secrets = YAML.load(File.open("#{Rails.root}/config/secrets.yml"))[Rails.env] rescue {}

if secrets.present?
  Rails.application.config.middleware.use OmniAuth::Builder do

    provider :developer if Rails.env.development?

    # Twitter
    provider :twitter, secrets['twitter']['token'], secrets['twitter']['secret']

    # Facebook
    provider :facebook, secrets['facebook']['token'], secrets['facebook']['secret'], 
      scope: 'email,public_profile,user_friends', 
      display: 'popup'

    # Google
    if secrets['google'].present?
      provider :google_oauth2, secrets['google']['token'], secrets['google']['secret'], {
        access_type: 'offline',
        prompt: 'select_account consent',
        scope: 'email profile https://www.googleapis.com/auth/gmail.readonly'
      }
    end
  end
end


# This is a hack for getting a list of available and configured providers.
module OmniAuth
  class Builder < ::Rack::Builder

    def provider_patch(klass, *args, &block)
      @@providers ||= {}
      @@providers[klass] = args
      old_provider(klass, *args, &block)
    end
    alias old_provider provider
    alias provider provider_patch

    class << self
      def providers
        provider_setups.keys
      end

      def provider_setups
        @@providers ||= {}
      end
    end
  end
end