class StaticPage

  attr_accessor :data


  def initialize(p={}, format=nil)
    @page, @format = p[:page], format || p[:format]
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
    return self.exists_for? || self.exists_for?('.haml') || self.exists_for?('.haml',:html)
  end

  def load_json_data(format=nil)
    return nil unless self.page.present? && self.exists_for?(nil,:json)
    self.data = File.read(self.fpath(nil,:json))# rescue nil
  end

  def self.available_pages(f=:html)
    Dir.glob("app/views/static_pages/*.#{f.to_s}.haml").map{|f| File.basename(f).split('.')[0]}
  end


protected

  def fpath(suffix=nil, format=nil)
    File.join(Rails.root, "app/views/static_pages/#{self.page}.#{format || self.format}#{suffix}")
  end

  def exists_for?(suffix=nil, format=nil)
    f = self.fpath(suffix, format)
    return false unless f.match(/app\/views\/static_pages\//) # dirup hack prevention
    File.exists?(f) && File.readable?(f)
  end

end
