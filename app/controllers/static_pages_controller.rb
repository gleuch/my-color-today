class StaticPagesController < ApplicationController

  before_filter :load_resource, only: [:show]

  set_pagination_headers :colors, only: [:show]


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
        json = JSON.parse(@page.data) rescue nil
        render json: json || @page.data, callback: params[:callback]
      }
      format.any { render_not_found }
    end
  end

  def home
    results = -> {
      @colors_date = Date.parse(params[:date]) rescue nil
      @colors_date ||= WebSitePageColor.recent.first.created_at.to_date rescue Date.today

      @request_url ||= dated_everyone_url(@colors_date)
      @colors = WebSitePageColor.on(@colors_date).page(before: params[:next_id]).per(100)
    }

    respond_to do |format|
      format.html { results.call }
      format.json {
        @page.data = {
          channel:      'all_users',
          channelInfo:  {},
          date:         @colors_date.to_s,
          dateUrl:      @request_url,
          colorData:    results.call.map(&:to_public_api),
          report:       ColorReport.everyone.on(:daily, date: @colors_date).get.to_api,
          viewType:     :everyone
        }
      }
    end
  end
  alias_method :svg, :home

  def load_data
    @page.load_json_data
  end


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