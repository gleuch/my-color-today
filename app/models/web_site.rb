class WebSite < ActiveRecord::Base


  # EXTENSIONS ----------------------------------------------------------------

  # UUID
  include Uuidable

  # FriendlyId
  extend FriendlyId
  friendly_id :uri_domain_tld, use: [:slugged, :finders]

  # Status
  enum status: {
    active:     0
  }
  

  # ASSOCIATIONS --------------------------------------------------------------

  has_many :pages, class: 'WebSitePage'
  has_many :colors, class: 'WebSitePageColor', through: :pages


  # VALIDATIONS ---------------------------------------------------------------

  validates :uri_domain_tld, presence: true

  before_validation :generate_uri_domain_tld, on: :create


  # CLASS METHODS -------------------------------------------------------------

  # Find first or create new web site
  def self.add(url)
    uri = Addressable::URI.parse(url)
    domain_tld = [uri.domain, uri.tld].join('.')

    self.where(uri_domain_tld: domain_tld).first_or_create do |site|
      site.url = url
    end
  end


  # METHODS -------------------------------------------------------------------

  # Parse URL
  def uri
    @@uri ||= Addressable::URI.parse(self.url)
  end


private

  # Parse only for the top level domain
  def generate_uri_domain_tld
    self.uri_domain_tld = [uri.domain, uri.tld].join('.')
  end

end
