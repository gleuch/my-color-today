class ApiToken < ActiveRecord::Base

  # EXTENSIONS ----------------------------------------------------------------

  # FriendlyId
  extend FriendlyId
  friendly_id :token_key, use: [:finders]

  enum status: {
    active:     0,
    inactive:   1,
  }


  # ASSOCIATIONS --------------------------------------------------------------

  belongs_to :user


  # VALIDATIONS ---------------------------------------------------------------

  before_create :generate_token_and_key


  # CLASS METHODS -------------------------------------------------------------


  # METHODS -------------------------------------------------------------------

  def to_api
    {token_key: self.token_key, token_secret: self.token_secret, user: self.user ? self.user.to_api : nil}
  end

  def reset_token_and_key
    generate_token_and_key(true)
  end


private

  def generate_token_and_key(force=false)
    generate_token_key
    generate_token_secret
  end

  def generate_token_key(force=false)
    if self.token_key.blank? || !!force
      self.token_key = SecureRandom.uuid[0,32]
      generate_token_key(true) if self.class.where(token_key: self.token_key).count > 0
    end
  end

  def generate_token_secret(force=false)
    if self.token_secret.blank? || !!force
      self.token_secret = SecureRandom.uuid[0,32]
      generate_token_secret(true) if self.class.where(token_secret: self.token_secret).count > 0
    end
  end

end
