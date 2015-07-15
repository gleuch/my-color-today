class WebSitesController < ApplicationController

  before_filter :get_web_site, only: [:show]

  set_pagination_headers :latest_colors, only: [:show]


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
      @latest_colors = @web_site.colors.recently(5.days).page(before: params[:next_id]).per(100)
    }

    respond_to do |format|
      format.html {
        results.call
        render :show
      }
      format.json {
        render json: {
          channel:      @web_site.uuid,
          channelInfo:  @web_site.to_api,
          colors:       results.call.map(&:to_public_api),
          url:          web_site_url(@web_site),
          viewType:     :site
        }
      }
    end
  end


private

  def get_web_site
    @web_site = WebSite.find(params[:id]) rescue nil
    raise ActiveRecord::RecordNotFound if @web_site.blank?
  end

end
