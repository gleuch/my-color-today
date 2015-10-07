class WebSitesController < ApplicationController

  before_filter :get_web_site, only: [:show]
  before_filter :get_colors_date, only: [:show]

  set_pagination_headers :colors, only: [:show]


  def index
    results = ->{
      @web_sites = WebSite.order('pages_count DESC').limit(100)
    }

    respond_to do |format|
      format.html {
        results.call
        render :index
      }
    end
  end


  def show
    results = ->{
      @request_url ||= dated_web_site_url(@web_site, @colors_date)
      @colors ||= @web_site.colors.on(@colors_date).page(before: params[:next_id]).per(100)
    }

    respond_to do |format|
      format.html { render :show }
      format.json {
        results.call
        render json: {
          channel:        @web_site.uuid,
          channelInfo:    @web_site.to_api,
          date:           @colors_date.to_s,
          dateUrl:        @request_url,
          colorData:      @colors.map(&:to_public_api),
          viewType:       :site
        }
      }
    end
  end


private

  def get_web_site
    @web_site = WebSite.find(params[:id]) rescue nil
    raise ActiveRecord::RecordNotFound if @web_site.blank?
  end

  def get_colors_date
    @colors_date = Date.parse(params[:date]) rescue nil
    @colors_date ||= @web_site.page_colors.recent.first.created_at.to_date rescue Date.today
  end


end
