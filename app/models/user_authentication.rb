class UserAuthentication < ActiveRecord::Base

  # EXTENSIONS ----------------------------------------------------------------

  # UUID
  include Uuidable


  # ENUMS ---------------------------------------------------------------------

  enum status: [:active, :inactive]

  # enum provider: {
  #   developer:    0,
  #   twitter:      1,
  #   # facebook:     2,
  #   # google:       3,
  #   # weibo:        4,
  #   # tumblr:       5,
  #   # github:       6,
  #   # pinterest:    7,
  #   # wechat:       8,
  #   # dribbble:     9,
  # }
  


  # ASSOCIATIONS --------------------------------------------------------------

  belongs_to :user


  # VALIDATIONS ---------------------------------------------------------------
  


  # CLASS METHODS -------------------------------------------------------------

  def self.find_from_omniauth_data(hash)
    where(provider: hash['provider'], uid: hash['uid']).first
  end

  def self.create_from_omniauth_data(hash, user = nil)
    user ||= User.create_from_omniauth_data(hash)
    create(user_id: user.id, uid: hash[:uid], provider: hash[:provider])
  end


  # METHODS -------------------------------------------------------------------

  def update_from_omniauth_data(auth)
    update(
      name: auth[:name], username: auth[:username],
      token: auth[:token], secret: auth[:secret], refresh_token: auth[:refresh_token], token_expires_at: auth[:token_expire_at],
      profile_image_url: auth[:profile_image_url], profile_url: auth[:profile_url],
      gender: auth[:gender], birthday: auth[:birthday], locale: auth[:locale]
    )
  end




private

end
