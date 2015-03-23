class UserSessionsController < ApplicationController

  before_filter :authenticate_user!, only: [:destroy]
  before_filter :get_app_token, only: [:new]


  def new
    render :new
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    redirect_to root_url
  end


private

  # If a token is sent, assign to session only if exists
  def get_app_token
    session.delete(:auth_api_app) # clear session
    token = request.authorization.gsub(/^Token token\=/, '')
    return if token.blank?
    session[:auth_api_app] = token if ApiToken.where(token_key: token).count > 0
  rescue
    nil
  end

end
