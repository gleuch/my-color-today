class WebSitePage < ActiveRecord::Base


  # EXTENSIONS ----------------------------------------------------------------

  # UUID
  include Uuidable

  # FriendlyId
  extend FriendlyId
  friendly_id :uri_path, use: [:slugged, :finders]


  # ASSOCIATIONS --------------------------------------------------------------

  belongs_to :site, class_name: 'WebSite', counter_cache: :pages_count, foreign_key: :web_site_id

  has_many :colors, class_name: 'WebSitePageColor', foreign_key: :web_site_page_id
  has_many :reports, class_name: 'ColorReport', as: :item


  # VALIDATIONS ---------------------------------------------------------------

  validates :url, presence: true

  before_validation :generate_uri_path, on: :create
  before_create :associate_web_site
  before_save :update_color_avg_hex
  

  # CLASS METHODS -------------------------------------------------------------

  # Find first or create new web site page
  def self.add(url)
    self.where(url: url).first_or_create
  end



  # METHODS -------------------------------------------------------------------

  # Return RGB as array
  def rgb_color
    [self.color_avg_red, self.color_avg_green, self.color_avg_blue]
  end
  alias_method :average_rgb_color, :rgb_color

  # Return color as hex code
  def hex_color
    self.color_avg_hex
  end
  alias_method :average_hex_color, :hex_color

  # Parse URL
  def uri
    Addressable::URI.parse(self.url)
  end

  # API return information
  def to_api
    {
      id: self.uuid,
      url: self.url,
      domain_tld: self.site.uri_domain_tld,
      colors: {
        rgb: average_rgb_color,
        hex: average_hex_color
      },
      colors_count: self.colors_count,
      created_at: self.created_at,
    }
  end

  def daily_color_avg
    reports.on(:today).get
  end


private

  # Generate path
  def generate_uri_path
    self.uri_path = uri.path
  end

  # Associate or create new web site
  def associate_web_site
    self.site ||= WebSite.add(self.url)
  end

  # Hex color
  def update_color_avg_hex
    self.color_avg_hex = rgb_color.rgb_to_hex
  end

end
