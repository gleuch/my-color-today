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
    # elsif current_user? && current_user.admin?
    #   return admin_dashboard_index_url
    else
      return root_url
    end
  end

  def authenticate_user!
    unless current_user
      session[:referrer] = request.url
      redirect_to login_url, notice: t(:require_login)
      return false
    else
      return true
    end
  end

end
