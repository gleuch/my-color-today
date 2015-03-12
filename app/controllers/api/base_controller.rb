module Api
  class BaseController < ApplicationController

    include ActionController::HttpAuthentication::Token::ControllerMethods


  private

    def authenticate_user_key
      authenticate_or_request_with_http_token do |token, options|
        @api_token = ApiToken.where(token_key: token).first
      end
    end

  end
end