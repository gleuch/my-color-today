module Uuidable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_uuid
  end

  def generate_uuid(force=false)
    if self.uuid.blank? || !!force
      self.uuid = SecureRandom.uuid[0,8]
      generate_uuid(true) if self.class.where(uuid: self.uuid).count > 0
    end
  end

end