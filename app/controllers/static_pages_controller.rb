class StaticPagesController < ApplicationController

  before_filter :load_resource, only: [:show]
  before_filter :load_short_code, only: [:short_code]

  set_pagination_headers :colors, only: [:show]

  def show
    @_static_page_options = {}

    respond_to do |format|
      format.html {
        trigger_actions

        @body_classes << 'static-page' << "page-#{@page.page.gsub(/\/|\-/m, '_').gsub(/("|')/m, '')}"
        render @page.file, @_static_page_options unless performed?
      }
      format.json {
        trigger_actions
        json = JSON.parse(@page.data) rescue nil
        render json: json || @page.data, callback: params[:callback] unless performed?
      }
      format.any { render_not_found }
    end
  end

  def home
    if current_user?
      render_user_channel(current_user)
    else
      render_everyone_channel
    end
  end
  alias_method :svg, :home

  def load_data
    @page.load_json_data
  end

  def everyone
    render_everyone_channel
  end

  def short_code
    respond_to do |format|
      format.html {
        @code.track!(session: session.id, user: current_user && current_user.uuid, referrer: request.referer)
        redirect_to @code.url
      }
      format.json {
        render json: @code.to_api, callback: params[:callback] unless performed?
      }
      format.any { render_not_found }
    end
  end


protected

  def load_resource
    @page = StaticPage.new(params)
    raise ActiveRecord::RecordNotFound unless @page.exists?
  end

  def load_short_code
    @code = ShortCode.new(params)
    raise ActiveRecord::RecordNotFound unless @code.exists?
  end

  def trigger_actions
    begin
      send(@page.page_method)
    rescue ActiveRecord::RecordNotFound => err
      raise err
    rescue => err
      nil
    end if respond_to?(@page.page_method)
  end

end