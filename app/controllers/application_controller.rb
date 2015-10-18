class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_filter :app_init

  helper_method :current_user

  rescue_from Timeout::Error, Redis::TimeoutError, with: :rescue_from_timeout


  def app_init
    # Define some necessary variables
    @body_classes = []
    @_page = [1,(params[:page] || 1).to_i].max

    # Set the locale if available but different to EN
    I18n.locale = params[:locale] if User.is_valid_language(params[:locale])


    @page_title = t(:name)
  end

  # Enable force_ssl where required
  def ssl_configured?
    Rails.env.production?
  end

  def rescue_from_timeout(e)
    # notify_airbrake(e) rescue nil
    respond_to do |format|
      format.html { render file: 'public/408', layout: false }
      format.any { render status: 408, text: '', layout: false }
    end and return
  end

  
private

  # Is the request coming from itself? (A few 3rd party tools make requests that originate from self, we don't want to track those.)
  def request_is_self?
    (request.url == request.referer) rescue false
  end

  def store_location(u=nil)
    uri ||= request.get? ? request.request_uri : request.referer
    session[:return_to] = uri
  end

  def redirect_back_or_default(uri, *args)
    opts = args.extract_options!
    redirect_to(session.delete(:return_to) || request.referer || uri, opts)
  end

  def current_user?
    current_user.present?
  end

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end

  def after_sign_in_url
    if !session[:referrer].nil?
      referrer = session[:referrer]
      session[:referrer] = nil
      return referrer
    else
      return root_url
    end
  end
  helper_method :after_sign_in_url

  def authenticate_user!
    unless current_user
      session[:referrer] = request.url
      redirect_to login_url, notice: t(:require_login)
      return false
    else
      return true
    end
  end


  def self.set_pagination_headers(name, options = {})
    after_filter(options) do |controller|
      results = instance_variable_get("@#{name}") rescue nil
      if results.present?
        request_url = instance_var_get("@request_url") rescue nil
        headers["X-Pagination"] = {
          total_results: results.total_results,
          total_entries: results.total_entries,
          next_cursor: results.next_cursor,
          prev_cursor: results.prev_cursor,
          current_cursor: (request_url || options[:request_url] || request.url rescue nil),
          next_url: (results.next_url(request_url || options[:request_url] || request.url) rescue nil),
          prev_url: (results.prev_url(request_url || options[:request_url] || request.url) rescue nil)
        }.to_json
      end
    end
  end


  # ---------------------------------------------------------------------------

  def render_everyone_channel
    results = -> {
      @colors_date = Date.parse(params[:date]) rescue nil
      @colors_date ||= WebSitePageColor.recent.first.created_at.to_date rescue Date.today

      @request_url ||= dated_everyone_url(@colors_date)
      @colors = WebSitePageColor.on(@colors_date).page(before: params[:next_id]).per(100)
    }

    respond_to do |format|
      format.html { render :'static_pages/everyone' }
      format.json {
        data = results.call.map(&:to_public_api)
        render json: {
          channel:      'all_users',
          channelInfo:  {},
          date:         @colors_date.to_s,
          dateUrl:      @request_url,
          colorData:    data,
          report:       ColorReport.everyone.on(:today, date: @colors_date).get.to_api,
          viewType:     :everyone
        }, callback: params[:callback]
      }
    end
  end

  def render_user_channel(user)
    @user = user

    results = ->{
      @request_url ||= dated_user_profile_url(@user, @colors_date)
      @colors ||= @user.page_colors.on(@colors_date).page(before: params[:next_id]).per(100)
    }

    respond_to do |format|
      format.html { render :'users/show' }
      format.json {
        results.call
        render json: {
          channel:        @user.uuid,
          channelInfo:    @user.to_api,
          date:           @colors_date.to_s,
          dateUrl:        @request_url,
          colorData:      @colors.map(&:to_public_api),
          report:         @user.report(:today, date: @colors_date),
          viewType:       :user
        }, callback: params[:callback]
      }
    end
  end


end
