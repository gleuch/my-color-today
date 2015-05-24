class ColorReport < ActiveRecord::Base

  # EXTENSIONS ----------------------------------------------------------------

  # UUID
  include Uuidable



  # ENUM ----------------------------------------------------------------------

  enum date_range: {
    overall:    0,
    daily:      1,  # last 24 hours
    today:      2,  # since midnight
    yesterday:  3,  # yesterday (00:00-23:59)
    range:      4,  # time range
    date:       5,
  }



  # ASSOCIATIONS --------------------------------------------------------------

  belongs_to :item, polymorphic: true



  # VALIDATIONS ---------------------------------------------------------------

  serialize :date_range_vaue, Array



  # SCOPES --------------------------------------------------------------------

  scope :on, ->(d) { where(date_range: ColorReport.date_ranges[d]) }
  scope :recent, -> { order('updated_at desc') }



  # CLASS METHODS -------------------------------------------------------------

  def self.get
    n = recent.first_or_create do |r|
      r.calculate_color_avg
    end
  end



  # METHODS -------------------------------------------------------------------

  # Return RGB as array
  def color_rgb
    return nil if self.color_red.blank? || self.color_green.blank? || self.color_blue.blank?
    [self.color_red, self.color_green, self.color_blue]
  end

  # Return as hex
  def color_hex
    color_rgb.rgb_to_hex
  rescue
    nil
  end

  def recalculate!
    return true if self.created_at > Time.now - 30.seconds
    self.calculate_color_avg && self.save
    self
  end

  def calculate_color_avg
    v = WebSitePageColor
    v = v.where(self.query_value) unless self.query_value.blank?

    case self.item_type.to_s
      when 'User'
        v = v.where(user_id: self.item_id)
      when 'WebSite'
        v = v.where(web_site_page_id: WebSitePage.where(web_site_id: self.item_id).pluck(:id))
      when 'WebPage'
        v = v.where(web_site_page_id: self.item_id)
    end

    case self.date_range.to_s
      when 'daily'
        v = v.where('created_at > ?', Time.now-1.day)
      when 'today'
        v = v.where('DATE(created_at) = ?', Date.today)
      when 'yesterday'
        v = v.where('DATE(created_at) = ?', Date.today - 1.day)
      when 'range'
        v = v.where('created_at >= ? AND created_at <= ?', self.date_range_value[0], self.date_range_value[1]) if self.date_range_value.length > 1
      when 'date'
        v = v.where('DATE(created_at) = ?', self.date_range_value[0]) if self.date_range_value.length > 0
    end

    color = self.palette ? v.palette_rgb : v.color_rgb
    self.assign_attributes(views_count: v.count, color_red: color[0], color_green: color[1], color_blue: color[2]) unless color.blank?
  end



private


end
