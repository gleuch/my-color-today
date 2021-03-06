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


  # SCOPES --------------------------------------------------------------------

  scope :on, -> (d=Date.today) { where("#{self.table_name}.created_at >= ? AND #{self.table_name}.created_at < ?", d.to_time, d.to_time + 1.day) }
  scope :recently, ->(d=1.day) { recent }
  scope :recent, -> { order("#{self.table_name}.created_at desc") }
  
  default_scope { where(active: true) }


  # CLASS METHODS -------------------------------------------------------------

  # Find first or create new web site page
  def self.add(url,avg_colors,dom_colors=nil,*args)
    opts = args.extract_options!
    page = WebSitePage.add(url)
    page.colors.create(
      color_red: avg_colors[:red], color_green: avg_colors[:green], color_blue: avg_colors[:blue], 
      palette_red: dom_colors[:red], palette_green: dom_colors[:green], palette_blue: dom_colors[:blue], 
      api_token_id: opts[:api_token].try(:id),
      user_id: opts[:user].try(:id)
    )
  end

  # Return pixel color as RGB
  def self.color_rgb
    color = select("AVG(#{self.table_name}.color_red) AS red, AVG(#{self.table_name}.color_green) AS green, AVG(#{self.table_name}.color_blue) AS blue").where("#{self.table_name}.color_red IS NOT NULL AND #{self.table_name}.color_blue IS NOT NULL AND #{self.table_name}.color_green IS NOT NULL").first
    [color.red.round, color.green.round, color.blue.round]
  rescue
    nil
  end

  # Return pixel color as hex
  def self.color_hex
    color_rgb.rgb_to_hex
  rescue
    nil
  end

  # Return palette color as RGB
  def self.palette_rgb
    color = select("AVG(#{self.table_name}.palette_red) AS red, AVG(#{self.table_name}.palette_green) AS green, AVG(#{self.table_name}.palette_blue) AS blue").where("#{self.table_name}.palette_red IS NOT NULL AND #{self.table_name}.palette_blue IS NOT NULL AND #{self.table_name}.palette_green IS NOT NULL").first
    [color.red.round, color.green.round, color.blue.round]
  rescue
    nil
  end

  # Return palette color as hex
  def self.palette_hex
    palette_rgb.rgb_to_hex
  rescue
    nil
  end

  # Calculate average of color column
  def self.color_avg(col)
    where("#{self.table_name}.#{col} IS NOT NULL").average(col).to_f
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

  # Return RGB as array
  def palette_rgb_color
    [self.palette_red, self.palette_green, self.palette_blue]
  end

  # Return color as hex code
  def palette_hex_color
    self.palette_hex
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
      palette: {
        rgb: palette_rgb_color,
        hex: palette_hex_color,
      },
      page: self.page.to_api,
      created_at: self.created_at
    }
  end

  def to_public_api
    n = to_api
    n.delete(:page)
    n
  end

private

  def generate_color_hex
    self.color_hex ||= rgb_color.rgb_to_hex
    self.palette_hex ||= palette_rgb_color.rgb_to_hex
  end

  def queue_average_color_worker
    self.page.reload # ensure we get updated record

    # Ping everyone websocket with new color
    WebsocketRails[:everyone].trigger(:new_color, {
      channel: :everyone,
      report: ColorReport.everyone.on(:today, date: @colors_date).get.to_api, 
      color: self.to_public_api
    })

    # Ping user websocket wth new color and update user's daily color report
    if self.user.present?
      # Update report
      ColorWorker.perform_in(30.seconds, :user_report, self.user.id, on: :today, date: Date.today)

      # Send through websocket unless user profile is private
      WebsocketRails["user-#{self.user.uuid}"].trigger(:new_color, {
        channel: self.user.login,
        report: self.user.report(:today, date: Date.today), 
        color: self.to_public_api
      }) unless self.user.profile_private
    end

    # If this color is only color, then average will be same as self
    unless self.page.colors_count > 1
      self.page.update(color_avg_red: self.color_red, color_avg_green: self.color_green, color_avg_blue: self.color_blue, color_avg_hex: self.color_hex)

    # Otherwise queue job to determine the correct average color
    else
      ColorWorker.perform_in(30.seconds, :web_page_report, self.web_site_page_id)
    end
  end

end
