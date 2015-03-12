require 'rubygems'
require 'gems'

gems = {}
File.open('Gemfile', 'r') do |f|
  while l = f.gets
    next unless l.match(/^([\s\t]+)?gem/i)
    l = l.gsub(/\s|\t/m,'').gsub(/^([\s\t]+)?gem/,'').gsub(/\"/m,'\'')

    if l.match(/^\'([A-Z0-9\_\-]+)\'(,\'([\=\~\>\<A-Z0-9\.]+)\'.*)?$/i)
      n,v = l.gsub(/^\'([A-Z0-9\_\-]+)\'(,\'([\=\~\>\<A-Z0-9\.]+)\'.*)?$/i,'\1|\3').split('|')
    else
      n,v = l.gsub(/^\'([A-Z0-9\_\-]+)\'(.*)?$/i,'\1|').split('|')
    end

    gems[n] = v
  end
end

puts "GEM".ljust(50) << "YOUR VERSION".ljust(20) << "CURRENT VERSION".ljust(20) << "DIFF?".ljust(10),"="*100,""

gems.each do |n,v|
  begin
    g = Gems.info(n) rescue nil
    c = g['version']
    c ||= 'NOT FOUND'
    next if c == v
  rescue
    c = 'ERROR'
  end
  puts n.ljust(50) << (v || '--').ljust(20) << c.ljust(20) << (c != v ? '[X]' : '').ljust(10)
end
