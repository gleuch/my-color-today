class ColorReport < ActiveRecord::Base

  # EXTENSIONS ----------------------------------------------------------------

  # UUID
  include Uuidable



  # ENUM ----------------------------------------------------------------------

  enum date_range: {
    # overall:    0,
    daily:      1,  # last 24 hours
    # today:      2,  # since midnight
    # yesterday:  3,  # yesterday (00:00-23:59)
    # range:      4,  # time range
    # date:       5,
  }



  # ASSOCIATIONS --------------------------------------------------------------

  belongs_to :item, polymorphic: true



  # VALIDATIONS ---------------------------------------------------------------

  serialize :date_range_vaue, Array



  # SCOPES --------------------------------------------------------------------

  scope :on, ->(d,*args) {
    opts = args.extract_options!
    n = where(date_range: ColorReport.date_ranges[d])
    n = n.where('DATE(created_at) = ?', opts[:date]) if opts[:date] # If a specific date is specified
    n
  }
  scope :recent, -> { order('updated_at desc') }
  scope :everyone, -> { where(item_type: 'Everyone') }



  # CLASS METHODS -------------------------------------------------------------

  def self.get
    n = recent.first_or_create do |r|
      r.calculate_color_avg
    end
  end



  # METHODS -------------------------------------------------------------------

  # API return
  def to_api
    obj = case self.item_type.to_s
      when 'User', 'Everyone'
        {pages_count: self.views_count, sites_count: self.unique_views_count}
      else
        {count: self.views_count}
    end

    obj.merge({ rgb: self.color_rgb, hex: self.color_hex, palette: self.palette })
  end

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
    calculate_color_avg
    self.save
  end

  def calculate_color_avg
    v = WebSitePageColor
    v = v.where(self.query_value) unless self.query_value.blank?
    ctv, ctuv = 0, 0

    case self.date_range.to_s
      when 'daily'
        v = v.where("#{WebSitePageColor.table_name}.created_at > ?", Time.now-1.day)
      when 'today'
        v = v.where("DATE(#{WebSitePageColor.table_name}.created_at) = ?", Date.today)
      when 'yesterday'
        v = v.where("DATE(#{WebSitePageColor.table_name}.created_at) = ?", Date.today - 1.day)
      when 'range'
        v = v.where("#{WebSitePageColor.table_name}.created_at >= ? AND #{WebSitePageColor.table_name}.created_at <= ?", self.date_range_value[0], self.date_range_value[1]) if self.date_range_value.length > 1
      when 'date'
        v = v.where("DATE(#{WebSitePageColor.table_name}.created_at) = ?", self.date_range_value[0]) if self.date_range_value.length > 0
    end

    case self.item_type.to_s
      when 'Everyone'
        ct = v.joins(page: [:site]).select('COUNT(web_site_pages.id) as pages_count, COUNT(DISTINCT web_sites.id) as sites_count').first
        ctv, ctuv = ct.pages_count, ct.sites_count

      when 'User'
        v = v.where(user_id: self.item_id)
        ct = v.joins(page: [:site]).select('COUNT(web_site_pages.id) as pages_count, COUNT(DISTINCT web_sites.id) as sites_count').first
        ctv, ctuv = ct.pages_count, ct.sites_count

      when 'WebSite'
        v = v.joins(:page).where(web_site_pages: {web_site_id: self.item_id})
        ctv = v.count

      when 'WebPage'
        v = v.where(web_site_page_id: self.item_id)
        ctv = v.count
    end

    color = self.palette ? v.palette_rgb : v.color_rgb

    self.assign_attributes(views_count: ctv, unique_views_count: ctuv, color_red: color[0], color_green: color[1], color_blue: color[2]) unless color.blank?
  end



private


end
