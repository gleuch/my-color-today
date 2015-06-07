module Api
  class HistoryController < BaseController

    before_filter :authenticate_user_key


    # Get latest colors
    def index
      results = ->{
        obj = @api_token.user if @api_token.user.present?
        obj ||= @api_token

        colors = obj.page_colors.limit(100).order('created_at desc')

        if colors.count > 0
          {success: true, colors: colors.map(&:to_api), daily: @api_token.user.report(:daily)}
        else
          {error: true}
        end
      }

      respond_to do |format|
        format.json { render json: results.call, callback: params[:callback] }
      end
    end


    # Add new page color into user's history
    def create
      results = ->{
        color = WebSitePageColor.add(params[:url], params[:average_color], params[:dominant_color], api_token: @api_token, user: @api_token.user)

        if color && !color.new_record?
          {success: true, color: color.to_api, daily: @api_token.user.report(:daily)}
        else
          {error: true}
        end
      }

      respond_to do |format|
        format.json { render json: results.call, callback: params[:callback] }
      end
    end


  private


  end

end
