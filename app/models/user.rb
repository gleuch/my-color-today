class User < ActiveRecord::Base

  # EXTENSIONS ----------------------------------------------------------------

  # UUID
  include Uuidable

  # Authlogic
  acts_as_authentic do |c|
    c.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha512
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
  end

  # FriendlyId
  extend FriendlyId
  friendly_id :login, use: [:slugged, :finders]

  enum language: {
    'en' =>     0,
    # 'es' =>     2,
    # 'zh-cn' =>  1,
  }



  # ASSOCIATIONS --------------------------------------------------------------

  has_one :api_token

  has_many :authentications, class: 'UserAuthentication'


  # VALIDATIONS ---------------------------------------------------------------

  validates :first_name, :last_name, :login, presence: true, length: {maximum: 250}


  # CLASS METHODS -------------------------------------------------------------

  # Check that specified local is a valid language
  def self.is_valid_language(l); User.languages.keys.include?(l.to_s.downcase) rescue false; end

  # Create user from ominiauth data
  def self.create_from_omniauth_data(auth)
    user = User.joins(:authentications).where(user_authentications: {provider: auth[:provider], uid: auth[:uid]}).first_or_initialize.tap do |u|
      # u.login = auth[:nickname]
      u.email = auth[:email]
      u.name = auth[:name] || auth[:nickname]
      u.password = u.password_confirmation = "".random(32)
      u.save!
    end

    provider = user.authentications.where(provider: auth[:provider]).first_or_create do |authentication|
      authentication.provider = auth[:provider]
      authentication.uid = auth[:uid]
    end

    provider.update(
      name: auth[:name], username: auth[:username], 
      token: auth[:token], secret: auth[:secret], refresh_token: auth[:refresh_token], token_expires_at: auth[:token_expire_at],
      profile_image_url: auth[:profile_image_url], profile_url: auth[:profile_url],
      gender: auth[:gender], birthday: auth[:birthday], locale: auth[:locale]
    )

    user.reset_persistence_token!

    user
  end

  # Get list of available providers from oAuth
  def self.available_providers
    OmniAuth::Builder.providers
  end



  # METHODS -------------------------------------------------------------------

  # def deliver_password_reset_instructions!
  #   reset_perishable_token!
  #   UserMailer.password_reset_instructions(self).deliver
  # end



private

end
