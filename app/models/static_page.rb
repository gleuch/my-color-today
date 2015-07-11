class StaticPage

  # include ActionDispatch::Routing::UrlFor
  # include Rails.application.routes.url_helpers

  attr_accessor :data

  def initialize(p={})
    @page, @format = p[:page], p[:format]
    @data = {}
  end

  def matches?(r)
    return false if r.path_parameters[:page].blank?
    @page, @format = r.path_parameters[:page], r.path_parameters[:format]
    self.exists?
  end

  def file; (!self.page.blank? ? "static_pages/#{self.page}" : nil).downcase; end
  def page; @page.gsub(/\-/m, '_').downcase; end
  def page_method; @page.gsub(/\/|\-/m, '_').downcase; end
  def format; @format || 'html'; end

  def exists?(format=nil)
    return false if self.page.blank?
    fpath = File.join(Rails.root, "app/views/static_pages/#{self.page}.#{self.format}.haml")
    return false unless fpath.match(/app\/views\/static_pages\//) # dirup hack prevention
    File.exists?(fpath) && File.readable?(fpath)
  end

  def self.available_pages(f=:html)
    Dir.glob("app/views/static_pages/*.#{f.to_s}.haml").map{|f| File.basename(f).split('.')[0]}
  end


protected


end
