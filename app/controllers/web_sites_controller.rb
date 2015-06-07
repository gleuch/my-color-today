class WebSitesController < ApplicationController

  before_filter :get_web_site, only: [:show]


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
    respond_to do |format|
      format.html {
        @latest_colors = @web_site.colors.recently(5.days).limit(100)
        render :show
      }
    end
  end


private

  def get_web_site
    @web_site = WebSite.find(params[:id]) rescue nil
    puts @web_site.inspect
    raise ActiveRecord::RecordNotFound if @web_site.blank?
  end

end
