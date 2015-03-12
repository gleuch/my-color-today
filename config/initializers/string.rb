class String

  # Posessive-ify
  def possessive
    self + ('s' == self[-1,1] ? "'" : "'s")
  end

  # return something as true/false from string
  def to_bool
    return true if ['true', '1', 'yes', 'on', 't'].include?(self.downcase)
    return false if ['false', '0', 'no', 'off', 'f'].include?(self.downcase)
    nil
  end

  # determine if is boolean
  def is_bool?
    !self.to_bool.nil?
  end

  # ensures start with
  def random(l=32,m=nil)
    l = (rand(m-l)+l) unless m.blank?
    o, p = [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten, [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten.push('_','-','=')
    o[rand(o.length)] << (2..l).map{ p[rand(p.length)] }.join
  end

  # Check if has allcaps or some combination where there are more capitals in the word than needed.
  # Not the most advanced, but it works for most cases, like "OMFG", "SoHo" and "INCREDiBLE", etc. but not "WTF", etc
  def has_any_all_caps?
    self.split(/\W/).each do |a|
      next if a.length <= 3 || a.match(/^(NYC)$/)
      n = a.gsub(/[\W0-9a-z]+/, '')
      return true if n.length.to_f/a.length.to_f > 0.5
    end
    false
  end

  def to_slug
    self.parameterize
  end

  def strip_unicode(r='')
    self.encode(Encoding.find('ASCII'), {:invalid => :replace, :undef => :replace, :replace => r, :universal_newline => true})
  end

end
