module Api
  class HistoryController < BaseController

    before_filter :authenticate_user_key


    # Add new page color into user's history
    def create
      results = ->{
        color = WebSitePageColor.add(params[:url], params[:color], @api_token.user)

        if color && !color.new_record?
          {success: true, color: color.to_api}
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
