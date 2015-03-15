module Api
  class TokensController < BaseController

    before_filter :authenticate_user_key, only: [:show]
    after_filter :set_csrf_header, only: [:create]


    # Get user info from token
    def show
      respond_to do |format|
        format.json { render json: @api_token.to_api, callback: params[:callback] }
      end
    end


    # Create new token for user
    def create
      results = ->{
        if params[:token_key].present?
          token = ApiToken.where(token_key: params[:token_key], token_secret: params[:token_secret]).first rescue nil
          token.reset_token_and_key(true) if token.present?
        end

        token ||= ApiToken.create

        if token && !token.new_record?
          {success: true, authentication: token.to_api}
        else
          {error: true}
        end
      }

      respond_to do |format|
        format.json { render json: results.call, callback: params[:callback] }
      end
    end


  private

    def set_csrf_header
      response.headers['X-CSRF-Token'] = form_authenticity_token
    end

  end

end
