namespace :info do
  
  task boxes: :environment do
    (null, strdate, ) = ARGV
    raise "date not specified" if strdate.blank?
    infoMakeBoxes(strdate)
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
      infoMakeBoxes(strdate)
    end

    exit
  end

end


def infoMakeBoxes(strdate)
  date = Date.parse(strdate)
  time = Time.parse("#{date.to_s} 00:00:00 UTC")

  info = {date: date, total_sites: 0, total_pages: 0, total_uniq_pages: 0, avg_color: nil, pages: [], sites: [], colors: []}

  # Initial SQL statement
  sql = WebSitePageColor.where('web_site_page_colors.created_at >= ? AND web_site_page_colors.created_at <= ?', time, time + 1.day - 1.second).order('web_site_page_colors.created_at ASC').joins(page: [:site])

  # Get average color
  info[:avg_color] = sql.color_hex

  # Get distinct counts for colors, pages, and sites
  info[:pages] = sql.pluck('web_site_pages.url')
  info[:sites] = sql.pluck('web_sites.uri_domain_tld')
  info[:colors] = sql.pluck('web_site_page_colors.color_hex')
  info[:total_pages] = info[:pages].length
  info[:total_uniq_pages] = info[:pages].uniq.length
  info[:total_sites] = info[:sites].uniq.length

  content = <<-INFO
# #{date.strftime('%a, %d %b %Y')}

## Counts

* Sites: #{info[:total_sites]}
* Pages: #{info[:total_pages]} (Uniq: #{info[:total_uniq_pages]})
* Avg Color: ##{info[:avg_color]}


## URLs:
#{info[:sites].join('   ')}


## Unique URLs:
#{info[:sites].uniq.join('   ')}


## Pages:
#{info[:pages].join('   ')}


## Unique Pages:
#{info[:pages].uniq.join('   ')}



Generated on #{Time.now.localtime.strftime('%a, %d %b %Y %H:%M:%S %Z')}.
(C) 2015 by Greg Leuch. All Rights Reserved. https://mycolor.today

  INFO


  infofpath = File.join(Rails.root, 'output', 'boxes', 'info', "#{strdate}.md")
  FileUtils.mkdir_p( File.dirname(infofpath) )# rescue nil
  File.open(infofpath, 'w') {|f| f.write(content) }
end
