class UserSessionsController < ApplicationController

  before_filter :get_app_token, only: [:new]
  before_filter :authenticate_user!, only: [:destroy]


  def new
    render :new
  end

  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    respond_to do |format|
      format.html {
        render :destroy
      }
    end
  end


private

  # If a token is sent, assign to session only if exists
  def get_app_token
    session.delete(:auth_api_app) # clear session
    token = request.authorization.gsub(/^Token token\=/, '')
    return if token.blank?

    @api_token = ApiToken.where(token_key: token).first rescue nil
    unless @api_token.blank?
      if current_user && @api_token.user.present?
        raise ActiveRecord::RecordNotFound unless @api_token.user.id == current_user.id
      end

      session[:auth_api_app] = token

      if @api_token.user.present?
        session[:extension_message] ||= {}
        session[:extension_message]['closeWindow'] = true
      end
    end
  rescue
    nil
  end

end
