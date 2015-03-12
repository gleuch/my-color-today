module Api
  class TokenController < BaseController

    before_filter :authenticate_user_key, only: [:show]


    # Get user info from token
    def show
      respond_to do |format|
        format.json { render json: @api_token.to_api, callback: params[:callback] }
      end
    end


    # Create new token for user
    def create
      results = ->{
        token = ApiToken.create

        if token && !token.new_record?
          {success: true, color: token.to_api}
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
