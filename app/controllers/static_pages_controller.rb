class StaticPagesController < ApplicationController

  before_filter :load_resource, only: [:show]

  set_pagination_headers :latest_colors, only: [:show]


  def show
    @_static_page_options = {}

    respond_to do |format|
      format.html {
        trigger_actions

        @body_classes << 'static-page' << "page-#{@page.page.gsub(/\/|\-/m, '_').gsub(/("|')/m, '')}"
        render @page.file, @_static_page_options
      }
      format.json {
        trigger_actions
        render json: @page.data
      }
      format.any { render_not_found }
    end
  end

  def home
    results = -> {
      @latest_colors = WebSitePageColor.recently(5.days).page(before: params[:next_id]).per(100)
    }

    respond_to do |format|
      format.html { results.call }
      format.json {
        @page.data = {
          channel:      'all_users',
          channelInfo:  {},
          colors:       results.call.map(&:to_public_api),
          url:          root_url,
          viewType:     :everyone
        }
      }
    end
  end
  alias_method :svg, :home


protected

  def load_resource
    @page = StaticPage.new(params)
    raise ActiveRecord::RecordNotFound unless @page.exists?
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