class ShortCode

  attr_accessor :data

  # LIST OF SHORT CODES AND REDIRECT URLS
  CODES = {
    'amazonbook' => {url: 'https://amazon.com', title: 'Amazon Book Referral Link'},
    'lulubook' => {url: 'https://lulu.com', title: 'Lulu Book Referral Link'}
  }


  def initialize(p={}, format=nil)
    @code, @format = p[:code], format || p[:format]
  end

  def matches?(r)
    return false if r.path_parameters[:code].blank?
    @code, @format = r.path_parameters[:code], r.path_parameters[:format]
    self.exists?
  end

  def code; @code; end
  def url; CODES[ @code ][:url]; end
  def title; CODES[ @code ][:title] || "Code: #{self.code}"; end
  def format; @format || 'html'; end

  def exists?(format=nil)
    !CODES[ @code ].blank?
  end

  def to_api
    {code: self.code, url: self.url, title: self.title}
  end


  # Track as pageview in analytics (perhaps event tracking instead?)
  def track!(*args)
    begin
      opts = args.extract_options!
      data = { v: 1, tid: Setting.google_analytics, cid: opts[:session] || SecureRandom.uuid[0,32], t: :pageview, dp: "/#{self.code}", dh: "mycolor.today", dt: self.title }
      data[:dr] = opts[:referrer] if opts[:referrer].present?
      data[:uid] = opts[:user] if opts[:user].present?
      resp = RestClient.post( 'http://www.google-analytics.com/collect', data )
    rescue
      nil
    end
  end


protected


end
