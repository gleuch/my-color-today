class ColorWorker

  include Sidekiq::Worker

  sidekiq_options unique: true


  def perform(type, id, *args)
    case type.to_s
      when 'user_report'
        user_report(id, *args)
      when 'web_page_report'
        web_page_report(id, *args)
    end
  end


  def user_report(id,*args)
    user = User.where(id: id).first rescue nil
    return if user.blank?

    opts = args.extract_options!
    user.color(opts[:on] || :daily, true)
  end


  def web_page_report(id,*args)
    page = WebSitePage.where(id: id).first rescue nil
    return if page.blank?

    color = WebSitePageColor.where(web_site_page_id: page.id).color_rgb
    page.update(color_avg_red: color[0], color_avg_green: color[1], color_avg_blue: color[2], color_avg_hex: color.rgb_to_hex)
  end


end