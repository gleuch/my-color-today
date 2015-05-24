class User < ActiveRecord::Base

  # EXTENSIONS ----------------------------------------------------------------

  # UUID
  include Uuidable

  # Authlogic
  acts_as_authentic do |c|
    c.crypto_provider = Authlogic::CryptoProviders::BCrypt
    c.merge_validates_length_of_email_field_options({unless: Proc.new { |u| u.is_oauth_signup }})
    c.merge_validates_format_of_email_field_options({unless: Proc.new { |u| u.is_oauth_signup }})
    c.merge_validates_uniqueness_of_email_field_options({unless: Proc.new { |u| u.is_oauth_signup }})
  end

  # FriendlyId
  extend FriendlyId
  friendly_id :login, use: [:finders]

  # Paperclip
  has_attached_file :avatar, 
      styles: { large: ["500x500#",:jpg], medium: ["200x200#",:jpg], small: ["64x64#",:jpg] }, 
      processors: [:thumbnail, :compression],
      default_style: :medium, default_url: "/images/:class/:attachment/:style.png"


  # ENUM ----------------------------------------------------------------------

  enum language: {
    'en' =>     0,
    # 'es' =>     2,
    # 'zh-cn' =>  1,
  }


  # ASSOCIATIONS --------------------------------------------------------------

  has_one :api_token

  has_many :page_colors, class_name: 'WebSitePageColor'
  has_many :authentications, class_name: 'UserAuthentication'
  has_many :reports, class_name: 'ColorReport', as: :item


  # VALIDATIONS ---------------------------------------------------------------

  attr_accessor :is_oauth_signup

  validates :name, :login, presence: true, length: {maximum: 250}
  validates_attachment :avatar, 
    content_type: { content_type: ['image/jpeg', 'image/jpg', 'image/png', 'image/gif'] },
    size: { less_than: 5.megabytes }


  # CLASS METHODS -------------------------------------------------------------

  # Check that specified local is a valid language
  def self.is_valid_language(l); User.languages.keys.include?(l.to_s.downcase) rescue false; end

  # Create user from ominiauth data
  def self.create_from_omniauth_data(auth)
    user = User.joins(:authentications).where(user_authentications: {provider: auth[:provider], uid: auth[:uid]}).first_or_initialize.tap do |u|
      u.login = auth[:username]
      u.email = auth[:email]
      u.name = auth[:name] || auth[:username]
      u.is_oauth_signup = true
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

  def to_api
    {
      id: self.uuid,
      name: self.name,
      login: self.login
    }
  end

  def color(d, *args)
    opts = args.extract_options!
    info = reports.on(d || :overall).get
    info.recalculate! if opts[:recalculate]
    {count: info.views_count, rgb: info.color_rgb, hex: info.color_hex, palette: info.palette}
  end

  # def deliver_password_reset_instructions!
  #   reset_perishable_token!
  #   UserMailer.password_reset_instructions(self).deliver
  # end



private

end
