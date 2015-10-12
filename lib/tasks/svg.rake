namespace :svg do

  desc "Generate SVG for given date and hour"
  task make: :environment do

    puts ARGV.inspect

    (null, date, hour, ) = ARGV

    puts date, hour

    raise "date not specified" if date.blank?
    raise "hour not specified" if hour.blank?

    # Set timezone as UTC
    date = Date.parse(date)
    time = Time.parse("#{date.to_s} 00:00:00 UTC") + hour.to_i.hours


    sql = WebSitePageColor.where('created_at >= ? AND created_at <= ?', time, time + 1.hour - 1.second)
    puts sql.count

    contents, w, i = [], 10, 0
    sql.find_each do |c|
      contents << "<rect width='#{w}' height='#{w}' y='0' x='#{i * w}' fill='##{c.hex_color}' />"
      i += 1
    end

    
    svg = <<-SVG
      <?xml version="1.0"?>
      <svg width="#{i * w}" height="#{w}" viewBox="0 0 #{i * w} #{w}" xmlns="http://www.w3.org/2000/svg">
        #{contents.join("\n")}
      </svg>
    SVG
    

    puts svg

    exit
  end

end

namespace :svg do

  desc "Generate SVG for given date and hour"
  task stripes: :environment do

    puts ARGV.inspect

    (null, date, ) = ARGV

    raise "date not specified" if date.blank?

    # Set timezone as UTC
    date = Date.parse(date)
    time = Time.parse("#{date.to_s} 00:00:00 UTC")

    w, i = 10, 0
    contents, maxct = {}, 0

    (0..23).each do |h|
      sql = WebSitePageColor.where('created_at >= ? AND created_at <= ?', time + h.hours, time + h.hours + 1.hours - 1.seconds)
      maxct = [maxct, sql.count].max
      contents[h] = sql.order('created_at desc').pluck(:color_hex)
    end

    svgcontents = []
    (0..23).each do |h|
      svgcontents << "  <g data-date='#{date.to_s}' date-hour='#{h}'>"
      offset = ((maxct - contents[h].length) / 2.to_f).floor
      contents[h].each_with_index do |v,i|
        svgcontents << "    <rect x='#{(offset + i) * w}' y='#{h * w}' width='#{w}' height='#{w}' fill='##{v}' />"
      end
      svgcontents << "  </g>"
    end

    svg = <<-SVG
<?xml version="1.0"?>
<svg width="#{maxct * w}" height="#{w * 24}" viewBox="0 0 #{maxct * w} #{w * 24}" xmlns="http://www.w3.org/2000/svg">
#{svgcontents.join("\n")}
</svg>
    SVG
    

    puts svg

    exit
  end




  task boxes: :environment do
    (null, strdate, ) = ARGV
    raise "date not specified" if strdate.blank?
    svgMakeBoxes(strdate)
    exit
  end

  task all_boxes: :environment do
    (null, strstartdate, strenddate, ) = ARGV
    raise "start date not specified" if strstartdate.blank?
    raise "end date not specified" if strenddate.blank?

    startdate, enddate = Date.parse(strstartdate), Date.parse(strenddate)
    intv = (enddate - startdate).to_i

    (0..intv).each do |d|
      strdate = (startdate + d.days).to_s
      puts "Building for #{sprintf('%03d', d)} :: #{strdate}"
      svgMakeBoxes(strdate)
    end

    exit
  end



  task increments: :environment do
    (null, date, intv, ) = ARGV
    raise "date not specified" if date.blank?
    intv = 10 if intv.blank?

    date = Date.parse(date)
    time = Time.parse("#{date.to_s} 00:00:00 UTC")

    svgcontents = []
    ct, wr, hr, sc = 86400, 3, 4, 10
    ttl = (ct - 1) / intv
    rt = Math.sqrt(ttl / (wr * hr).to_f).ceil
    w, h = wr * rt, hr * rt

    puts "COUNT: #{ct} / RT: #{rt} / WIDTH: #{w} / HEIGHT: #{h}"

    seconds, colors = [], []
    WebSitePageColor.where('created_at >= ? AND created_at < ?', time, time + 1.day).select('color_hex, UNIX_TIMESTAMP(created_at) as seconds').order('created_at asc').each do |v|
      s = v.seconds - time.to_i # get actual seconds leftover
      s = (s - (s % intv)) / intv.to_f # round down
      colors[s] ||= v.color_hex
    end

    (0..ttl).each do |s|
      next if colors[s].blank?
      x, y = (s % w), (s / w).floor
      svgcontents << "    <rect x='#{x * sc}' y='#{y * sc}' width='#{sc}' height='#{sc}' fill='##{colors[s]}' />"
    end

    svg = <<-SVG
<?xml version="1.0"?>
<svg width="#{sc * w}" height="#{sc * h}" viewBox="0 0 #{sc * w} #{sc * h}" xmlns="http://www.w3.org/2000/svg">
#{svgcontents.join("\n")}
</svg>
    SVG


    puts svg

    exit
  end
end


#
#
#
#
#
#
#
#
#
#
#
#
#
# d = Date.today
# t = Time.parse("#{d.to_s} 00:00:00 UTC")
# (0..86399).each do |s|
#   n = t + s.seconds
#   sql = WebSitePageColor.where('HOUR(created_at) = ? AND MINUTE(created_at) = ? AND SECOND(created_at) = ?', n.hour, n.min, n.sec)
#   puts "#{s}: #{sql.count}"
# end


def svgMakeBoxes(strdate)
  date = Date.parse(strdate)
  time = Time.parse("#{date.to_s} 00:00:00 UTC")

  sql = WebSitePageColor.where('created_at >= ? AND created_at <= ?', time, time + 1.day - 1.second)
  ct = sql.count

  svgcontents = []
  wr, hr, sc = 3, 4, 10
  # wr, hr, sc = 63, 86, 10
  rt = Math.sqrt(ct/(wr * hr).to_f).ceil
  w, h = wr * rt, hr * rt

  n = (ct / h.to_f).ceil
  sp = ((w - n) / 2.to_f).floor

  # puts "COUNT: #{ct} / WIDTH: #{w} / HEIGHT: #{h}"
  
  sql.pluck(:color_hex).in_groups_of(n).each_with_index do |g,r|
    g.each_with_index do |c,i|
      next if c.blank?
      svgcontents << "    <rect x='#{(sp + i) * sc}' y='#{r * sc}' width='#{sc}' height='#{sc}' fill='##{c}' />"
    end
  end

  svg = <<-SVG
<?xml version="1.0"?>
<!-- 
  **
  ** What Color Is My Internet?
  **
  ** A rendering of the browsing history of @gleuch,
  ** as browsed on #{date.strftime('%a, %d %b %Y')}.           
  **
  ** Generated on #{Time.now.localtime.strftime('%a, %d %b %Y %H:%M:%S %Z')}.
  **
  ** (C) 2015 by Greg Leuch. All Rights Reserved.
  ** https://mycolor.today
  **
-->
<svg width="#{sc * w}" height="#{sc * h}" viewBox="0 0 #{sc * w} #{sc * h}" xmlns="http://www.w3.org/2000/svg">
#{svgcontents.join("\n")}
</svg>
  SVG

  svgfpath = File.join(Rails.root, 'output', 'boxes', 'svg', "#{strdate}.svg")
  epsfpath = File.join(Rails.root, 'output', 'boxes', 'eps', "#{strdate}.eps")
  FileUtils.mkdir_p( File.dirname(svgfpath) )# rescue nil
  FileUtils.mkdir_p( File.dirname(epsfpath) )# rescue nil
  File.open(svgfpath, 'w') {|f| f.write(svg) }
  File.unlink(epsfpath) rescue nil
  `convert #{svgfpath} #{epsfpath}`
end



# 43p0 x 31p6
# 86 x 63