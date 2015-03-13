class WebSitePageColor < ActiveRecord::Base


  # EXTENSIONS ----------------------------------------------------------------

  # UUID
  include Uuidable

  # FriendlyId
  extend FriendlyId
  friendly_id :uuid, use: [:finders]


  # ASSOCIATIONS --------------------------------------------------------------

  belongs_to :page, class_name: 'WebSitePage', counter_cache: :colors_count, foreign_key: :web_site_page_id
  belongs_to :user


  # VALIDATIONS ---------------------------------------------------------------

  validates :color_red, :color_green, :color_blue, presence: true, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 255}

  before_create :generate_color_hex
  after_create :queue_average_color_worker
  

  # CLASS METHODS -------------------------------------------------------------

  # Find first or create new web site page
  def self.add(url,colors,user=nil)
    page = WebSitePage.add(url)
    page.colors.create(color_red: colors[:red], color_green: colors[:green], color_blue: colors[:blue], user_id: (user.present? ? user.id : nil))
  end


  # METHODS -------------------------------------------------------------------

  # Return RGB as array
  def rgb_color
    [self.color_red, self.color_green, self.color_blue]
  end

  # Return color as hex code
  def hex_color
    self.color_hex
  end

  # Site association
  def site
    self.page.site
  end

  # API return information
  def to_api
    {
      id: self.uuid,
      color: {
        rgb: rgb_color,
        hex: hex_color
      },
      page: self.page.to_api,
      created_at: self.created_at
    }
  end



private

  def generate_color_hex
    self.color_hex ||= ("%02x%02x%02x" % rgb_color).upcase
  end

  def queue_average_color_worker
    self.page.reload # ensure we get updated record

    WebsocketRails[:all_users].trigger(:new_color, self.to_api)
    WebsocketRails["user-#{self.user.uuid}"].trigger(:new_color, self.to_api) if self.user.present?

    # If this color is only color, then average will be same as self
    unless self.page.colors_count > 1
      self.page.update(color_avg_red: self.color_red, color_avg_green: self.color_green, color_avg_blue: self.color_blue, color_avg_hex: self.color_hex)

    # Otherwise queue job to determine the correct average color
    else
      # TODO : QUEUE AVG JOB
    end
  end

end
