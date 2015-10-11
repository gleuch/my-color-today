module ApplicationHelper

  def page_title
    (@page_title.present? && @page_title) || t(:name)
  end

  def page_meta_description
    (@page_meta_description.present? && @page_meta_description) || t('meta.description')
  end

  def page_meta_keywords
    (@page_meta_keywords.present? && @page_meta_keywords) || t('meta.keywords')
  end

  def page_meta_robots
    @page_meta_robots || 'index,follow'
  end

  def page_meta_image
    '' # TODO
  end

  def page_canonical_url
    (@canonical_url.present? && @canonical_url) || request.url
  end

  def page_share_title
    @page_share_title
  end

  def page_share_description
    @page_share_description
  end

  def twitter_share_card_type
    @twitter_share_card_type || 'summary'
  end

  def page_category
    ''
  end

  def page_is_nsfw?
    @page_nsfw || false
  end

  def page_type_is?(type)
    about_types, article_types = %w(about profile), %w(project client_work post work lab)
    case type.to_s
      when 'profile'
        about_types.include?(@page_meta_type.to_s)
      when 'article'
        article_types.include?(@page_meta_type.to_s)
      else #when 'website'
        !(about_types + project_types).include?(@page_meta_type.to_s)
    end
  end

  def extension_send_message
    return '' unless session[:extension_message].present?
    msg = session.delete(:extension_message)

    "chrome.runtime.sendMessage('#{Setting.chrome_extension_id}', " + msg.to_json.html_safe + ", function() {});"
  end

  def signin_providers
    User.available_providers.map{|provider| {name: provider.to_s.titleize, url: authenticate_url(provider)} }
  end

end