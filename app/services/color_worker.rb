class ColorWorker

  include Sidekiq::Worker

  sidekiq_options unique: true


  def perform(type, id, *args)
    case type.to_s
      when 'user_report'
        user_report(id, *args)
      when 'web_page_report'
        web_page_report(id, *args)
      when 'everyone_report'
        everyone_report
    end
  end

  # Generate the color report for user
  def user_report(id,*args)
    user = User.where(id: id).first rescue nil
    return if user.blank?

    opts = args.extract_options!
    opts[:on] ||= :today
    info = user.report(opts[:on], date: opts[:date], recalculate: true)
  end


  # Set the average color for the web page
  def web_page_report(id,*args)
    page = WebSitePage.where(id: id).first rescue nil
    return if page.blank?

    color = WebSitePageColor.where(web_site_page_id: page.id).color_rgb
    page.update(color_avg_red: color[0], color_avg_green: color[1], color_avg_blue: color[2], color_avg_hex: color.rgb_to_hex)
  end


  # Set the average color for all users
  def everyone_report(*args)
    opts = args.extract_options!
    ColorReport.everyone.on(:today, date: opts[:date]).get.recalculate!
  end


end