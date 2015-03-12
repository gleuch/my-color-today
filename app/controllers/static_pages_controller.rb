class StaticPagesController < ApplicationController

  before_filter :load_resource, only: [:show]


  def show
    @_static_page_options = {}

    respond_to do |format|
      format.html {
        begin
          send(@page.page_method)
        rescue ActiveRecord::RecordNotFound => err
          raise err
        rescue => err
          nil
        end if respond_to?(@page.page_method)

        @body_classes << 'static-page' << "page-#{@page.page.gsub(/\/|\-/m, '_').gsub(/("|')/m, '')}"
        render @page.file, @_static_page_options
      }
      format.any { render_not_found }
    end
  end

  def home
    @latest_colors = WebSitePageColor.order('created_at desc').limit(100)
  end


protected

  def load_resource
    @page = StaticPage.new(params)
    raise ActiveRecord::RecordNotFound unless @page.exists?
  end

end