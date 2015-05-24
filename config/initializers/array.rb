class Array

  def average
    self.sum / self.size.to_f rescue 0
  end
  alias_method :mean, :average

  def humanize_join(str=',')
    if self.length > 2
      l = self.pop
      "#{self.join(', ')}, #{str} #{l}"
    elsif self.length == 2
      "#{self.shift} #{str} #{self.pop}"
    elsif self.length == 1
      self.shift
    else
      ''
    end
  end

  def and_join
    self.humanize_join( I18n.t('and') )
  end

  def or_join
    self.humanize_join( I18n.t('or') )
  end

  def to_slug(s='-')
    self.compact.map{|v| (v || '').to_s.parameterize}.join(s)
  end

  def rgb_to_hex
    ("%02x%02x%02x" % self).upcase
  rescue
    nil
  end

end
